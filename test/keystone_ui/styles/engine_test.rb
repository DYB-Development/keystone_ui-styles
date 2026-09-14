# frozen_string_literal: true

require "test_helper"
require "keystone_ui/styles/engine"

class KeystoneUi::Styles::EngineTest < Minitest::Test
  def test_tailwindcss_rails_finds_the_entry_file_under_the_engine_name
    engine = KeystoneUi::Styles::Engine

    assert engine.root.join("app/assets/tailwind/#{engine.engine_name}/engine.css").exist?
  end
end
