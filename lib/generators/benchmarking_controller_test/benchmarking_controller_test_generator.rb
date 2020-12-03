class BenchmarkingControllerTestGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_test_file
    template 'test.erb', file_path
  end

  def create_script
    template 'runner.erb', script_path
  end

  def make_script_executable
    system("chmod a+x #{script_path}")
  end

  private

  def script_path
    "app/services/benchmarking/scripts/run_#{filename}.sh"
  end

  def file_path
    "app/services/benchmarking/aggregate_tests/#{filename}.rb"
  end

  def model
    name.split('_').first
  end

  def endpoint
    name.split('_').second
  end

  def filename
    "#{model.pluralize}_controller_#{endpoint}"
  end
end
