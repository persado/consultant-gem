# frozen_string_literal: true

module Consultant
  class Configuration
    attr_accessor :results_directory, :timezone, :root

    REQUIRED_SETTINGS = [
      :results_directory,
      :timezone,
      :root
    ]

    def initialize
      @results_directory = nil
      @timezone = Time.zone
      @root = File.expand_path '../..', __FILE__
    end

    def configured?
      REQUIRED_SETTINGS.all? do |accessor|
        send(accessor).present?
      end
    end

    def timezone=(zone)
      Time.zone = zone
      @timezone = Time.zone
    end
  end
end
