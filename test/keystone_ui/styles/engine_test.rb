# frozen_string_literal: true

require "test_helper"
require "keystone_ui/styles/engine"

class KeystoneUi::Styles::EngineTest < Minitest::Test
  def test_tailwindcss_rails_finds_no_entry_file_under_the_engine_name_so_it_writes_no_stub_into_hosts
    engine = KeystoneUi::Styles::Engine

    refute engine.root.join("app/assets/tailwind/#{engine.engine_name}/engine.css").exist?
  end

  def test_keeps_the_tailwind_file_where_released_keystone_ui_versions_import_it
    assert KeystoneUi::Styles::Engine.root.join("app/assets/tailwind/keystone_ui_styles/engine.css").exist?
  end

  def test_tells_keystone_ui_where_its_tailwind_file_is
    assert_equal KeystoneUi::Styles::Engine.root.join("app/assets/tailwind/keystone_ui_styles/engine.css"), KeystoneUi::Styles.tailwind_file
  end
end
