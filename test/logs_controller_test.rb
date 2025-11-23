# frozen_string_literal: true

require "test_helper"
require "stringio"
require "ostruct"
require "action_controller"
require "rails_js_logger/logs_controller"

class LogsControllerTest < Minitest::Test
  def setup
    RailsJsLogger.enabled = true
    RailsJsLogger.log_level = :debug
    RailsJsLogger.tag = "JS"
    RailsJsLogger.sample_rate = 1.0
    RailsJsLogger.max_payload_size = 100_000

    @log_output = StringIO.new
    @logger = Logger.new(@log_output)
    RailsJsLogger.logger = @logger

    @controller = RailsJsLogger::LogsController.new
  end

  def test_normalize_level
    assert_equal :info, @controller.send(:normalize_level, "log")
    assert_equal :info, @controller.send(:normalize_level, "LOG")
    assert_equal :info, @controller.send(:normalize_level, "info")
    assert_equal :warn, @controller.send(:normalize_level, "warn")
    assert_equal :error, @controller.send(:normalize_level, "error")
    assert_equal :debug, @controller.send(:normalize_level, "debug")
    assert_equal :info, @controller.send(:normalize_level, "unknown")
    assert_equal :info, @controller.send(:normalize_level, "")
  end

  def test_below_threshold_filters_debug_when_level_is_info
    RailsJsLogger.log_level = :info
    assert @controller.send(:below_threshold?, :debug)
    refute @controller.send(:below_threshold?, :info)
    refute @controller.send(:below_threshold?, :warn)
    refute @controller.send(:below_threshold?, :error)
  end

  def test_below_threshold_allows_all_at_debug_level
    RailsJsLogger.log_level = :debug
    refute @controller.send(:below_threshold?, :debug)
    refute @controller.send(:below_threshold?, :info)
    refute @controller.send(:below_threshold?, :warn)
    refute @controller.send(:below_threshold?, :error)
  end

  def test_below_threshold_only_allows_error_at_error_level
    RailsJsLogger.log_level = :error
    assert @controller.send(:below_threshold?, :debug)
    assert @controller.send(:below_threshold?, :info)
    assert @controller.send(:below_threshold?, :warn)
    refute @controller.send(:below_threshold?, :error)
  end

  def test_sample_out_returns_false_when_rate_is_full
    RailsJsLogger.sample_rate = 1.0
    100.times { refute @controller.send(:sample_out?) }
  end

  def test_sample_out_returns_true_when_rate_is_zero
    RailsJsLogger.sample_rate = 0.0
    100.times { assert @controller.send(:sample_out?) }
  end

  def test_write_log_writes_with_tag
    @controller.send(:write_log, :info, "test message")
    @log_output.rewind
    assert_includes @log_output.read, "[JS]"

    @log_output.truncate(0)
    RailsJsLogger.tag = "Frontend"
    @controller.send(:write_log, :warn, "warning")
    @log_output.rewind
    assert_includes @log_output.read, "[Frontend]"
  end

  def test_log_entry_writes_to_logger
    entry = { level: "info", message: "test log entry" }
    @controller.send(:log_entry, entry)
    @log_output.rewind
    output = @log_output.read
    assert_includes output, "test log entry"
  end

  def test_log_entry_respects_log_level_threshold
    RailsJsLogger.log_level = :error
    entry = { level: "info", message: "should not appear" }
    @controller.send(:log_entry, entry)
    @log_output.rewind
    output = @log_output.read
    refute_includes output, "should not appear"
  end

  def test_log_entry_truncates_long_messages
    long_message = "x" * 20_000
    entry = { level: "info", message: long_message }
    @controller.send(:log_entry, entry)
    @log_output.rewind
    output = @log_output.read
    # Message should be truncated to 10_000 chars + "..."
    assert output.length < long_message.length
  end

  def test_log_entry_respects_sample_rate
    RailsJsLogger.sample_rate = 0.0
    entry = { level: "info", message: "sampled out" }
    @controller.send(:log_entry, entry)
    @log_output.rewind
    output = @log_output.read
    refute_includes output, "sampled out"
  end

  def test_constants
    assert_equal :info, RailsJsLogger::LogsController::LEVEL_MAP["log"]
    assert_equal :warn, RailsJsLogger::LogsController::LEVEL_MAP["warn"]
    assert_equal 0, RailsJsLogger::LogsController::LEVEL_ORDER[:debug]
    assert_equal 3, RailsJsLogger::LogsController::LEVEL_ORDER[:error]
  end
end
