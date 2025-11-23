# frozen_string_literal: true

require "test_helper"
require "rails/generators"
require "generators/rails_js_logger/install_generator"

class InstallGeneratorTest < Minitest::Test
  def test_generator_exists
    assert defined?(RailsJsLogger::Generators::InstallGenerator)
  end

  def test_generator_inherits_from_base
    assert RailsJsLogger::Generators::InstallGenerator < Rails::Generators::Base
  end

  def test_generator_has_source_root
    source_root = RailsJsLogger::Generators::InstallGenerator.source_root
    assert source_root.end_with?("templates")
  end

  def test_generator_has_description
    desc = RailsJsLogger::Generators::InstallGenerator.desc
    assert_includes desc, "RailsJsLogger"
  end

  def test_template_exists
    template_path = File.join(
      RailsJsLogger::Generators::InstallGenerator.source_root,
      "initializer.rb.tt"
    )
    assert File.exist?(template_path), "Template file should exist"
  end

  def test_usage_file_exists
    usage_path = File.join(
      File.dirname(RailsJsLogger::Generators::InstallGenerator.source_root),
      "USAGE"
    )
    assert File.exist?(usage_path), "USAGE file should exist"
  end
end
