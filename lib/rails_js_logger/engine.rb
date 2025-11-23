# frozen_string_literal: true

module RailsJsLogger
  class Engine < ::Rails::Engine
    isolate_namespace RailsJsLogger

    initializer "rails_js_logger.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << Engine.root.join("app/assets/javascripts")
        app.config.assets.precompile << "rails_js_logger.js"
      end
    end

    initializer "rails_js_logger.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << Engine.root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << Engine.root.join("app/assets/javascripts")
      end
    end
  end
end
