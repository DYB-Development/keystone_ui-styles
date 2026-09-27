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

  def test_primary_button_background_reads_the_accent_colour_role
    assert_includes rule(".ks-button-primary"), "background-color: var(--ks-color-accent)"
  end

  def test_panel_background_reads_the_surface_colour_role
    assert_includes rule(".ks-panel"), "background-color: var(--ks-color-surface)"
  end

  def test_panel_turns_dark_when_the_page_chooses_dark
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-surface-dark\)/m, block(".ks-panel"))
  end

  def test_panel_turns_dark_when_the_operating_system_is_dark
    assert_match(/prefers-color-scheme: dark.*?background-color: var\(--ks-color-surface-dark\)/m, block(".ks-panel"))
  end

  def test_panel_stays_light_on_a_dark_operating_system_when_the_page_chooses_light
    assert_match(/prefers-color-scheme: dark.*?:not\(\[data-theme="light"\], \[data-theme="light"\] \*/m, block(".ks-panel"))
  end

  def test_panel_stays_light_on_a_dark_operating_system_when_the_page_chooses_custom
    assert_match(/prefers-color-scheme: dark.*?:not\(.*?\[data-theme="custom"\], \[data-theme="custom"\] \*\)/m, block(".ks-panel"))
  end

  def test_custom_page_draws_white_in_the_custom_background
    assert_includes rule('[data-theme="custom"]'), "--color-white: var(--color-custom-background)"
  end

  def test_custom_page_draws_every_gray_shade_as_a_blend_of_text_into_background
    blends = { 50 => 3, 100 => 6, 200 => 12, 300 => 20, 400 => 40, 500 => 55, 600 => 68, 700 => 78, 800 => 87, 900 => 94, 950 => 100 }
    missing = blends.reject do |shade, share|
      self.class.compiled.include?("--color-gray-#{shade}: color-mix(in oklab, var(--color-custom-text) #{share}%, var(--color-custom-background))")
    end

    assert_equal({}, missing)
  end

  def test_custom_page_draws_every_zinc_shade_as_a_blend_of_text_into_background
    blends = { 50 => 3, 100 => 6, 200 => 12, 300 => 20, 400 => 40, 500 => 55, 600 => 68, 700 => 78, 800 => 87, 900 => 94, 950 => 100 }
    missing = blends.reject do |shade, share|
      self.class.compiled.include?("--color-zinc-#{shade}: color-mix(in oklab, var(--color-custom-text) #{share}%, var(--color-custom-background))")
    end

    assert_equal({}, missing)
  end

  def test_custom_background_defaults_to_white
    assert_includes self.class.compiled, "--color-custom-background: #ffffff"
  end

  def test_custom_text_defaults_to_near_black
    assert_includes self.class.compiled, "--color-custom-text: #18181b"
  end

  def test_button_corner_radius_reads_the_control_radius_variable
    assert_includes rule(".ks-button"), "border-radius: var(--ks-radius-control)"
  end

  def test_control_radius_defaults_to_the_large_radius_inside_a_layer
    assert_match(/@layer base \{.*?:root \{[^}]*--ks-radius-control: var\(--radius-lg\)/m, self.class.compiled)
  end

  def test_button_font_weight_reads_the_strong_weight_variable
    assert_includes rule(".ks-button"), "font-weight: var(--ks-font-weight-strong)"
  end

  def test_strong_font_weight_defaults_to_semibold
    assert_match(/:root \{[^}]*--ks-font-weight-strong: var\(--font-weight-semibold\)/m, self.class.compiled)
  end

  def test_button_font_reads_the_body_font_variable
    assert_includes rule(".ks-button"), "font-family: var(--ks-font-body)"
  end

  def test_button_border_width_reads_the_control_border_width_variable
    assert_includes rule(".ks-button"), "border-width: var(--ks-border-width-control)"
  end

  def test_control_border_width_defaults_to_none
    assert_match(/:root \{[^}]*--ks-border-width-control: 0px/m, self.class.compiled)
  end

  def test_small_button_side_padding_reads_the_spacing_variable
    assert_includes rule(".ks-button-sm"), "padding-inline: calc(var(--ks-spacing) * 3)"
  end

  def test_small_button_end_padding_reads_the_spacing_variable
    assert_includes rule(".ks-button-sm"), "padding-block: calc(var(--ks-spacing) * 1.5)"
  end

  def test_medium_button_side_padding_reads_the_spacing_variable
    assert_includes rule(".ks-button-md"), "padding-inline: calc(var(--ks-spacing) * 4)"
  end

  def test_medium_button_end_padding_reads_the_spacing_variable
    assert_includes rule(".ks-button-md"), "padding-block: calc(var(--ks-spacing) * 2)"
  end

  def test_large_button_side_padding_reads_the_spacing_variable
    assert_includes rule(".ks-button-lg"), "padding-inline: calc(var(--ks-spacing) * 5)"
  end

  def test_large_button_end_padding_reads_the_spacing_variable
    assert_includes rule(".ks-button-lg"), "padding-block: calc(var(--ks-spacing) * 3)"
  end

  def test_spacing_defaults_to_the_tailwind_spacing_unit
    assert_match(/:root \{[^}]*--ks-spacing: var\(--spacing\)/m, self.class.compiled)
  end

  def test_accent_colour_role_defaults_to_accent_600
    assert_match(/:root \{[^}]*\-\-ks\-color\-accent:\ var\(\-\-color\-accent\-600\)/m, self.class.compiled)
  end

  def test_primary_button_hover_reads_the_accent_hover_colour_role
    assert_match(/&:hover.*?background-color: var\(--ks-color-accent-hover\)/m, block(".ks-button-primary"))
  end

  def test_accent_hover_colour_role_defaults_to_accent_500
    assert_match(/:root \{[^}]*\-\-ks\-color\-accent\-hover:\ var\(\-\-color\-accent\-500\)/m, self.class.compiled)
  end

  def test_primary_button_text_reads_the_on_fill_colour_role
    assert_includes rule(".ks-button-primary"), "color: var(--ks-color-on-fill)"
  end

  def test_on_fill_colour_role_defaults_to_white
    assert_match(/:root \{[^}]*\-\-ks\-color\-on\-fill:\ var\(\-\-color\-white\)/m, self.class.compiled)
  end

  def test_neutral_colour_role_defaults_to_gray_500
    assert_match(/:root \{[^}]*\-\-ks\-color\-neutral:\ var\(\-\-color\-gray\-500\)/m, self.class.compiled)
  end

  def test_secondary_button_hover_reads_the_neutral_hover_colour_role
    assert_match(/&:hover.*?background-color: var\(--ks-color-neutral-hover\)/m, block(".ks-button-secondary"))
  end

  def test_neutral_hover_colour_role_defaults_to_gray_400
    assert_match(/:root \{[^}]*\-\-ks\-color\-neutral\-hover:\ var\(\-\-color\-gray\-400\)/m, self.class.compiled)
  end

  def test_secondary_button_text_reads_the_on_fill_colour_role
    assert_includes rule(".ks-button-secondary"), "color: var(--ks-color-on-fill)"
  end

  def test_danger_colour_role_defaults_to_red_600
    assert_match(/:root \{[^}]*\-\-ks\-color\-danger:\ var\(\-\-color\-red\-600\)/m, self.class.compiled)
  end

  def test_danger_button_hover_reads_the_danger_hover_colour_role
    assert_match(/&:hover.*?background-color: var\(--ks-color-danger-hover\)/m, block(".ks-button-danger"))
  end

  def test_danger_hover_colour_role_defaults_to_red_500
    assert_match(/:root \{[^}]*\-\-ks\-color\-danger\-hover:\ var\(\-\-color\-red\-500\)/m, self.class.compiled)
  end

  def test_danger_button_text_reads_the_on_fill_colour_role
    assert_includes rule(".ks-button-danger"), "color: var(--ks-color-on-fill)"
  end

  def test_primary_button_background_reads_the_dark_accent_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-accent-dark\)/m, block(".ks-button-primary"))
  end

  def test_dark_accent_colour_role_defaults_to_accent_600
    assert_match(/:root \{[^}]*\-\-ks\-color\-accent\-dark:\ var\(\-\-color\-accent\-600\)/m, self.class.compiled)
  end

  def test_primary_button_hover_reads_the_dark_accent_hover_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?&:hover.*?background-color: var\(--ks-color-accent-hover-dark\)/m, block(".ks-button-primary"))
  end

  def test_dark_accent_hover_colour_role_defaults_to_accent_500
    assert_match(/:root \{[^}]*\-\-ks\-color\-accent\-hover\-dark:\ var\(\-\-color\-accent\-500\)/m, self.class.compiled)
  end

  def test_secondary_button_background_reads_the_dark_neutral_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-neutral-dark\)/m, block(".ks-button-secondary"))
  end

  def test_dark_neutral_colour_role_defaults_to_gray_500
    assert_match(/:root \{[^}]*\-\-ks\-color\-neutral\-dark:\ var\(\-\-color\-gray\-500\)/m, self.class.compiled)
  end

  def test_secondary_button_hover_reads_the_dark_neutral_hover_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?&:hover.*?background-color: var\(--ks-color-neutral-hover-dark\)/m, block(".ks-button-secondary"))
  end

  def test_dark_neutral_hover_colour_role_defaults_to_gray_400
    assert_match(/:root \{[^}]*\-\-ks\-color\-neutral\-hover\-dark:\ var\(\-\-color\-gray\-400\)/m, self.class.compiled)
  end

  def test_danger_button_background_reads_the_dark_danger_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-danger-dark\)/m, block(".ks-button-danger"))
  end

  def test_dark_danger_colour_role_defaults_to_red_600
    assert_match(/:root \{[^}]*\-\-ks\-color\-danger\-dark:\ var\(\-\-color\-red\-600\)/m, self.class.compiled)
  end

  def test_danger_button_hover_reads_the_dark_danger_hover_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?&:hover.*?background-color: var\(--ks-color-danger-hover-dark\)/m, block(".ks-button-danger"))
  end

  def test_dark_danger_hover_colour_role_defaults_to_red_500
    assert_match(/:root \{[^}]*\-\-ks\-color\-danger\-hover\-dark:\ var\(\-\-color\-red\-500\)/m, self.class.compiled)
  end

  def test_primary_button_text_reads_the_dark_on_fill_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*? color: var\(--ks-color-on-fill-dark\)/m, block(".ks-button-primary"))
  end

  def test_dark_on_fill_colour_role_defaults_to_white
    assert_match(/:root \{[^}]*\-\-ks\-color\-on\-fill\-dark:\ var\(\-\-color\-white\)/m, self.class.compiled)
  end

  def test_secondary_button_text_reads_the_dark_on_fill_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*? color: var\(--ks-color-on-fill-dark\)/m, block(".ks-button-secondary"))
  end

  def test_danger_button_text_reads_the_dark_on_fill_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*? color: var\(--ks-color-on-fill-dark\)/m, block(".ks-button-danger"))
  end

  def test_secondary_button_background_reads_the_neutral_colour_role
    assert_includes rule(".ks-button-secondary"), "background-color: var(--ks-color-neutral)"
  end

  def test_danger_button_background_reads_the_danger_colour_role
    assert_includes rule(".ks-button-danger"), "background-color: var(--ks-color-danger)"
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

  def test_alert_classes_match_keystone_ui_alert
    assert_includes rule(".ks-alert"), "border-radius: var(--radius-md)"
    assert_includes rule(".ks-alert-info"), "background-color: var(--color-accent-50)"
    assert_includes rule(".ks-alert-success"), "background-color: var(--color-green-50)"
    assert_includes rule(".ks-alert-warning"), "background-color: var(--color-yellow-50)"
    assert_includes rule(".ks-alert-error"), "background-color: var(--color-red-50)"
    assert_includes rule(".ks-alert-body"), "display: flex"
    assert_includes rule(".ks-alert-content"), "flex: 1"
    assert_includes rule(".ks-alert-title"), "font-weight: var(--font-weight-semibold)"
    assert_includes rule(".ks-alert-message"), "font-size: var(--text-sm)"
    assert_includes rule(".ks-alert-message-titled"), "margin-top: var(--spacing)"
    assert_includes rule(".ks-alert-dismiss"), "cursor: pointer"
    assert_match(/data-theme="dark".*?color: var\(--color-accent-300\)/m, block(".ks-alert-info"))
  end

  def test_card_classes_match_keystone_ui_card
    assert_includes rule(".ks-card"), "border-radius: var(--radius-lg)"
    assert_includes rule(".ks-card-edge"), "border-block-width: 1px"
    assert_includes rule(".ks-card-body"), "padding-inline: calc(var(--spacing) * 4)"
    assert_includes rule(".ks-card-title"), "font-size: var(--text-lg)"
    assert_includes rule(".ks-card-summary"), "color: var(--color-gray-500)"
    assert_includes rule(".ks-card-cta"), "padding-bottom: calc(var(--spacing) * 4)"
    assert_includes rule(".ks-card-link"), "color: var(--color-accent-600)"
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-surface-dark\)/m, block(".ks-card"))
  end

  def test_section_classes_match_keystone_ui_section
    assert_includes rule(".ks-section-sm"), "margin-top: calc(var(--spacing) * 4)"
    assert_includes rule(".ks-section-md"), "margin-top: calc(var(--spacing) * 6)"
    assert_includes rule(".ks-section-lg"), "margin-top: calc(var(--spacing) * 8)"
    assert_includes rule(".ks-section-header"), "justify-content: space-between"
    assert_includes rule(".ks-section-title"), "font-size: var(--text-lg)"
    assert_includes rule(".ks-section-subtitle"), "color: var(--color-gray-500)"
    assert_includes rule(".ks-section-action"), "color: var(--color-accent-600)"
    assert_match(/data-theme="dark".*?color: var\(--color-white\)/m, block(".ks-section-title"))
  end

  def test_page_header_classes_match_keystone_ui_page_header
    assert_includes rule(".ks-page-header"), "margin-bottom: calc(var(--spacing) * 6)"
    assert_includes rule(".ks-page-header-title"), "font-size: var(--text-2xl)"
    assert_includes rule(".ks-page-header-subtitle"), "color: var(--color-gray-500)"
    assert_includes rule(".ks-page-header-actions"), "flex-shrink: 0"
    assert_match(/data-theme="dark".*?color: var\(--color-white\)/m, block(".ks-page-header-title"))
  end

  def test_page_classes_match_keystone_ui_page
    assert_includes rule(".ks-page"), "padding-inline: calc(var(--spacing) * 4)"
    assert_includes rule(".ks-page-sm"), "max-width: var(--container-2xl)"
    assert_includes rule(".ks-page-md"), "max-width: var(--container-4xl)"
    assert_includes rule(".ks-page-lg"), "max-width: var(--container-6xl)"
    assert_includes rule(".ks-page-xl"), "max-width: var(--container-7xl)"
    assert_includes rule(".ks-page-xl"), "margin-inline: auto"
    assert_includes rule(".ks-page-offset-sm"), "padding-top: calc(var(--spacing) * 12)"
    assert_includes rule(".ks-page-offset-md"), "padding-top: calc(var(--spacing) * 16)"
    assert_includes rule(".ks-page-offset-lg"), "padding-top: calc(var(--spacing) * 20)"
    assert_includes rule(".ks-page-offset-xl"), "padding-top: calc(var(--spacing) * 24)"
  end

  def test_color_surface_defaults_to_var_color_white
    assert_match(/:root \{[^}]*--ks-color-surface: var\(--color-white\)/m, self.class.compiled)
  end

  def test_color_surface_dark_defaults_to_var_color_zinc_900
    assert_match(/:root \{[^}]*--ks-color-surface-dark: var\(--color-zinc-900\)/m, self.class.compiled)
  end

  def test_panel_border_reads_the_border_colour_role
    assert_includes rule(".ks-panel"), "border-color: var(--ks-color-border)"
  end

  def test_color_border_defaults_to_var_color_gray_200
    assert_match(/:root \{[^}]*--ks-color-border: var\(--color-gray-200\)/m, self.class.compiled)
  end

  def test_panel_border_reads_the_dark_border_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-panel"))
  end

  def test_color_border_dark_defaults_to_var_color_zinc_700
    assert_match(/:root \{[^}]*--ks-color-border-dark: var\(--color-zinc-700\)/m, self.class.compiled)
  end

  def test_card_background_reads_the_surface_colour_role
    assert_includes rule(".ks-card"), "background-color: var(--ks-color-surface)"
  end

  def test_card_border_reads_the_border_colour_role
    assert_includes rule(".ks-card"), "border-color: var(--ks-color-border)"
  end

  def test_card_border_reads_the_dark_border_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-card"))
  end

  def test_edge_to_edge_card_background_reads_the_surface_colour_role
    assert_includes rule(".ks-card-edge"), "background-color: var(--ks-color-surface)"
  end

  private

  def block(selector)
    self.class.compiled[/^  #{Regexp.escape(selector)} \{\n(.*?)^  \}\n/m, 1].to_s
  end

  def rule(selector)
    self.class.compiled[/^\s*#{Regexp.escape(selector)}\s*\{(.*?)\}/m, 1].to_s
  end
end
