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

  def test_input_border_reads_the_control_border_colour_role
    assert_includes rule(".ks-input"), "border-color: var(--ks-color-border-control)"
  end

  def test_focused_input_rings_in_the_accent_color
    assert_match(/:focus.*?--tw-ring-color: var\(--color-accent-500\)/m, block(".ks-input"))
  end

  def test_input_turns_dark_in_dark_mode
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-surface-dark\)/m, block(".ks-input"))
  end

  def test_disabled_input_shows_a_not_allowed_cursor
    assert_includes rule(".ks-input-disabled"), "cursor: not-allowed"
  end

  def test_label_reads_the_label_text_colour_role
    assert_includes rule(".ks-label"), "color: var(--ks-color-text-label)"
  end

  def test_required_marker_is_red
    assert_includes rule(".ks-required"), "color: var(--color-red-500)"
  end

  def test_hint_reads_the_muted_text_colour_role
    assert_includes rule(".ks-hint"), "color: var(--ks-color-text-muted)"
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
    assert_includes rule(".ks-badge-success"), "background-color: var(--ks-color-success-100)"
    assert_includes rule(".ks-badge-danger"), "background-color: var(--ks-color-danger-100)"
    assert_includes rule(".ks-badge-warning"), "background-color: var(--ks-color-warning-100)"
    assert_includes rule(".ks-badge-info"), "background-color: var(--ks-color-info-100)"
    assert_match(/data-theme="dark".*?background-color: color-mix\(in oklab, var\(--ks-color-info-900\) 50%, transparent\)/m, block(".ks-badge-info"))
  end

  def test_alert_classes_match_keystone_ui_alert
    assert_includes rule(".ks-alert"), "border-radius: calc(var(--ks-radius-surface) * 0.75)"
    assert_includes rule(".ks-alert-info"), "background-color: var(--ks-color-info-50)"
    assert_includes rule(".ks-alert-success"), "background-color: var(--ks-color-success-50)"
    assert_includes rule(".ks-alert-warning"), "background-color: var(--ks-color-warning-50)"
    assert_includes rule(".ks-alert-error"), "background-color: var(--ks-color-danger-50)"
    assert_includes rule(".ks-alert-body"), "display: flex"
    assert_includes rule(".ks-alert-content"), "flex: 1"
    assert_includes rule(".ks-alert-title"), "font-weight: var(--ks-font-weight-heading)"
    assert_includes rule(".ks-alert-message"), "font-size: var(--text-sm)"
    assert_includes rule(".ks-alert-message-titled"), "margin-top: var(--spacing)"
    assert_includes rule(".ks-alert-dismiss"), "cursor: pointer"
    assert_match(/data-theme="dark".*? color: var\(--ks-color-info-300\)/m, block(".ks-alert-info"))
  end

  def test_card_classes_match_keystone_ui_card
    assert_includes rule(".ks-card"), "border-radius: var(--ks-radius-surface)"
    assert_includes rule(".ks-card-edge"), "border-block-width: 1px"
    assert_includes rule(".ks-card-body"), "padding-inline: calc(var(--ks-spacing) * 4)"
    assert_includes rule(".ks-card-title"), "font-size: var(--text-lg)"
    assert_includes rule(".ks-card-summary"), "color: var(--ks-color-text-muted)"
    assert_includes rule(".ks-card-cta"), "padding-bottom: calc(var(--ks-spacing) * 4)"
    assert_includes rule(".ks-card-link"), "color: var(--color-accent-600)"
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-surface-dark\)/m, block(".ks-card"))
  end

  def test_section_classes_match_keystone_ui_section
    assert_includes rule(".ks-section-sm"), "margin-top: calc(var(--spacing) * 4)"
    assert_includes rule(".ks-section-md"), "margin-top: calc(var(--spacing) * 6)"
    assert_includes rule(".ks-section-lg"), "margin-top: calc(var(--spacing) * 8)"
    assert_includes rule(".ks-section-header"), "justify-content: space-between"
    assert_includes rule(".ks-section-title"), "font-size: var(--text-lg)"
    assert_includes rule(".ks-section-subtitle"), "color: var(--ks-color-text-muted)"
    assert_includes rule(".ks-section-action"), "color: var(--color-accent-600)"
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-dark\)/m, block(".ks-section-title"))
  end

  def test_page_header_classes_match_keystone_ui_page_header
    assert_includes rule(".ks-page-header"), "margin-bottom: calc(var(--spacing) * 6)"
    assert_includes rule(".ks-page-header-title"), "font-size: var(--text-2xl)"
    assert_includes rule(".ks-page-header-subtitle"), "color: var(--ks-color-text-muted)"
    assert_includes rule(".ks-page-header-actions"), "flex-shrink: 0"
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-dark\)/m, block(".ks-page-header-title"))
  end

  def test_page_classes_match_keystone_ui_page
    assert_includes rule(".ks-page"), "padding-inline: calc(var(--ks-spacing) * 4)"
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

  def test_edge_to_edge_card_background_reads_the_dark_surface_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-surface-dark\)/m, block(".ks-card-edge"))
  end

  def test_edge_to_edge_card_border_reads_the_border_colour_role
    assert_includes rule(".ks-card-edge"), "border-color: var(--ks-color-border)"
  end

  def test_edge_to_edge_card_border_reads_the_dark_border_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-card-edge"))
  end

  def test_input_background_reads_the_surface_colour_role
    assert_includes rule(".ks-input"), "background-color: var(--ks-color-surface)"
  end

  def test_color_border_control_defaults_to_var_color_gray_300
    assert_match(/:root \{[^}]*--ks-color-border-control: var\(--color-gray-300\)/m, self.class.compiled)
  end

  def test_input_border_reads_the_dark_control_border_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-control-dark\)/m, block(".ks-input"))
  end

  def test_color_border_control_dark_defaults_to_var_color_zinc_700
    assert_match(/:root \{[^}]*--ks-color-border-control-dark: var\(--color-zinc-700\)/m, self.class.compiled)
  end

  def test_input_text_reads_the_text_colour_role
    assert_includes rule(".ks-input"), "color: var(--ks-color-text)"
  end

  def test_color_text_defaults_to_var_color_gray_900
    assert_match(/:root \{[^}]*--ks-color-text: var\(--color-gray-900\)/m, self.class.compiled)
  end

  def test_input_text_reads_the_dark_text_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*? color: var\(--ks-color-text-dark\)/m, block(".ks-input"))
  end

  def test_color_text_dark_defaults_to_var_color_white
    assert_match(/:root \{[^}]*--ks-color-text-dark: var\(--color-white\)/m, self.class.compiled)
  end

  def test_color_text_label_defaults_to_var_color_gray_700
    assert_match(/:root \{[^}]*--ks-color-text-label: var\(--color-gray-700\)/m, self.class.compiled)
  end

  def test_label_reads_the_dark_label_text_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*? color: var\(--ks-color-text-label-dark\)/m, block(".ks-label"))
  end

  def test_color_text_label_dark_defaults_to_var_color_gray_300
    assert_match(/:root \{[^}]*--ks-color-text-label-dark: var\(--color-gray-300\)/m, self.class.compiled)
  end

  def test_color_text_muted_defaults_to_var_color_gray_500
    assert_match(/:root \{[^}]*--ks-color-text-muted: var\(--color-gray-500\)/m, self.class.compiled)
  end

  def test_hint_reads_the_dark_muted_text_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*? color: var\(--ks-color-text-muted-dark\)/m, block(".ks-hint"))
  end

  def test_color_text_muted_dark_defaults_to_var_color_gray_400
    assert_match(/:root \{[^}]*--ks-color-text-muted-dark: var\(--color-gray-400\)/m, self.class.compiled)
  end

  def test_section_title_reads_the_text_colour_role
    assert_includes rule(".ks-section-title"), "color: var(--ks-color-text)"
  end

  def test_page_header_title_reads_the_text_colour_role
    assert_includes rule(".ks-page-header-title"), "color: var(--ks-color-text)"
  end

  def test_card_title_reads_the_text_colour_role
    assert_includes rule(".ks-card-title"), "color: var(--ks-color-text)"
  end

  def test_card_title_reads_the_dark_text_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*? color: var\(--ks-color-text-dark\)/m, block(".ks-card-title"))
  end

  def test_section_subtitle_reads_the_dark_muted_text_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*? color: var\(--ks-color-text-muted-dark\)/m, block(".ks-section-subtitle"))
  end

  def test_page_header_subtitle_reads_the_dark_muted_text_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*? color: var\(--ks-color-text-muted-dark\)/m, block(".ks-page-header-subtitle"))
  end

  def test_card_summary_reads_the_dark_muted_text_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*? color: var\(--ks-color-text-muted-dark\)/m, block(".ks-card-summary"))
  end

  def test_section_title_weight_reads_the_heading_font_weight_variable
    assert_includes rule(".ks-section-title"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_font_weight_heading_defaults_to_var_font_weight_semibold
    assert_match(/:root \{[^}]*--ks-font-weight-heading: var\(--font-weight-semibold\)/m, self.class.compiled)
  end

  def test_card_title_weight_reads_the_heading_font_weight_variable
    assert_includes rule(".ks-card-title"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_page_header_title_weight_is_one_step_above_the_heading_font_weight
    assert_includes rule(".ks-page-header-title"), "font-weight: calc(var(--ks-font-weight-heading) + 100)"
  end

  def test_radius_surface_defaults_to_var_radius_lg
    assert_match(/:root \{[^}]*--ks-radius-surface: var\(--radius-lg\)/m, self.class.compiled)
  end

  def test_edge_to_edge_card_radius_reads_the_surface_radius_variable_on_wider_screens
    assert_match(/width >= 40rem.*?border-radius: var\(--ks-radius-surface\)/m, block(".ks-card-edge"))
  end

  def test_input_radius_is_three_quarters_of_the_control_radius
    assert_includes rule(".ks-input"), "border-radius: calc(var(--ks-radius-control) * 0.75)"
  end

  def test_md_panel_radius_reads_the_surface_radius_variable
    assert_includes rule(".ks-panel-radius-md"), "border-radius: var(--ks-radius-surface)"
  end

  def test_lg_panel_radius_reads_the_surface_radius_variable
    assert_includes rule(".ks-panel-radius-lg"), "border-radius: calc(var(--ks-radius-surface) * 1.5)"
  end

  def test_xl_panel_radius_reads_the_surface_radius_variable
    assert_includes rule(".ks-panel-radius-xl"), "border-radius: calc(var(--ks-radius-surface) * 2)"
  end

  def test_panel_shadow_reads_the_surface_shadow_variable
    assert_includes rule(".ks-panel-shadow"), "--tw-shadow: var(--ks-shadow-surface)"
  end

  def test_shadow_surface_defaults_to_var_shadow_sm
    assert_match(/:root \{[^}]*--ks-shadow-surface: var\(--shadow-sm\)/m, self.class.compiled)
  end

  def test_page_py_base_reads_the_spacing_variable
    assert_includes rule(".ks-page"), "padding-block: calc(var(--ks-spacing) * 4)"
  end

  def test_page_px_sm_reads_the_spacing_variable
    assert_match(/width >= 40rem.*?padding-inline: calc\(var\(--ks-spacing\) \* 6\)/m, block(".ks-page"))
  end

  def test_page_px_lg_reads_the_spacing_variable
    assert_match(/width >= 64rem.*?padding-inline: calc\(var\(--ks-spacing\) \* 8\)/m, block(".ks-page"))
  end

  def test_card_body_py_base_reads_the_spacing_variable
    assert_includes rule(".ks-card-body"), "padding-block: calc(var(--ks-spacing) * 4)"
  end

  def test_card_body_px_sm_reads_the_spacing_variable
    assert_match(/width >= 40rem.*?padding-inline: calc\(var\(--ks-spacing\) \* 6\)/m, block(".ks-card-body"))
  end

  def test_card_body_pt_sm_reads_the_spacing_variable
    assert_match(/width >= 40rem.*?padding-top: calc\(var\(--ks-spacing\) \* 6\)/m, block(".ks-card-body"))
  end

  def test_card_body_pb_sm_reads_the_spacing_variable
    assert_match(/width >= 40rem.*?padding-bottom: calc\(var\(--ks-spacing\) \* 4\)/m, block(".ks-card-body"))
  end

  def test_card_call_to_action_px_base_reads_the_spacing_variable
    assert_includes rule(".ks-card-cta"), "padding-inline: calc(var(--ks-spacing) * 4)"
  end

  def test_card_call_to_action_px_sm_reads_the_spacing_variable
    assert_match(/width >= 40rem.*?padding-inline: calc\(var\(--ks-spacing\) \* 6\)/m, block(".ks-card-cta"))
  end

  def test_card_call_to_action_pb_sm_reads_the_spacing_variable
    assert_match(/width >= 40rem.*?padding-bottom: calc\(var\(--ks-spacing\) \* 6\)/m, block(".ks-card-cta"))
  end

  def test_alert_p_base_reads_the_spacing_variable
    assert_includes rule(".ks-alert"), "padding: calc(var(--ks-spacing) * 4)"
  end

  def test_input_px_base_reads_the_spacing_variable
    assert_includes rule(".ks-input"), "padding-inline: calc(var(--ks-spacing) * 3)"
  end

  def test_input_py_base_reads_the_spacing_variable
    assert_includes rule(".ks-input"), "padding-block: calc(var(--ks-spacing) * 2)"
  end

  def test_sm_panel_padding_reads_the_spacing_variable
    assert_includes rule(".ks-panel-padding-sm"), "padding: calc(var(--ks-spacing) * 4)"
  end

  def test_md_panel_padding_reads_the_spacing_variable
    assert_includes rule(".ks-panel-padding-md"), "padding: calc(var(--ks-spacing) * 5)"
  end

  def test_lg_panel_padding_reads_the_spacing_variable
    assert_includes rule(".ks-panel-padding-lg"), "padding: calc(var(--ks-spacing) * 6)"
  end

  def test_success_alert_text_reads_the_success_scale
    assert_includes rule(".ks-alert-success"), "color: var(--ks-color-success-800)"
  end

  def test_success_alert_dbg_reads_the_success_scale
    assert_match(/data-theme="dark".*?background-color: color-mix\(in oklab, var\(--ks-color-success-900\) 30%, transparent\)/m, block(".ks-alert-success"))
  end

  def test_success_alert_dtext_reads_the_success_scale
    assert_match(/data-theme="dark".*? color: var\(--ks-color-success-300\)/m, block(".ks-alert-success"))
  end

  def test_success_badge_text_reads_the_success_scale
    assert_includes rule(".ks-badge-success"), "color: var(--ks-color-success-700)"
  end

  def test_success_badge_dbg_reads_the_success_scale
    assert_match(/data-theme="dark".*?background-color: color-mix\(in oklab, var\(--ks-color-success-900\) 50%, transparent\)/m, block(".ks-badge-success"))
  end

  def test_success_badge_dtext_reads_the_success_scale
    assert_match(/data-theme="dark".*? color: var\(--ks-color-success-400\)/m, block(".ks-badge-success"))
  end

  def test_color_success_50_defaults_to_var_color_green_50
    assert_match(/:root \{[^}]*--ks-color-success-50: var\(--color-green-50\)/m, self.class.compiled)
  end

  def test_color_success_100_defaults_to_var_color_green_100
    assert_match(/:root \{[^}]*--ks-color-success-100: var\(--color-green-100\)/m, self.class.compiled)
  end

  def test_color_success_300_defaults_to_var_color_green_300
    assert_match(/:root \{[^}]*--ks-color-success-300: var\(--color-green-300\)/m, self.class.compiled)
  end

  def test_color_success_400_defaults_to_var_color_green_400
    assert_match(/:root \{[^}]*--ks-color-success-400: var\(--color-green-400\)/m, self.class.compiled)
  end

  def test_color_success_700_defaults_to_var_color_green_700
    assert_match(/:root \{[^}]*--ks-color-success-700: var\(--color-green-700\)/m, self.class.compiled)
  end

  def test_color_success_800_defaults_to_var_color_green_800
    assert_match(/:root \{[^}]*--ks-color-success-800: var\(--color-green-800\)/m, self.class.compiled)
  end

  def test_color_success_900_defaults_to_var_color_green_900
    assert_match(/:root \{[^}]*--ks-color-success-900: var\(--color-green-900\)/m, self.class.compiled)
  end

  def test_warning_alert_text_reads_the_warning_scale
    assert_includes rule(".ks-alert-warning"), "color: var(--ks-color-warning-800)"
  end

  def test_warning_alert_dbg_reads_the_warning_scale
    assert_match(/data-theme="dark".*?background-color: color-mix\(in oklab, var\(--ks-color-warning-900\) 30%, transparent\)/m, block(".ks-alert-warning"))
  end

  def test_warning_alert_dtext_reads_the_warning_scale
    assert_match(/data-theme="dark".*? color: var\(--ks-color-warning-300\)/m, block(".ks-alert-warning"))
  end

  def test_warning_badge_text_reads_the_warning_scale
    assert_includes rule(".ks-badge-warning"), "color: var(--ks-color-warning-700)"
  end

  def test_warning_badge_dbg_reads_the_warning_scale
    assert_match(/data-theme="dark".*?background-color: color-mix\(in oklab, var\(--ks-color-warning-900\) 50%, transparent\)/m, block(".ks-badge-warning"))
  end

  def test_warning_badge_dtext_reads_the_warning_scale
    assert_match(/data-theme="dark".*? color: var\(--ks-color-warning-400\)/m, block(".ks-badge-warning"))
  end

  def test_color_warning_50_defaults_to_var_color_yellow_50
    assert_match(/:root \{[^}]*--ks-color-warning-50: var\(--color-yellow-50\)/m, self.class.compiled)
  end

  def test_color_warning_100_defaults_to_var_color_yellow_100
    assert_match(/:root \{[^}]*--ks-color-warning-100: var\(--color-yellow-100\)/m, self.class.compiled)
  end

  def test_color_warning_300_defaults_to_var_color_yellow_300
    assert_match(/:root \{[^}]*--ks-color-warning-300: var\(--color-yellow-300\)/m, self.class.compiled)
  end

  def test_color_warning_400_defaults_to_var_color_yellow_400
    assert_match(/:root \{[^}]*--ks-color-warning-400: var\(--color-yellow-400\)/m, self.class.compiled)
  end

  def test_color_warning_700_defaults_to_var_color_yellow_700
    assert_match(/:root \{[^}]*--ks-color-warning-700: var\(--color-yellow-700\)/m, self.class.compiled)
  end

  def test_color_warning_800_defaults_to_var_color_yellow_800
    assert_match(/:root \{[^}]*--ks-color-warning-800: var\(--color-yellow-800\)/m, self.class.compiled)
  end

  def test_color_warning_900_defaults_to_var_color_yellow_900
    assert_match(/:root \{[^}]*--ks-color-warning-900: var\(--color-yellow-900\)/m, self.class.compiled)
  end

  def test_danger_alert_text_reads_the_danger_scale
    assert_includes rule(".ks-alert-error"), "color: var(--ks-color-danger-800)"
  end

  def test_danger_alert_dbg_reads_the_danger_scale
    assert_match(/data-theme="dark".*?background-color: color-mix\(in oklab, var\(--ks-color-danger-900\) 30%, transparent\)/m, block(".ks-alert-error"))
  end

  def test_danger_alert_dtext_reads_the_danger_scale
    assert_match(/data-theme="dark".*? color: var\(--ks-color-danger-300\)/m, block(".ks-alert-error"))
  end

  def test_danger_badge_text_reads_the_danger_scale
    assert_includes rule(".ks-badge-danger"), "color: var(--ks-color-danger-700)"
  end

  def test_danger_badge_dbg_reads_the_danger_scale
    assert_match(/data-theme="dark".*?background-color: color-mix\(in oklab, var\(--ks-color-danger-900\) 50%, transparent\)/m, block(".ks-badge-danger"))
  end

  def test_danger_badge_dtext_reads_the_danger_scale
    assert_match(/data-theme="dark".*? color: var\(--ks-color-danger-400\)/m, block(".ks-badge-danger"))
  end

  def test_color_danger_50_defaults_to_var_color_red_50
    assert_match(/:root \{[^}]*--ks-color-danger-50: var\(--color-red-50\)/m, self.class.compiled)
  end

  def test_color_danger_100_defaults_to_var_color_red_100
    assert_match(/:root \{[^}]*--ks-color-danger-100: var\(--color-red-100\)/m, self.class.compiled)
  end

  def test_color_danger_300_defaults_to_var_color_red_300
    assert_match(/:root \{[^}]*--ks-color-danger-300: var\(--color-red-300\)/m, self.class.compiled)
  end

  def test_color_danger_400_defaults_to_var_color_red_400
    assert_match(/:root \{[^}]*--ks-color-danger-400: var\(--color-red-400\)/m, self.class.compiled)
  end

  def test_color_danger_700_defaults_to_var_color_red_700
    assert_match(/:root \{[^}]*--ks-color-danger-700: var\(--color-red-700\)/m, self.class.compiled)
  end

  def test_color_danger_800_defaults_to_var_color_red_800
    assert_match(/:root \{[^}]*--ks-color-danger-800: var\(--color-red-800\)/m, self.class.compiled)
  end

  def test_color_danger_900_defaults_to_var_color_red_900
    assert_match(/:root \{[^}]*--ks-color-danger-900: var\(--color-red-900\)/m, self.class.compiled)
  end

  def test_info_alert_text_reads_the_info_scale
    assert_includes rule(".ks-alert-info"), "color: var(--ks-color-info-800)"
  end

  def test_info_alert_dbg_reads_the_info_scale
    assert_match(/data-theme="dark".*?background-color: color-mix\(in oklab, var\(--ks-color-info-900\) 30%, transparent\)/m, block(".ks-alert-info"))
  end

  def test_info_badge_text_reads_the_info_scale
    assert_includes rule(".ks-badge-info"), "color: var(--ks-color-info-700)"
  end

  def test_info_badge_dtext_reads_the_info_scale
    assert_match(/data-theme="dark".*? color: var\(--ks-color-info-400\)/m, block(".ks-badge-info"))
  end

  def test_color_info_50_defaults_to_var_color_accent_50
    assert_match(/:root \{[^}]*--ks-color-info-50: var\(--color-accent-50\)/m, self.class.compiled)
  end

  def test_color_info_100_defaults_to_var_color_accent_100
    assert_match(/:root \{[^}]*--ks-color-info-100: var\(--color-accent-100\)/m, self.class.compiled)
  end

  def test_color_info_300_defaults_to_var_color_accent_300
    assert_match(/:root \{[^}]*--ks-color-info-300: var\(--color-accent-300\)/m, self.class.compiled)
  end

  def test_color_info_400_defaults_to_var_color_accent_400
    assert_match(/:root \{[^}]*--ks-color-info-400: var\(--color-accent-400\)/m, self.class.compiled)
  end

  def test_color_info_700_defaults_to_var_color_accent_700
    assert_match(/:root \{[^}]*--ks-color-info-700: var\(--color-accent-700\)/m, self.class.compiled)
  end

  def test_color_info_800_defaults_to_var_color_accent_800
    assert_match(/:root \{[^}]*--ks-color-info-800: var\(--color-accent-800\)/m, self.class.compiled)
  end

  def test_color_info_900_defaults_to_var_color_accent_900
    assert_match(/:root \{[^}]*--ks-color-info-900: var\(--color-accent-900\)/m, self.class.compiled)
  end

  def test_border_width_defaults_to_1px
    assert_match(/:root \{[^}]*--ks-border-width: 1px/m, self.class.compiled)
  end

  def test_shadow_overlay_defaults_to_var_shadow_lg
    assert_match(/:root \{[^}]*--ks-shadow-overlay: var\(--shadow-lg\)/m, self.class.compiled)
  end

  def test_font_weight_medium_defaults_to_var_font_weight_medium
    assert_match(/:root \{[^}]*--ks-font-weight-medium: var\(--font-weight-medium\)/m, self.class.compiled)
  end

  def test_modal_backdrop_fill_reads_the_backdrop_colour_role
    assert_includes rule(".ks-modal-backdrop"), "background-color: var(--ks-color-backdrop)"
  end

  def test_color_backdrop_defaults_to_color_mix_in_oklab_var_color_black_60_transparent
    assert_match(/:root \{[^}]*--ks-color-backdrop: color-mix\(in oklab, var\(--color-black\) 60%, transparent\)/m, self.class.compiled)
  end

  def test_modal_panel_radius_is_1_5_of_the_surface_radius
    assert_includes rule(".ks-modal-panel"), "border-radius: calc(var(--ks-radius-surface) * 1.5)"
  end

  def test_modal_panel_border_width_reads_the_border_width_variable
    assert_includes rule(".ks-modal-panel"), "border-width: var(--ks-border-width)"
  end

  def test_modal_panel_border_reads_the_border_colour_role
    assert_includes rule(".ks-modal-panel"), "border-color: var(--ks-color-border)"
  end

  def test_modal_panel_fill_reads_the_overlay_colour_role
    assert_includes rule(".ks-modal-panel"), "background-color: var(--ks-color-overlay)"
  end

  def test_color_overlay_defaults_to_var_color_white
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-overlay: var\(--color-white\)/m, self.class.compiled)
  end

  def test_color_overlay_dark_defaults_to_var_color_zinc_800
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-overlay-dark: var\(--color-zinc-800\)/m, self.class.compiled)
  end

  def test_modal_panel_padding_is_6_spacing_units
    assert_includes rule(".ks-modal-panel"), "padding: calc(var(--ks-spacing) * 6)"
  end

  def test_modal_panel_margin_inline_is_4_spacing_units
    assert_includes rule(".ks-modal-panel"), "margin-inline: calc(var(--ks-spacing) * 4)"
  end

  def test_modal_panel_border_reads_the_border_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-modal-panel"))
  end

  def test_modal_panel_fill_reads_the_overlay_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-overlay-dark\)/m, block(".ks-modal-panel"))
  end

  def test_modal_header_margin_bottom_is_4_spacing_units
    assert_includes rule(".ks-modal-header"), "margin-bottom: calc(var(--ks-spacing) * 4)"
  end

  def test_modal_title_weight_reads_the_heading_font_weight_variable
    assert_includes rule(".ks-modal-title"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_modal_title_text_reads_the_text_heading_colour_role
    assert_includes rule(".ks-modal-title"), "color: var(--ks-color-text-heading)"
  end

  def test_modal_title_text_reads_the_text_heading_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-heading-dark\)/m, block(".ks-modal-title"))
  end

  def test_color_text_heading_defaults_to_var_color_gray_900
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-heading: var\(--color-gray-900\)/m, self.class.compiled)
  end

  def test_color_text_heading_dark_defaults_to_var_color_gray_200
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-heading-dark: var\(--color-gray-200\)/m, self.class.compiled)
  end

  def test_modal_close_text_reads_the_close_colour_role
    assert_includes rule(".ks-modal-close"), "color: var(--ks-color-close)"
  end

  def test_modal_close_text_reads_the_close_hover_colour_role_on_hover
    assert_match(/\&:hover.*?color: var\(--ks-color-close-hover\)/m, block(".ks-modal-close"))
  end

  def test_modal_close_text_reads_the_close_hover_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?\&:hover.*?color: var\(--ks-color-close-hover-dark\)/m, block(".ks-modal-close"))
  end

  def test_color_close_defaults_to_var_color_gray_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-close: var\(--color-gray-400\)/m, self.class.compiled)
  end

  def test_color_close_hover_defaults_to_var_color_gray_600
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-close-hover: var\(--color-gray-600\)/m, self.class.compiled)
  end

  def test_color_close_hover_dark_defaults_to_var_color_gray_200
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-close-hover-dark: var\(--color-gray-200\)/m, self.class.compiled)
  end

  def test_action_menu_margin_top_is_2_spacing_units
    assert_includes rule(".ks-action-menu"), "margin-top: calc(var(--ks-spacing) * 2)"
  end

  def test_action_menu_radius_is_0_75_of_the_surface_radius
    assert_includes rule(".ks-action-menu"), "border-radius: calc(var(--ks-radius-surface) * 0.75)"
  end

  def test_action_menu_fill_reads_the_overlay_colour_role
    assert_includes rule(".ks-action-menu"), "background-color: var(--ks-color-overlay)"
  end

  def test_action_menu_padding_block_is_1_spacing_units
    assert_includes rule(".ks-action-menu"), "padding-block: calc(var(--ks-spacing) * 1)"
  end

  def test_action_menu_shadow_reads_the_overlay_shadow_variable
    assert_includes rule(".ks-action-menu"), "--tw-shadow: var(--ks-shadow-overlay)"
  end

  def test_action_menu_ring_width_reads_the_border_width_variable
    assert_includes rule(".ks-action-menu"), "calc(var(--ks-border-width) + var(--tw-ring-offset-width))"
  end

  def test_action_menu_ring_reads_the_ring_colour_role
    assert_includes rule(".ks-action-menu"), "--tw-ring-color: var(--ks-color-ring)"
  end

  def test_action_menu_fill_reads_the_overlay_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-overlay-dark\)/m, block(".ks-action-menu"))
  end

  def test_action_menu_ring_reads_the_ring_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?--tw-ring-color: var\(--ks-color-ring-dark\)/m, block(".ks-action-menu"))
  end

  def test_color_ring_defaults_to_color_mix_in_oklab_var_color_black_5_transparent
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-ring: color-mix\(in oklab, var\(--color-black\) 5%, transparent\)/m, self.class.compiled)
  end

  def test_color_ring_dark_defaults_to_color_mix_in_oklab_var_color_white_10_transparent
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-ring-dark: color-mix\(in oklab, var\(--color-white\) 10%, transparent\)/m, self.class.compiled)
  end

  def test_action_menu_button_text_reads_the_text_muted_colour_role
    assert_includes rule(".ks-action-menu-button"), "color: var(--ks-color-text-muted)"
  end

  def test_action_menu_button_text_reads_the_text_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-muted-dark\)/m, block(".ks-action-menu-button"))
  end

  def test_menu_margin_top_is_1_spacing_units
    assert_includes rule(".ks-menu"), "margin-top: calc(var(--ks-spacing) * 1)"
  end

  def test_menu_radius_is_0_75_of_the_surface_radius
    assert_includes rule(".ks-menu"), "border-radius: calc(var(--ks-radius-surface) * 0.75)"
  end

  def test_menu_border_width_reads_the_border_width_variable
    assert_includes rule(".ks-menu"), "border-width: var(--ks-border-width)"
  end

  def test_menu_border_reads_the_border_colour_role
    assert_includes rule(".ks-menu"), "border-color: var(--ks-color-border)"
  end

  def test_menu_fill_reads_the_surface_colour_role
    assert_includes rule(".ks-menu"), "background-color: var(--ks-color-surface)"
  end

  def test_menu_shadow_reads_the_overlay_shadow_variable
    assert_includes rule(".ks-menu"), "--tw-shadow: var(--ks-shadow-overlay)"
  end

  def test_menu_border_reads_the_border_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-menu"))
  end

  def test_menu_fill_reads_the_surface_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-surface-dark\)/m, block(".ks-menu"))
  end

  def test_menu_trigger_gap_is_1_spacing_units
    assert_includes rule(".ks-menu-trigger"), "gap: calc(var(--ks-spacing) * 1)"
  end

  def test_menu_trigger_radius_is_0_75_of_the_control_radius
    assert_includes rule(".ks-menu-trigger"), "border-radius: calc(var(--ks-radius-control) * 0.75)"
  end

  def test_menu_trigger_border_width_reads_the_border_width_variable
    assert_includes rule(".ks-menu-trigger"), "border-width: var(--ks-border-width)"
  end

  def test_menu_trigger_padding_inline_is_3_spacing_units
    assert_includes rule(".ks-menu-trigger"), "padding-inline: calc(var(--ks-spacing) * 3)"
  end

  def test_menu_trigger_padding_block_is_2_spacing_units
    assert_includes rule(".ks-menu-trigger"), "padding-block: calc(var(--ks-spacing) * 2)"
  end

  def test_menu_trigger_border_reads_the_border_control_colour_role
    assert_includes rule(".ks-menu-trigger"), "border-color: var(--ks-color-border-control)"
  end

  def test_menu_trigger_fill_reads_the_surface_colour_role
    assert_includes rule(".ks-menu-trigger"), "background-color: var(--ks-color-surface)"
  end

  def test_menu_trigger_text_reads_the_text_colour_role
    assert_includes rule(".ks-menu-trigger"), "color: var(--ks-color-text)"
  end

  def test_menu_trigger_border_reads_the_border_control_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-control-dark\)/m, block(".ks-menu-trigger"))
  end

  def test_menu_trigger_fill_reads_the_surface_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-surface-dark\)/m, block(".ks-menu-trigger"))
  end

  def test_menu_trigger_text_reads_the_text_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-dark\)/m, block(".ks-menu-trigger"))
  end

  def test_menu_option_gap_is_2_spacing_units
    assert_includes rule(".ks-menu-option"), "gap: calc(var(--ks-spacing) * 2)"
  end

  def test_menu_option_padding_inline_is_3_spacing_units
    assert_includes rule(".ks-menu-option"), "padding-inline: calc(var(--ks-spacing) * 3)"
  end

  def test_menu_option_padding_block_is_2_spacing_units
    assert_includes rule(".ks-menu-option"), "padding-block: calc(var(--ks-spacing) * 2)"
  end

  def test_menu_option_text_reads_the_text_label_colour_role
    assert_includes rule(".ks-menu-option"), "color: var(--ks-color-text-label)"
  end

  def test_menu_option_fill_reads_the_hover_colour_role_on_hover
    assert_match(/\&:hover.*?background-color: var\(--ks-color-hover\)/m, block(".ks-menu-option"))
  end

  def test_menu_option_text_reads_the_text_label_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-label-dark\)/m, block(".ks-menu-option"))
  end

  def test_menu_option_fill_reads_the_hover_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?\&:hover.*?background-color: var\(--ks-color-hover-dark\)/m, block(".ks-menu-option"))
  end

  def test_color_hover_defaults_to_var_color_gray_50
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-hover: var\(--color-gray-50\)/m, self.class.compiled)
  end

  def test_color_hover_dark_defaults_to_var_color_zinc_800
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-hover-dark: var\(--color-zinc-800\)/m, self.class.compiled)
  end

  def test_menu_checkbox_radius_is_0_5_of_the_control_radius
    assert_includes rule(".ks-menu-checkbox"), "border-radius: calc(var(--ks-radius-control) * 0.5)"
  end

  def test_menu_checkbox_border_reads_the_border_strong_colour_role
    assert_includes rule(".ks-menu-checkbox"), "border-color: var(--ks-color-border-strong)"
  end

  def test_menu_checkbox_text_reads_the_accent_colour_role
    assert_includes rule(".ks-menu-checkbox"), "color: var(--ks-color-accent)"
  end

  def test_menu_checkbox_ring_reads_the_focus_colour_role_on_focus
    assert_match(/\&:focus.*?--tw-ring-color: var\(--ks-color-focus\)/m, block(".ks-menu-checkbox"))
  end

  def test_menu_checkbox_border_reads_the_border_strong_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-strong-dark\)/m, block(".ks-menu-checkbox"))
  end

  def test_color_border_strong_defaults_to_var_color_gray_300
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-border-strong: var\(--color-gray-300\)/m, self.class.compiled)
  end

  def test_color_border_strong_dark_defaults_to_var_color_zinc_600
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-border-strong-dark: var\(--color-zinc-600\)/m, self.class.compiled)
  end

  def test_color_focus_defaults_to_var_color_accent_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-focus: var\(--color-accent-500\)/m, self.class.compiled)
  end

  def test_copy_button_gap_is_1_5_spacing_units
    assert_includes rule(".ks-copy-button"), "gap: calc(var(--ks-spacing) * 1.5)"
  end

  def test_copy_button_radius_is_0_75_of_the_control_radius
    assert_includes rule(".ks-copy-button"), "border-radius: calc(var(--ks-radius-control) * 0.75)"
  end

  def test_copy_button_border_width_reads_the_border_width_variable
    assert_includes rule(".ks-copy-button"), "border-width: var(--ks-border-width)"
  end

  def test_copy_button_border_reads_the_border_strong_colour_role
    assert_includes rule(".ks-copy-button"), "border-color: var(--ks-color-border-strong)"
  end

  def test_copy_button_fill_reads_the_overlay_colour_role
    assert_includes rule(".ks-copy-button"), "background-color: var(--ks-color-overlay)"
  end

  def test_copy_button_padding_inline_is_3_spacing_units
    assert_includes rule(".ks-copy-button"), "padding-inline: calc(var(--ks-spacing) * 3)"
  end

  def test_copy_button_padding_block_is_1_5_spacing_units
    assert_includes rule(".ks-copy-button"), "padding-block: calc(var(--ks-spacing) * 1.5)"
  end

  def test_copy_button_weight_reads_the_medium_font_weight_variable
    assert_includes rule(".ks-copy-button"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_copy_button_text_reads_the_text_label_colour_role
    assert_includes rule(".ks-copy-button"), "color: var(--ks-color-text-label)"
  end

  def test_copy_button_fill_reads_the_hover_raised_colour_role_on_hover
    assert_match(/\&:hover.*?background-color: var\(--ks-color-hover-raised\)/m, block(".ks-copy-button"))
  end

  def test_copy_button_border_reads_the_border_strong_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-strong-dark\)/m, block(".ks-copy-button"))
  end

  def test_copy_button_fill_reads_the_overlay_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-overlay-dark\)/m, block(".ks-copy-button"))
  end

  def test_copy_button_text_reads_the_text_label_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-label-dark\)/m, block(".ks-copy-button"))
  end

  def test_copy_button_fill_reads_the_hover_raised_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?\&:hover.*?background-color: var\(--ks-color-hover-raised-dark\)/m, block(".ks-copy-button"))
  end

  def test_color_hover_raised_defaults_to_var_color_gray_50
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-hover-raised: var\(--color-gray-50\)/m, self.class.compiled)
  end

  def test_color_hover_raised_dark_defaults_to_var_color_zinc_700
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-hover-raised-dark: var\(--color-zinc-700\)/m, self.class.compiled)
  end

  def test_theme_toggle_option_fill_reads_the_accent_colour_role_when_pressed
    assert_match(/\.ks-theme-toggle-option.*?aria-pressed="true".*?background-color: var\(--ks-color-accent\)/m, self.class.compiled)
  end

  def test_theme_toggle_option_fill_reads_the_accent_hover_colour_role_when_pressed_and_on_hover
    assert_match(/\.ks-theme-toggle-option.*?aria-pressed="true".*?:hover.*?background-color: var\(--ks-color-accent-hover\)/m, self.class.compiled)
  end

  def test_theme_toggle_option_fill_reads_the_accent_dark_colour_role_on_a_dark_page_and_when_pressed
    assert_match(/\.ks-theme-toggle-option.*?data-theme="dark".*?aria-pressed="true".*?background-color: var\(--ks-color-accent-dark\)/m, self.class.compiled)
  end

  def test_theme_toggle_option_fill_reads_the_accent_hover_dark_colour_role_on_a_dark_page_and_when_pressed_and_on_hover
    assert_match(/\.ks-theme-toggle-option.*?data-theme="dark".*?aria-pressed="true".*?:hover.*?background-color: var\(--ks-color-accent-hover-dark\)/m, self.class.compiled)
  end

  def test_checkbox_row_gap_is_3_spacing_units
    assert_includes rule(".ks-checkbox-row"), "gap: calc(var(--ks-spacing) * 3)"
  end

  def test_checkbox_row_padding_block_is_3_spacing_units
    assert_includes rule(".ks-checkbox-row"), "padding-block: calc(var(--ks-spacing) * 3)"
  end

  def test_checkbox_row_input_margin_top_is_0_5_spacing_units
    assert_includes rule(".ks-checkbox-row-input"), "margin-top: calc(var(--ks-spacing) * 0.5)"
  end

  def test_checkbox_row_input_radius_is_0_5_of_the_control_radius
    assert_includes rule(".ks-checkbox-row-input"), "border-radius: calc(var(--ks-radius-control) * 0.5)"
  end

  def test_checkbox_row_input_border_reads_the_border_choice_colour_role
    assert_includes rule(".ks-checkbox-row-input"), "border-color: var(--ks-color-border-choice)"
  end

  def test_checkbox_row_input_text_reads_the_accent_colour_role
    assert_includes rule(".ks-checkbox-row-input"), "color: var(--ks-color-accent)"
  end

  def test_checkbox_row_input_fill_reads_the_accent_colour_role_when_checked
    assert_match(/\&:checked.*?background-color: var\(--ks-color-accent\)/m, block(".ks-checkbox-row-input"))
  end

  def test_checkbox_row_input_ring_reads_the_focus_colour_role_on_focus
    assert_match(/\&:focus.*?--tw-ring-color: var\(--ks-color-focus\)/m, block(".ks-checkbox-row-input"))
  end

  def test_color_border_choice_defaults_to_var_color_surface_300
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-border-choice: var\(--color-surface-300\)/m, self.class.compiled)
  end

  def test_checkbox_row_label_weight_reads_the_medium_font_weight_variable
    assert_includes rule(".ks-checkbox-row-label"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_checkbox_row_label_text_reads_the_text_choice_colour_role
    assert_includes rule(".ks-checkbox-row-label"), "color: var(--ks-color-text-choice)"
  end

  def test_checkbox_row_label_text_reads_the_text_choice_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-choice-dark\)/m, block(".ks-checkbox-row-label"))
  end

  def test_color_text_choice_defaults_to_var_color_surface_900
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-choice: var\(--color-surface-900\)/m, self.class.compiled)
  end

  def test_color_text_choice_dark_defaults_to_var_color_surface_100
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-choice-dark: var\(--color-surface-100\)/m, self.class.compiled)
  end

  def test_checkbox_row_hint_margin_top_is_0_5_spacing_units
    assert_includes rule(".ks-checkbox-row-hint"), "margin-top: calc(var(--ks-spacing) * 0.5)"
  end

  def test_checkbox_row_hint_text_reads_the_text_choice_muted_colour_role
    assert_includes rule(".ks-checkbox-row-hint"), "color: var(--ks-color-text-choice-muted)"
  end

  def test_checkbox_row_hint_text_reads_the_text_choice_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-choice-muted-dark\)/m, block(".ks-checkbox-row-hint"))
  end

  def test_color_text_choice_muted_defaults_to_var_color_surface_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-choice-muted: var\(--color-surface-500\)/m, self.class.compiled)
  end

  def test_color_text_choice_muted_dark_defaults_to_var_color_surface_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-choice-muted-dark: var\(--color-surface-400\)/m, self.class.compiled)
  end

  def test_radio_card_padding_inline_is_4_spacing_units
    assert_includes rule(".ks-radio-card"), "padding-inline: calc(var(--ks-spacing) * 4)"
  end

  def test_radio_card_padding_block_is_3_spacing_units
    assert_includes rule(".ks-radio-card"), "padding-block: calc(var(--ks-spacing) * 3)"
  end

  def test_radio_card_radius_reads_the_surface_radius
    assert_includes rule(".ks-radio-card"), "border-radius: var(--ks-radius-surface)"
  end

  def test_radio_card_border_width_is_2_times_the_border_width_variable
    assert_includes rule(".ks-radio-card"), "border-width: calc(var(--ks-border-width) * 2)"
  end

  def test_radio_card_highlight_border_reads_the_border_colour_role
    assert_includes rule(".ks-radio-card-highlight"), "border-color: var(--ks-color-border)"
  end

  def test_radio_card_highlight_border_reads_the_border_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-radio-card-highlight"))
  end

  def test_radio_card_highlight_border_reads_the_selected_border_colour_role_when_its_input_is_checked
    assert_match(/:checked \~.*?border-color: var\(--ks-color-selected-border\)/m, block(".ks-radio-card-highlight"))
  end

  def test_radio_card_highlight_fill_reads_the_selected_colour_role_when_its_input_is_checked
    assert_match(/:checked \~.*?background-color: var\(--ks-color-selected\)/m, block(".ks-radio-card-highlight"))
  end

  def test_radio_card_highlight_fill_reads_the_selected_dark_colour_role_on_a_dark_page_and_when_its_input_is_checked
    assert_match(/data-theme="dark".*?:checked \~.*?background-color: var\(--ks-color-selected-dark\)/m, block(".ks-radio-card-highlight"))
  end

  def test_color_selected_border_defaults_to_var_color_accent_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-selected-border: var\(--color-accent-500\)/m, self.class.compiled)
  end

  def test_color_selected_defaults_to_var_color_accent_50
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-selected: var\(--color-accent-50\)/m, self.class.compiled)
  end

  def test_color_selected_dark_defaults_to_var_color_zinc_800
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-selected-dark: var\(--color-zinc-800\)/m, self.class.compiled)
  end

  def test_radio_card_label_weight_reads_the_medium_font_weight_variable
    assert_includes rule(".ks-radio-card-label"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_radio_card_label_text_reads_the_text_option_colour_role
    assert_includes rule(".ks-radio-card-label"), "color: var(--ks-color-text-option)"
  end

  def test_radio_card_label_text_reads_the_text_option_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-option-dark\)/m, block(".ks-radio-card-label"))
  end

  def test_color_text_option_defaults_to_var_color_gray_900
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-option: var\(--color-gray-900\)/m, self.class.compiled)
  end

  private

  def block(selector)
    self.class.compiled[/^  #{Regexp.escape(selector)} \{\n(.*?)^  \}\n/m, 1].to_s
  end

  def rule(selector)
    self.class.compiled[/^\s*#{Regexp.escape(selector)}\s*\{(.*?)\}/m, 1].to_s
  end
end
