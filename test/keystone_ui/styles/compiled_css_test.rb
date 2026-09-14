# frozen_string_literal: true

require "test_helper"
require "tailwindcss/ruby"
require "tmpdir"

class KeystoneUi::Styles::CompiledCssTest < Minitest::Test
  ENTRY = File.expand_path("../../../app/assets/tailwind/keystone_ui_styles/engine.css", __dir__)

  def self.compiled
    @compiled ||= Dir.mktmpdir do |dir|
      input = File.join(dir, "application.css")
      output = File.join(dir, "out.css")
      File.write(input, %(@import "tailwindcss";\n@import "#{ENTRY}";\n))
      system(Tailwindcss::Ruby.executable, "-i", input, "-o", output, chdir: dir, exception: true, err: File::NULL)
      File.read(output)
    end
  end

  def test_defines_the_button_class
    assert_match(/\.ks-button\s*\{/, self.class.compiled)
  end

  def test_primary_button_background_reads_the_accent_color_variable
    assert_includes rule(".ks-button-primary"), "background-color: var(--color-accent-600)"
  end

  def test_panel_has_a_white_background
    assert_includes rule(".ks-panel"), "background-color: var(--color-white)"
  end

  def test_panel_turns_dark_when_the_page_chooses_dark
    assert_match(/data-theme="dark".*?background-color: var\(--color-zinc-900\)/m, block(".ks-panel"))
  end

  def test_panel_turns_dark_when_the_operating_system_is_dark
    assert_match(/prefers-color-scheme: dark.*?background-color: var\(--color-zinc-900\)/m, block(".ks-panel"))
  end

  def test_panel_stays_light_on_a_dark_operating_system_when_the_page_chooses_light
    assert_match(/prefers-color-scheme: dark.*?:not\(\[data-theme="light"\], \[data-theme="light"\] \*\)/m, block(".ks-panel"))
  end

  def test_secondary_button_has_a_gray_background
    assert_includes rule(".ks-button-secondary"), "background-color: var(--color-gray-500)"
  end

  def test_danger_button_has_a_red_background
    assert_includes rule(".ks-button-danger"), "background-color: var(--color-red-600)"
  end

  private

  def block(selector)
    self.class.compiled[/^  #{Regexp.escape(selector)} \{\n(.*?)^  \}\n/m, 1].to_s
  end

  def rule(selector)
    self.class.compiled[/^\s*#{Regexp.escape(selector)}\s*\{(.*?)\}/m, 1].to_s
  end
end
