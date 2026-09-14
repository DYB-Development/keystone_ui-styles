# frozen_string_literal: true

require "rails"
require "keystone_ui/styles/leftover_stylesheet"

module KeystoneUi
  module Styles
    class Engine < ::Rails::Engine
      engine_name "keystone_ui_styles_engine"

      initializer "keystone_ui_styles.remove_leftover_stylesheet" do |app|
        LeftoverStylesheet.new(app.root).remove
      end
    end
  end
end
