#! /bin/bash

# function declarations

function usage {
    echo "usage: $PROGRAM_NAME [-m]"
    echo "  -m      drop, create, reset, and migrate sanitized database between each git operation"
    exit 1
}

function get_commits {
  echo $'Enter branch name(s) or commit hash(es):'
  IFS=',' read -ra INPUT_COMMITS
  COMMITS+=( "${INPUT_COMMITS[@]}" )
}

function convert_to_ruby_array() {
  bash_array=("$@")
  for i in "${!bash_array[@]}"; do
    bash_array["$i"]=\'"${bash_array[$i]}"\';
  done
  printf -v joined_array '%s,' "${bash_array[@]}"
  echo "[${joined_array%,}]"
}

function extract_filename() {
  IFS=" " read -ra PARSED <<< "$1"
  if [[ ${#PARSED[@]} -lt 2 ]]; then
    echo "${PARSED[0]}";
  else
    echo "${PARSED[@]:1}"
  fi
}

function safe_filename_for() {
  index="$(ls tmp/ | grep $1 | wc -l | xargs)"
  if [[ $index -ne 0 ]]; then
    echo $1-$index
  else
    echo $1;
  fi
}

function random_letter() {
  s=abcdefghijklmnopqrstuvxwyz
  p=$(( $RANDOM % 26))        echo -n ${s:$p:1}
}

function class_name_safe_commit_hash_for() {
  current_hash="$1"
  if [[ $current_hash =~ ^[0-9] ]]; then
    echo "$(random_letter)"$current_hash
  else
    echo $current_hash
  fi
}

function capitalize() {
  LOWER_CASE="$1"
  echo "$(tr '[:lower:]' '[:upper:]' <<< ${LOWER_CASE:0:1})${LOWER_CASE:1}"
}

# start of main script

uncomitted_files=$(git status --porcelain=v1 2>/dev/null | wc -l)
if [[ $uncomitted_files -ne 0 ]]; then
  echo $'You have uncommited files.\nThis script does a lot of git traversal, so it is not safe to run with uncommited files.\nPlease commit or stash your files and try running again.';
  cd "$RAILS_ROOT"
  git status;
  exit 1;
fi

SKIP_DB=true
while getopts ":m" flag
do
  case "${flag}" in
    m) SKIP_DB=false;;
    *) usage;;
  esac
done

echo $'INSTRUCTIONS:\n\nStart by selecting a mode for entering commits or branch names (see below).\nOnce you have the commit or branch ready, you can enter it in the following formats:\n\na) Just the commit/branch\nb) The commit/branch plus an alias, in the format <commit/branch> <alias>\nc) A list of commits/branches in either format a) or b), separated by commas\n'
prompt=$'Choose mode for entering commits or branches:\n\n1) List branch names\n2) List 10 most recent commits\n3) Search branch names\n4) Search commits\n5) Enter branch names or commits manually\n\nEnter "done" when done'

COMMITS=()

while [[ $MODE != "done" ]]
do
  echo "$prompt"
  read MODE
  case $MODE in
    
    1)
      echo "$(git branch)";
      get_commits;
      ;;
      
    2)
      echo "enter branch name (leave blank to get commits from current branch)"
      read branch_name_for_commits
      if [[ -z $branch_name_for_commits ]]; then
        echo "$(git log -n 10)";
      else
        echo "$(git log -n 10 $branch_name_for_commits)";
      fi
      get_commits;
      ;;
      
    3)
      echo "enter search string:";
      read SEARCH;
      echo "$(git branch | grep "$SEARCH")";
      get_commits;
      ;;
    
    4)
      echo "enter search string:";
      read SEARCH;
      echo "$(git log -i --reverse --grep="$SEARCH")";
      get_commits;
      ;;
      
    5)
      get_commits;
      ;;
      
    done)
      echo "Will run "$TEST_CLASS" test on the following:";
      for commit in "${COMMITS[@]}"; do
        echo "$commit"
      done
      ;;
    
    *)
      echo "Please enter the number of a valid mode"
      ;;
  esac
done

echo "How many tests would you like to run per commit?"
read NUM_RUNS
echo $'Tests are now ready to run.\nFOR BEST PERFORMANCE, CLOSE ANY OTHER PROGRAMS YOU CURRENTLY HAVE OPEN.\nHit enter when ready.'
read confirmation
echo "Starting test..."

CURRENT_HASH="$(git rev-parse HEAD)"
INITIAL_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

cd "$RAILS_ROOT"

for i in "${!COMMITS[@]}"; do
  commit=${COMMITS[$i]}
  hash="$(echo "$commit" | head -n1 | awk '{print $1;}')"
  echo "checking out to \""$(extract_filename "$commit")"\""
  git checkout "$hash" --quiet
  git checkout $CURRENT_HASH app/services/benchmarking --quiet # retrieve this branch's changes to the benchmarking folder so that the new test exists
  if [[ $SKIP_DB = false ]]; then
    if [[ $(ps aux | grep sidekiq | wc -l) -gt 1 ]]; then
      echo "WARNING: Sidekiq is running, which will cause the db:drop to fail. Please exit sidekiq and then hit enter to continue."
      read confirmation
    fi
    echo "resetting db for \""$(extract_filename "$commit")"\""
    bin/rails db:environment:set RAILS_ENV=development && rails db:drop db:create sanitized_data:reset db:migrate
  fi

  if [[ $FOR_CONTROLLER_TEST = true ]]; then
    safe_hash="$(class_name_safe_commit_hash_for "$hash")"
    rails g benchmarking_live_controller_test ""$MODEL_NAME"_"$ENDPOINT"" --commit "$safe_hash"
    TEST_CLASS=""$(capitalize "$MODEL_NAME")"Controller"$(capitalize "$ENDPOINT")""$(capitalize "$safe_hash")""
  fi

  if [[ $i == 0 ]]; then
    rails runner "Benchmarking::AggregateTests::$TEST_CLASS.run_test($NUM_RUNS, \"$commit\")"
  else
    rails runner "Benchmarking::AggregateTests::$TEST_CLASS.run_test($NUM_RUNS, \"$commit\", \"${COMMITS[0]}\")"
  fi
  if [[ $SKIP_DB = false ]]; then
    # stash to avoid db/structure.sql causing any issues
    git stash;
  fi
  git checkout "$INITIAL_BRANCH" --quiet
done

files_list="$(convert_to_ruby_array "${COMMITS[@]}")"

SAFE_OUTPUT_FILENAME="$(safe_filename_for $OUTPUT_FILENAME)"

export_command="Benchmarking::AggregateTests::$TEST_CLASS.create_xlsx($files_list, '$SAFE_OUTPUT_FILENAME')"

rails runner "$export_command"

for commit in "${COMMITS[@]}"; do
  rm ""tmp/"$(extract_filename "$commit")".txt""
  if [[ $FOR_CONTROLLER_TEST = true ]]; then
    hash="$(echo "$commit" | head -n1 | awk '{print $1;}')"
    safe_hash="$(class_name_safe_commit_hash_for "$hash")"
    rm ""app/services/benchmarking/aggregate_tests/"$MODEL_NAME"_controller_"$ENDPOINT"_"$safe_hash".rb""
  fi
done

open -a "Microsoft Excel" "tmp/$SAFE_OUTPUT_FILENAME.xlsx.axlsx"
