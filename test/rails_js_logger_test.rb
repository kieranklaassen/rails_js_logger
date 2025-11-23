# frozen_string_literal: true

require "test_helper"

class RailsJsLoggerTest < Minitest::Test
  def setup
    RailsJsLogger.enabled = true
    RailsJsLogger.log_level = :debug
    RailsJsLogger.tag = "JS"
    RailsJsLogger.sample_rate = 1.0
    RailsJsLogger.max_payload_size = 100_000
  end

  def test_version
    refute_nil RailsJsLogger::VERSION
  end

  def test_enabled_default
    assert RailsJsLogger.enabled
  end

  def test_enabled_setter
    RailsJsLogger.enabled = false
    refute RailsJsLogger.enabled
  end

  def test_log_level_default
    assert_equal :debug, RailsJsLogger.log_level
  end

  def test_log_level_setter
    RailsJsLogger.log_level = :error
    assert_equal :error, RailsJsLogger.log_level
  end

  def test_tag_default
    assert_equal "JS", RailsJsLogger.tag
  end

  def test_tag_setter
    RailsJsLogger.tag = "Frontend"
    assert_equal "Frontend", RailsJsLogger.tag
  end

  def test_sample_rate_default
    assert_equal 1.0, RailsJsLogger.sample_rate
  end

  def test_sample_rate_setter
    RailsJsLogger.sample_rate = 0.5
    assert_equal 0.5, RailsJsLogger.sample_rate
  end

  def test_max_payload_size_default
    assert_equal 100_000, RailsJsLogger.max_payload_size
  end

  def test_max_payload_size_setter
    RailsJsLogger.max_payload_size = 50_000
    assert_equal 50_000, RailsJsLogger.max_payload_size
  end

  def test_logger_default
    assert_kind_of Logger, RailsJsLogger.logger
  end

  def test_logger_setter
    custom_logger = Logger.new($stderr)
    RailsJsLogger.logger = custom_logger
    assert_equal custom_logger, RailsJsLogger.logger
  end
end
