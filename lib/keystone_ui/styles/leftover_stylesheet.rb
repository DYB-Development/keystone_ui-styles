# frozen_string_literal: true

require "pathname"

module KeystoneUi
  module Styles
    class LeftoverStylesheet
      def initialize(root)
        @root = Pathname.new(root)
      end

      def remove
        @root.join("app/assets/builds/tailwind/keystone_ui_styles.css").delete
      end
    end
  end
end
