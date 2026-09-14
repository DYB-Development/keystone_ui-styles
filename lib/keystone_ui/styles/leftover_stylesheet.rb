# frozen_string_literal: true

require "pathname"

module KeystoneUi
  module Styles
    class LeftoverStylesheet
      def initialize(root)
        @root = Pathname.new(root)
      end

      def remove
        leftover = @root.join("app/assets/builds/tailwind/keystone_ui_styles.css")
        leftover.delete if leftover.exist?
      end
    end
  end
end
