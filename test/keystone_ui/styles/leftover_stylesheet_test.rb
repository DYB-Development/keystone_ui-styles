# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "keystone_ui/styles/leftover_stylesheet"

class KeystoneUi::Styles::LeftoverStylesheetTest < Minitest::Test
  def test_removes_the_stylesheet_tailwindcss_rails_generated_for_older_versions
    Dir.mktmpdir do |root|
      leftover = Pathname.new(root).join("app/assets/builds/tailwind/keystone_ui_styles.css")
      leftover.dirname.mkpath
      leftover.write(%(@import "/old/gem/engine.css";))

      KeystoneUi::Styles::LeftoverStylesheet.new(root).remove

      refute leftover.exist?
    end
  end

  def test_does_nothing_when_the_host_has_no_leftover_stylesheet
    Dir.mktmpdir do |root|
      KeystoneUi::Styles::LeftoverStylesheet.new(root).remove

      refute Pathname.new(root).join("app/assets/builds/tailwind/keystone_ui_styles.css").exist?
    end
  end
end
