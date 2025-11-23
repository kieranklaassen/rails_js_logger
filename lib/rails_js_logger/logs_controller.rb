# frozen_string_literal: true

module RailsJsLogger
  class LogsController < ActionController::Base
    LEVEL_MAP = {
      "log" => :info,
      "info" => :info,
      "warn" => :warn,
      "error" => :error,
      "debug" => :debug
    }.freeze

    LEVEL_ORDER = { debug: 0, info: 1, warn: 2, error: 3 }.freeze
    MAX_LOGS_PER_REQUEST = 100

    skip_forgery_protection

    def create
      return head(:no_content) unless RailsJsLogger.enabled
      return head(:request_entity_too_large) if request.content_length.to_i > RailsJsLogger.max_payload_size

      logs = params[:logs] || [params.slice(:level, :message)]
      logs.first(MAX_LOGS_PER_REQUEST).each { |entry| log_entry(entry) }

      head :ok
    end

    private

    def log_entry(entry)
      return if sample_out?

      level = normalize_level(entry[:level])
      return if below_threshold?(level)

      message = entry[:message].to_s.truncate(10_000).gsub(/[\r\n]/, " ").gsub(/\e\[[0-9;]*m/, "")
      write_log(level, message)
    end

    def normalize_level(level)
      LEVEL_MAP.fetch(level.to_s.downcase, :info)
    end

    def below_threshold?(level)
      LEVEL_ORDER[level] < LEVEL_ORDER[RailsJsLogger.log_level]
    end

    def sample_out?
      RailsJsLogger.sample_rate < 1.0 && rand > RailsJsLogger.sample_rate
    end

    def write_log(level, message)
      logger = RailsJsLogger.logger
      tag = RailsJsLogger.tag

      if logger.respond_to?(:tagged)
        logger.tagged(tag) { logger.public_send(level, message) }
      else
        logger.public_send(level, "[#{tag}] #{message}")
      end
    end
  end
end
