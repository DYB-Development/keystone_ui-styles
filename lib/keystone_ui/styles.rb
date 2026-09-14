# frozen_string_literal: true

require "keystone_ui/styles/version"
require "keystone_ui/styles/engine"

module KeystoneUi
  module Styles
    def self.tailwind_file
      Engine.root.join("app/assets/tailwind/keystone_ui_styles/engine.css")
    end
  end
end
