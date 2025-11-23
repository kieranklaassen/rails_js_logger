# frozen_string_literal: true

require_relative "lib/rails_js_logger/version"

Gem::Specification.new do |spec|
  spec.name = "rails_js_logger"
  spec.version = RailsJsLogger::VERSION
  spec.authors = ["Kieran Klaassen"]
  spec.email = ["kieranklaassen@gmail.com"]

  spec.summary = "Bridge JavaScript console output to Rails logs"
  spec.description = "Forward browser console.log, console.error, and window.onerror to Rails logs for unified debugging"
  spec.homepage = "https://github.com/kieranklaassen/rails_js_logger"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["*.{md,txt}", "{app,config,lib}/**/*"]
  spec.require_paths = ["lib"]
end
