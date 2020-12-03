class BenchmarkingTestGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  
  def create_test_file
    template "test.erb", "app/services/benchmarking/aggregate_tests/#{file_name}.rb"
  end
  
  def create_script
    template "runner.erb", script_name
  end
  
  def make_script_executable
    system("chmod a+x #{script_name}")
  end
  
  private

  def script_name
    "app/services/benchmarking/scripts/run_#{file_name}.sh"
  end
end
