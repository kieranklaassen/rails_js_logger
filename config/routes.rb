# frozen_string_literal: true

RailsJsLogger::Engine.routes.draw do
  post "logs", to: "logs#create"
end
