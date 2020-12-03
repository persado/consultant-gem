# frozen_string_literal: true

class BenchmarkingLiveControllerTestGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)
  class_option :commit, type: :string

  def create_test_file
    template 'live_test.erb', file_path
  end

  private

  def script_path
    "app/services/benchmarking/scripts/run_#{filename}.sh"
  end

  def file_path
    "app/services/benchmarking/aggregate_tests/#{filename}.rb"
  end

  def model
    @model ||= name.split("_").first
  end

  def endpoint
    @endpoint ||= name.split("_").second
  end

  def commit
    @commit ||= options['commit'].underscore
  end

  def filename
    "#{model.pluralize}_controller_#{endpoint}_#{commit}"
  end

  def format(str)
    str.titleize.gsub(' ', '')
  end
end
