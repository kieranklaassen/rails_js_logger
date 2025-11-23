# frozen_string_literal: true

require "rails/generators"

module RailsJsLogger
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Install RailsJsLogger to forward JavaScript console output to Rails logs"

      def copy_initializer
        template "initializer.rb.tt", "config/initializers/rails_js_logger.rb"
      end

      def mount_engine
        route %(mount RailsJsLogger::Engine, at: "/rails_js_logger")
      end

      def add_javascript
        if importmap?
          say_status :append, "config/importmap.rb"
          append_to_file "config/importmap.rb", %(pin "rails_js_logger", to: "rails_js_logger.js"\n)

          if File.exist?(Rails.root.join("app/javascript/application.js"))
            say_status :append, "app/javascript/application.js"
            append_to_file "app/javascript/application.js", %(import "rails_js_logger"\n)
          end
        else
          say_status :info, "Add to your JavaScript: import 'rails_js_logger'", :yellow
        end
      end

      private

      def importmap?
        File.exist?(Rails.root.join("config/importmap.rb"))
      end
    end
  end
end
