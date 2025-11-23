# frozen_string_literal: true

require "rails/generators"

module RailsJsLogger
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Install RailsJsLogger"

      def copy_initializer
        template "initializer.rb", "config/initializers/rails_js_logger.rb"
      end

      def add_javascript
        if importmap?
          say "Adding rails_js_logger to importmap"
          append_to_file "config/importmap.rb", %(pin "rails_js_logger", to: "rails_js_logger.js"\n)

          if File.exist?(Rails.root.join("app/javascript/application.js"))
            say "Importing rails_js_logger in application.js"
            append_to_file "app/javascript/application.js", %(import "rails_js_logger"\n)
          end
        else
          say "Add to your JavaScript: import 'rails_js_logger'"
        end
      end

      def mount_engine
        route %(mount RailsJsLogger::Engine, at: "/rails_js_logger")
      end

      private

      def importmap?
        File.exist?(Rails.root.join("config/importmap.rb"))
      end
    end
  end
end
