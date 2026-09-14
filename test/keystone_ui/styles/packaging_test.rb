# frozen_string_literal: true

require "test_helper"
require "rubygems"

class KeystoneUi::Styles::PackagingTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)

  def test_packaged_files_include_the_tailwind_entry_file
    assert_includes packaged_files, "app/assets/tailwind/keystone_ui_styles/engine.css"
  end

  private

  def packaged_files
    Dir.chdir(ROOT) { Gem::Specification.load(File.join(ROOT, "keystone_ui-styles.gemspec")).files }
  end
end
