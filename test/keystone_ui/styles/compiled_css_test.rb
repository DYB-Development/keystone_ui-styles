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

  def test_small_button_uses_small_text
    assert_includes rule(".ks-button-sm"), "font-size: var(--text-sm)"
  end

  def test_medium_button_uses_base_text
    assert_includes rule(".ks-button-md"), "font-size: var(--text-base)"
  end

  def test_large_button_uses_large_text
    assert_includes rule(".ks-button-lg"), "font-size: var(--text-lg)"
  end

  def test_input_has_a_gray_border
    assert_includes rule(".ks-input"), "border-color: var(--color-gray-300)"
  end

  def test_focused_input_rings_in_the_accent_color
    assert_match(/:focus.*?--tw-ring-color: var\(--color-accent-500\)/m, block(".ks-input"))
  end

  def test_input_turns_dark_in_dark_mode
    assert_match(/data-theme="dark".*?background-color: var\(--color-zinc-900\)/m, block(".ks-input"))
  end

  def test_disabled_input_shows_a_not_allowed_cursor
    assert_includes rule(".ks-input-disabled"), "cursor: not-allowed"
  end

  def test_label_uses_gray_text
    assert_includes rule(".ks-label"), "color: var(--color-gray-700)"
  end

  def test_required_marker_is_red
    assert_includes rule(".ks-required"), "color: var(--color-red-500)"
  end

  def test_hint_uses_muted_gray_text
    assert_includes rule(".ks-hint"), "color: var(--color-gray-500)"
  end

  def test_error_uses_red_text
    assert_includes rule(".ks-error"), "color: var(--color-red-600)"
  end

  def test_checkbox_uses_the_accent_color
    assert_includes rule(".ks-checkbox"), "color: var(--color-accent-600)"
  end

  def test_defines_every_surface_color_variable_even_when_no_class_uses_it
    assert_includes self.class.compiled, "--color-surface-950: #09090b"
  end

  def test_badge_classes_match_keystone_ui_badge
    assert_includes rule(".ks-badge"), "border-radius: calc(infinity * 1px)"
    assert_includes rule(".ks-badge-neutral"), "background-color: var(--color-gray-100)"
    assert_includes rule(".ks-badge-success"), "background-color: var(--color-green-100)"
    assert_includes rule(".ks-badge-danger"), "background-color: var(--color-red-100)"
    assert_includes rule(".ks-badge-warning"), "background-color: var(--color-yellow-100)"
    assert_includes rule(".ks-badge-info"), "background-color: var(--color-accent-100)"
    assert_match(/data-theme="dark".*?background-color: color-mix\(in (srgb|oklab), var\(--color-accent-900\) 50%, transparent\)/m, block(".ks-badge-info"))
  end

  private

  def block(selector)
    self.class.compiled[/^  #{Regexp.escape(selector)} \{\n(.*?)^  \}\n/m, 1].to_s
  end

  def rule(selector)
    self.class.compiled[/^\s*#{Regexp.escape(selector)}\s*\{(.*?)\}/m, 1].to_s
  end
end
