# frozen_string_literal: true

require "test_helper"
require "keystone_ui/styles/engine"

class KeystoneUi::Styles::EngineTest < Minitest::Test
  def test_tailwindcss_rails_finds_no_entry_file_under_the_engine_name_so_it_writes_no_stub_into_hosts
    engine = KeystoneUi::Styles::Engine

    refute engine.root.join("app/assets/tailwind/#{engine.engine_name}/engine.css").exist?
  end
end
