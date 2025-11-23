# frozen_string_literal: true

require "logger"
require_relative "rails_js_logger/version"

module RailsJsLogger
  class Error < StandardError; end

  class << self
    attr_accessor :enabled, :log_level, :tag, :sample_rate, :max_payload_size
    attr_writer :logger

    def logger
      @logger || default_logger
    end

    private

    def default_logger
      (defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger) || Logger.new($stdout)
    end
  end

  # defaults
  self.enabled = true
  self.log_level = :debug
  self.tag = "JS"
  self.sample_rate = 1.0
  self.max_payload_size = 100_000
end

require_relative "rails_js_logger/engine" if defined?(Rails::Engine)
