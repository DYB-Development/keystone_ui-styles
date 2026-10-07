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
    assert_match(/:focus.*?--tw-ring-color: var\(--ks-color-focus\)/m, block(".ks-input"))
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
    assert_includes rule(".ks-required"), "color: var(--ks-color-danger-500)"
  end

  def test_hint_reads_the_muted_text_colour_role
    assert_includes rule(".ks-hint"), "color: var(--ks-color-text-muted)"
  end

  def test_error_uses_red_text
    assert_includes rule(".ks-error"), "color: var(--ks-color-danger-600)"
  end

  def test_checkbox_uses_the_accent_color
    assert_includes rule(".ks-checkbox"), "color: var(--ks-color-accent)"
  end

  def test_defines_every_surface_color_variable_even_when_no_class_uses_it
    assert_includes self.class.compiled, "--color-surface-950: #09090b"
  end

  def test_badge_classes_match_keystone_ui_badge
    assert_includes rule(".ks-badge"), "border-radius: var(--ks-radius-pill)"
    assert_includes rule(".ks-badge-neutral"), "background-color: var(--ks-color-badge-neutral)"
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
    assert_includes rule(".ks-alert-message-titled"), "margin-top: calc(var(--ks-spacing) * 1)"
    assert_includes rule(".ks-alert-dismiss"), "cursor: pointer"
    assert_match(/data-theme="dark".*? color: var\(--ks-color-info-300\)/m, block(".ks-alert-info"))
  end

  def test_card_classes_match_keystone_ui_card
    assert_includes rule(".ks-card"), "border-radius: var(--ks-radius-surface)"
    assert_includes rule(".ks-card-edge"), "border-block-width: var(--ks-border-width)"
    assert_includes rule(".ks-card-body"), "padding-inline: calc(var(--ks-spacing) * 4)"
    assert_includes rule(".ks-card-title"), "font-size: var(--text-lg)"
    assert_includes rule(".ks-card-summary"), "color: var(--ks-color-text-muted)"
    assert_includes rule(".ks-card-cta"), "padding-bottom: calc(var(--ks-spacing) * 4)"
    assert_includes rule(".ks-card-link"), "color: var(--ks-color-link)"
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-surface-dark\)/m, block(".ks-card"))
  end

  def test_section_classes_match_keystone_ui_section
    assert_includes rule(".ks-section-sm"), "margin-top: calc(var(--ks-spacing) * 4)"
    assert_includes rule(".ks-section-md"), "margin-top: calc(var(--ks-spacing) * 6)"
    assert_includes rule(".ks-section-lg"), "margin-top: calc(var(--ks-spacing) * 8)"
    assert_includes rule(".ks-section-header"), "justify-content: space-between"
    assert_includes rule(".ks-section-title"), "font-size: var(--text-lg)"
    assert_includes rule(".ks-section-subtitle"), "color: var(--ks-color-text-muted)"
    assert_includes rule(".ks-section-action"), "color: var(--ks-color-link)"
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-dark\)/m, block(".ks-section-title"))
  end

  def test_page_header_classes_match_keystone_ui_page_header
    assert_includes rule(".ks-page-header"), "margin-bottom: calc(var(--ks-spacing) * 6)"
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
    assert_includes rule(".ks-page-offset-sm"), "padding-top: calc(var(--ks-spacing) * 12)"
    assert_includes rule(".ks-page-offset-md"), "padding-top: calc(var(--ks-spacing) * 16)"
    assert_includes rule(".ks-page-offset-lg"), "padding-top: calc(var(--ks-spacing) * 20)"
    assert_includes rule(".ks-page-offset-xl"), "padding-top: calc(var(--ks-spacing) * 24)"
  end

  def test_color_surface_defaults_to_var_color_white
    assert_match(/:root \{[^}]*--ks-color-surface: var\(--color-white\)/m, self.class.compiled)
  end

  def test_color_surface_dark_defaults_to_var_color_zinc_900
    assert_match(/:root \{[^}]*--ks-color-surface-dark: var\(--color-surface-900\)/m, self.class.compiled)
  end

  def test_panel_border_reads_the_border_colour_role
    assert_includes rule(".ks-panel"), "border-color: var(--ks-color-border)"
  end

  def test_color_border_defaults_to_var_color_gray_200
    assert_match(/:root \{[^}]*--ks-color-border: var\(--color-surface-200\)/m, self.class.compiled)
  end

  def test_panel_border_reads_the_dark_border_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-panel"))
  end

  def test_color_border_dark_defaults_to_var_color_zinc_700
    assert_match(/:root \{[^}]*--ks-color-border-dark: var\(--color-surface-700\)/m, self.class.compiled)
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
    assert_match(/:root \{[^}]*--ks-color-border-control: var\(--ks-color-border-strong\)/m, self.class.compiled)
  end

  def test_input_border_reads_the_dark_control_border_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-control-dark\)/m, block(".ks-input"))
  end

  def test_color_border_control_dark_defaults_to_var_color_zinc_700
    assert_match(/:root \{[^}]*--ks-color-border-control-dark: var\(--ks-color-border-strong-dark\)/m, self.class.compiled)
  end

  def test_input_text_reads_the_text_colour_role
    assert_includes rule(".ks-input"), "color: var(--ks-color-text)"
  end

  def test_color_text_defaults_to_var_color_gray_900
    assert_match(/:root \{[^}]*--ks-color-text: var\(--color-surface-900\)/m, self.class.compiled)
  end

  def test_input_text_reads_the_dark_text_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*? color: var\(--ks-color-text-dark\)/m, block(".ks-input"))
  end

  def test_color_text_dark_defaults_to_var_color_white
    assert_match(/:root \{[^}]*--ks-color-text-dark: var\(--color-white\)/m, self.class.compiled)
  end

  def test_color_text_label_defaults_to_var_color_gray_700
    assert_match(/:root \{[^}]*--ks-color-text-label: var\(--color-surface-700\)/m, self.class.compiled)
  end

  def test_label_reads_the_dark_label_text_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*? color: var\(--ks-color-text-label-dark\)/m, block(".ks-label"))
  end

  def test_color_text_label_dark_defaults_to_var_color_gray_300
    assert_match(/:root \{[^}]*--ks-color-text-label-dark: var\(--color-surface-300\)/m, self.class.compiled)
  end

  def test_color_text_muted_defaults_to_var_color_gray_500
    assert_match(/:root \{[^}]*--ks-color-text-muted: var\(--color-surface-500\)/m, self.class.compiled)
  end

  def test_hint_reads_the_dark_muted_text_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*? color: var\(--ks-color-text-muted-dark\)/m, block(".ks-hint"))
  end

  def test_color_text_muted_dark_defaults_to_var_color_gray_400
    assert_match(/:root \{[^}]*--ks-color-text-muted-dark: var\(--color-surface-400\)/m, self.class.compiled)
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
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-overlay-dark: var\(--color-surface-800\)/m, self.class.compiled)
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
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-heading: var\(--ks-color-text\)/m, self.class.compiled)
  end

  def test_color_text_heading_dark_defaults_to_var_color_gray_200
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-heading-dark: var\(--ks-color-text-dark\)/m, self.class.compiled)
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
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-close: var\(--ks-color-icon\)/m, self.class.compiled)
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
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-hover: var\(--color-surface-50\)/m, self.class.compiled)
  end

  def test_color_hover_dark_defaults_to_var_color_zinc_800
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-hover-dark: var\(--color-surface-800\)/m, self.class.compiled)
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
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-border-strong: var\(--color-surface-300\)/m, self.class.compiled)
  end

  def test_color_border_strong_dark_defaults_to_var_color_zinc_600
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-border-strong-dark: var\(--color-surface-600\)/m, self.class.compiled)
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
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-hover-raised: var\(--ks-color-hover\)/m, self.class.compiled)
  end

  def test_color_hover_raised_dark_defaults_to_var_color_zinc_700
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-hover-raised-dark: var\(--ks-color-hover-dark\)/m, self.class.compiled)
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
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-border-choice: var\(--ks-color-border-strong\)/m, self.class.compiled)
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
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-choice: var\(--ks-color-text\)/m, self.class.compiled)
  end

  def test_color_text_choice_dark_defaults_to_var_color_surface_100
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-choice-dark: var\(--ks-color-text-dark\)/m, self.class.compiled)
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
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-choice-muted: var\(--ks-color-text-muted\)/m, self.class.compiled)
  end

  def test_color_text_choice_muted_dark_defaults_to_var_color_surface_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-choice-muted-dark: var\(--ks-color-text-muted-dark\)/m, self.class.compiled)
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
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-option: var\(--ks-color-text\)/m, self.class.compiled)
  end

  def test_color_text_option_dark_defaults_to_var_color_gray_100
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-option-dark: var\(--ks-color-text-dark\)/m, self.class.compiled)
  end

  def test_radio_card_hint_margin_top_is_1_spacing_units
    assert_includes rule(".ks-radio-card-hint"), "margin-top: calc(var(--ks-spacing) * 1)"
  end

  def test_radio_card_hint_text_reads_the_text_option_muted_colour_role
    assert_includes rule(".ks-radio-card-hint"), "color: var(--ks-color-text-option-muted)"
  end

  def test_radio_card_hint_text_reads_the_text_option_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-option-muted-dark\)/m, block(".ks-radio-card-hint"))
  end

  def test_color_text_option_muted_defaults_to_var_color_surface_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-option-muted: var\(--ks-color-text-muted\)/m, self.class.compiled)
  end

  def test_color_text_option_muted_dark_defaults_to_var_color_gray_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-option-muted-dark: var\(--ks-color-text-muted-dark\)/m, self.class.compiled)
  end

  def test_option_card_gap_is_2_spacing_units
    assert_includes rule(".ks-option-card"), "gap: calc(var(--ks-spacing) * 2)"
  end

  def test_option_card_padding_inline_is_3_spacing_units
    assert_includes rule(".ks-option-card"), "padding-inline: calc(var(--ks-spacing) * 3)"
  end

  def test_option_card_padding_block_is_2_spacing_units
    assert_includes rule(".ks-option-card"), "padding-block: calc(var(--ks-spacing) * 2)"
  end

  def test_option_card_radius_reads_the_surface_radius
    assert_includes rule(".ks-option-card"), "border-radius: var(--ks-radius-surface)"
  end

  def test_option_card_border_width_is_2_times_the_border_width_variable
    assert_includes rule(".ks-option-card"), "border-width: calc(var(--ks-border-width) * 2)"
  end

  def test_option_card_selected_border_reads_the_selected_border_colour_role
    assert_includes rule(".ks-option-card-selected"), "border-color: var(--ks-color-selected-border)"
  end

  def test_file_upload_vertical_gap_between_children_is_1_spacing_units
    assert_match(/:where\(\.ks-file-upload > :not\(:last-child\)\).*?calc\(var\(--ks-spacing\) \* 1\)/m, self.class.compiled)
  end

  def test_file_upload_drop_zone_margin_top_is_1_spacing_units
    assert_includes rule(".ks-file-upload-drop-zone"), "margin-top: calc(var(--ks-spacing) * 1)"
  end

  def test_file_upload_drop_zone_radius_is_0_75_of_the_surface_radius
    assert_includes rule(".ks-file-upload-drop-zone"), "border-radius: calc(var(--ks-radius-surface) * 0.75)"
  end

  def test_file_upload_drop_zone_border_width_is_2_times_the_border_width_variable
    assert_includes rule(".ks-file-upload-drop-zone"), "border-width: calc(var(--ks-border-width) * 2)"
  end

  def test_file_upload_drop_zone_border_is_dashed
    assert_includes rule(".ks-file-upload-drop-zone"), "border-style: dashed"
  end

  def test_file_upload_drop_zone_border_reads_the_border_strong_colour_role
    assert_includes rule(".ks-file-upload-drop-zone"), "border-color: var(--ks-color-border-strong)"
  end

  def test_file_upload_drop_zone_padding_inline_is_6_spacing_units
    assert_includes rule(".ks-file-upload-drop-zone"), "padding-inline: calc(var(--ks-spacing) * 6)"
  end

  def test_file_upload_drop_zone_padding_block_is_8_spacing_units
    assert_includes rule(".ks-file-upload-drop-zone"), "padding-block: calc(var(--ks-spacing) * 8)"
  end

  def test_file_upload_drop_zone_border_reads_the_border_strong_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-strong-dark\)/m, block(".ks-file-upload-drop-zone"))
  end

  def test_file_upload_drop_zone_active_border_reads_the_selected_border_colour_role
    assert_includes rule(".ks-file-upload-drop-zone-active"), "border-color: var(--ks-color-selected-border)"
  end

  def test_file_upload_drop_zone_active_fill_reads_the_drop_active_colour_role
    assert_includes rule(".ks-file-upload-drop-zone-active"), "background-color: var(--ks-color-drop-active)"
  end

  def test_file_upload_drop_zone_active_fill_reads_the_drop_active_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-drop-active-dark\)/m, block(".ks-file-upload-drop-zone-active"))
  end

  def test_color_drop_active_defaults_to_var_color_accent_50
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-drop-active: var\(--color-accent-50\)/m, self.class.compiled)
  end

  def test_color_drop_active_dark_defaults_to_color_mix_in_oklab_var_color_accent_900_10_transparent
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-drop-active-dark: color-mix\(in oklab, var\(--color-accent-900\) 10%, transparent\)/m, self.class.compiled)
  end

  def test_file_upload_inner_vertical_gap_between_children_is_2_spacing_units
    assert_match(/:where\(\.ks-file-upload-inner > :not\(:last-child\)\).*?calc\(var\(--ks-spacing\) \* 2\)/m, self.class.compiled)
  end

  def test_file_upload_icon_text_reads_the_icon_colour_role
    assert_includes rule(".ks-file-upload-icon"), "color: var(--ks-color-icon)"
  end

  def test_file_upload_icon_text_reads_the_icon_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-icon-dark\)/m, block(".ks-file-upload-icon"))
  end

  def test_color_icon_defaults_to_var_color_gray_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-icon: var\(--color-surface-400\)/m, self.class.compiled)
  end

  def test_color_icon_dark_defaults_to_var_color_gray_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-icon-dark: var\(--color-surface-500\)/m, self.class.compiled)
  end

  def test_file_upload_prompt_text_reads_the_text_secondary_colour_role
    assert_includes rule(".ks-file-upload-prompt"), "color: var(--ks-color-text-secondary)"
  end

  def test_file_upload_prompt_text_reads_the_text_secondary_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-secondary-dark\)/m, block(".ks-file-upload-prompt"))
  end

  def test_color_text_secondary_defaults_to_var_color_gray_600
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-secondary: var\(--color-surface-600\)/m, self.class.compiled)
  end

  def test_color_text_secondary_dark_defaults_to_var_color_gray_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-secondary-dark: var\(--color-surface-400\)/m, self.class.compiled)
  end

  def test_file_upload_browse_weight_reads_the_strong_font_weight_variable
    assert_includes rule(".ks-file-upload-browse"), "font-weight: var(--ks-font-weight-strong)"
  end

  def test_file_upload_browse_text_reads_the_link_colour_role
    assert_includes rule(".ks-file-upload-browse"), "color: var(--ks-color-link)"
  end

  def test_file_upload_browse_text_reads_the_link_hover_colour_role_on_hover
    assert_match(/:hover.*?color: var\(--ks-color-link-hover\)/m, block(".ks-file-upload-browse"))
  end

  def test_file_upload_browse_text_reads_the_link_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-link-dark\)/m, block(".ks-file-upload-browse"))
  end

  def test_file_upload_browse_text_reads_the_link_hover_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?:hover.*?color: var\(--ks-color-link-hover-dark\)/m, block(".ks-file-upload-browse"))
  end

  def test_color_link_defaults_to_var_color_accent_600
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-link: var\(--color-accent-600\)/m, self.class.compiled)
  end

  def test_color_link_dark_defaults_to_var_color_accent_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-link-dark: var\(--color-accent-400\)/m, self.class.compiled)
  end

  def test_color_link_hover_defaults_to_var_color_accent_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-link-hover: var\(--color-accent-500\)/m, self.class.compiled)
  end

  def test_color_link_hover_dark_defaults_to_var_color_accent_300
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-link-hover-dark: var\(--color-accent-300\)/m, self.class.compiled)
  end

  def test_file_upload_hint_margin_top_is_1_spacing_units
    assert_includes rule(".ks-file-upload-hint"), "margin-top: calc(var(--ks-spacing) * 1)"
  end

  def test_file_upload_hint_text_reads_the_text_muted_colour_role
    assert_includes rule(".ks-file-upload-hint"), "color: var(--ks-color-text-muted)"
  end

  def test_file_upload_hint_text_reads_the_text_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-muted-dark\)/m, block(".ks-file-upload-hint"))
  end

  def test_file_upload_file_name_margin_top_is_2_spacing_units
    assert_includes rule(".ks-file-upload-file-name"), "margin-top: calc(var(--ks-spacing) * 2)"
  end

  def test_file_upload_file_name_text_reads_the_text_label_colour_role
    assert_includes rule(".ks-file-upload-file-name"), "color: var(--ks-color-text-label)"
  end

  def test_file_upload_file_name_text_reads_the_text_label_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-label-dark\)/m, block(".ks-file-upload-file-name"))
  end

  def test_color_swatch_radius_reads_the_surface_radius
    assert_includes rule(".ks-color-swatch"), "border-radius: var(--ks-radius-surface)"
  end

  def test_color_swatch_border_width_reads_the_border_width_variable
    assert_includes rule(".ks-color-swatch"), "border-width: var(--ks-border-width)"
  end

  def test_color_swatch_border_reads_the_border_strong_colour_role
    assert_includes rule(".ks-color-swatch"), "border-color: var(--ks-color-border-strong)"
  end

  def test_color_swatch_border_reads_the_border_strong_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-strong-dark\)/m, block(".ks-color-swatch"))
  end

  def test_color_picker_panel_margin_top_is_2_spacing_units
    assert_includes rule(".ks-color-picker-panel"), "margin-top: calc(var(--ks-spacing) * 2)"
  end

  def test_color_picker_panel_padding_is_3_spacing_units
    assert_includes rule(".ks-color-picker-panel"), "padding: calc(var(--ks-spacing) * 3)"
  end

  def test_color_picker_panel_radius_reads_the_surface_radius
    assert_includes rule(".ks-color-picker-panel"), "border-radius: var(--ks-radius-surface)"
  end

  def test_color_picker_panel_shadow_reads_the_overlay_shadow_variable
    assert_includes rule(".ks-color-picker-panel"), "--tw-shadow: var(--ks-shadow-overlay)"
  end

  def test_color_picker_panel_fill_reads_the_overlay_colour_role
    assert_includes rule(".ks-color-picker-panel"), "background-color: var(--ks-color-overlay)"
  end

  def test_color_picker_panel_border_width_reads_the_border_width_variable
    assert_includes rule(".ks-color-picker-panel"), "border-width: var(--ks-border-width)"
  end

  def test_color_picker_panel_border_reads_the_border_colour_role
    assert_includes rule(".ks-color-picker-panel"), "border-color: var(--ks-color-border)"
  end

  def test_color_picker_panel_fill_reads_the_overlay_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-overlay-dark\)/m, block(".ks-color-picker-panel"))
  end

  def test_color_picker_panel_border_reads_the_border_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-color-picker-panel"))
  end

  def test_radius_pill_defaults_to_calc_infinity_1px
    assert_match(/@layer base \{.*?:root \{.*?--ks-radius-pill: calc\(infinity \* 1px\)/m, self.class.compiled)
  end

  def test_color_success_600_defaults_to_var_color_green_600
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-success-600: var\(--color-green-600\)/m, self.class.compiled)
  end

  def test_color_warning_600_defaults_to_var_color_yellow_600
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-warning-600: var\(--color-yellow-600\)/m, self.class.compiled)
  end

  def test_color_danger_600_defaults_to_var_color_red_600
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-danger-600: var\(--color-red-600\)/m, self.class.compiled)
  end

  def test_color_info_600_defaults_to_var_color_accent_600
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-info-600: var\(--color-accent-600\)/m, self.class.compiled)
  end

  def test_color_danger_500_defaults_to_var_color_red_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-danger-500: var\(--color-red-500\)/m, self.class.compiled)
  end

  def test_metric_card_radius_is_1_5_of_the_surface_radius
    assert_includes block(".ks-metric-card"), "border-radius: calc(var(--ks-radius-surface) * 1.5)"
  end

  def test_metric_card_border_width_reads_the_border_width_variable
    assert_includes block(".ks-metric-card"), "border-width: var(--ks-border-width)"
  end

  def test_metric_card_border_reads_the_border_colour_role
    assert_includes block(".ks-metric-card"), "border-color: var(--ks-color-border)"
  end

  def test_metric_card_fill_reads_the_overlay_colour_role
    assert_includes block(".ks-metric-card"), "background-color: var(--ks-color-overlay)"
  end

  def test_metric_card_padding_is_6_spacing_units
    assert_includes block(".ks-metric-card"), "padding: calc(var(--ks-spacing) * 6)"
  end

  def test_metric_card_border_reads_the_border_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-metric-card"))
  end

  def test_metric_card_fill_reads_the_overlay_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-overlay-dark\)/m, block(".ks-metric-card"))
  end

  def test_stat_card_header_gap_is_2_spacing_units
    assert_includes block(".ks-stat-card-header"), "gap: calc(var(--ks-spacing) * 2)"
  end

  def test_stat_card_label_weight_reads_the_medium_font_weight_variable
    assert_includes block(".ks-stat-card-label"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_stat_card_label_text_reads_the_text_muted_colour_role
    assert_includes block(".ks-stat-card-label"), "color: var(--ks-color-text-muted)"
  end

  def test_stat_card_label_text_reads_the_text_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-muted-dark\)/m, block(".ks-stat-card-label"))
  end

  def test_stat_card_value_margin_top_is_1_spacing_units
    assert_includes block(".ks-stat-card-value"), "margin-top: calc(var(--ks-spacing) * 1)"
  end

  def test_stat_card_value_weight_is_one_step_above_the_heading_font_weight
    assert_includes block(".ks-stat-card-value"), "font-weight: calc(var(--ks-font-weight-heading) + 100)"
  end

  def test_stat_card_suffix_text_reads_the_text_muted_colour_role
    assert_includes block(".ks-stat-card-suffix"), "color: var(--ks-color-text-muted)"
  end

  def test_stat_card_suffix_text_reads_the_text_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-muted-dark\)/m, block(".ks-stat-card-suffix"))
  end

  def test_stat_card_disclosure_margin_top_is_2_spacing_units
    assert_includes block(".ks-stat-card-disclosure"), "margin-top: calc(var(--ks-spacing) * 2)"
  end

  def test_stat_card_disclosure_radius_reads_the_surface_radius
    assert_includes block(".ks-stat-card-disclosure"), "border-radius: var(--ks-radius-surface)"
  end

  def test_stat_card_disclosure_border_width_reads_the_border_width_variable
    assert_includes block(".ks-stat-card-disclosure"), "border-width: var(--ks-border-width)"
  end

  def test_stat_card_disclosure_border_reads_the_border_colour_role
    assert_includes block(".ks-stat-card-disclosure"), "border-color: var(--ks-color-border)"
  end

  def test_stat_card_disclosure_fill_reads_the_overlay_colour_role
    assert_includes block(".ks-stat-card-disclosure"), "background-color: var(--ks-color-overlay)"
  end

  def test_stat_card_disclosure_padding_is_3_spacing_units
    assert_includes block(".ks-stat-card-disclosure"), "padding: calc(var(--ks-spacing) * 3)"
  end

  def test_stat_card_disclosure_text_reads_the_text_secondary_colour_role
    assert_includes block(".ks-stat-card-disclosure"), "color: var(--ks-color-text-secondary)"
  end

  def test_stat_card_disclosure_shadow_reads_the_overlay_shadow_variable
    assert_includes block(".ks-stat-card-disclosure"), "--tw-shadow: var(--ks-shadow-overlay)"
  end

  def test_stat_card_disclosure_border_reads_the_border_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-stat-card-disclosure"))
  end

  def test_stat_card_disclosure_fill_reads_the_overlay_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-overlay-dark\)/m, block(".ks-stat-card-disclosure"))
  end

  def test_stat_card_disclosure_text_reads_the_text_secondary_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-secondary-dark\)/m, block(".ks-stat-card-disclosure"))
  end

  def test_stat_card_disclosure_vertical_gap_between_children_is_1_spacing_units
    assert_match(/\.ks-stat-card-disclosure(?![\w-]).*?:not\(:last-child\).*?calc\(var\(--ks-spacing\) \* 1\)/m, self.class.compiled)
  end

  def test_stat_card_emphasis_weight_reads_the_medium_font_weight_variable
    assert_includes block(".ks-stat-card-emphasis"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_stat_card_emphasis_text_reads_the_text_label_colour_role
    assert_includes block(".ks-stat-card-emphasis"), "color: var(--ks-color-text-label)"
  end

  def test_stat_card_emphasis_text_reads_the_text_label_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-label-dark\)/m, block(".ks-stat-card-emphasis"))
  end

  def test_stat_card_change_margin_top_is_1_spacing_units
    assert_includes block(".ks-stat-card-change"), "margin-top: calc(var(--ks-spacing) * 1)"
  end

  def test_stat_card_change_weight_reads_the_medium_font_weight_variable
    assert_includes block(".ks-stat-card-change"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_stat_card_info_text_reads_the_close_colour_role
    assert_includes block(".ks-stat-card-info"), "color: var(--ks-color-close)"
  end

  def test_stat_card_info_text_reads_the_link_colour_role_on_hover
    assert_match(/:hover.*?color: var\(--ks-color-link\)/m, block(".ks-stat-card-info"))
  end

  def test_stat_card_info_text_reads_the_link_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?:hover.*?color: var\(--ks-color-link-dark\)/m, block(".ks-stat-card-info"))
  end

  def test_tone_neutral_text_reads_the_text_colour_role
    assert_includes block(".ks-tone-neutral"), "color: var(--ks-color-text)"
  end

  def test_tone_neutral_text_reads_the_text_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-dark\)/m, block(".ks-tone-neutral"))
  end

  def test_tone_muted_text_reads_the_text_muted_colour_role
    assert_includes block(".ks-tone-muted"), "color: var(--ks-color-text-muted)"
  end

  def test_tone_muted_text_reads_the_text_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-muted-dark\)/m, block(".ks-tone-muted"))
  end

  def test_tone_success_text_reads_the_success_600_colour_role
    assert_includes block(".ks-tone-success"), "color: var(--ks-color-success-600)"
  end

  def test_tone_success_text_reads_the_success_400_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-success-400\)/m, block(".ks-tone-success"))
  end

  def test_tone_danger_text_reads_the_danger_600_colour_role
    assert_includes block(".ks-tone-danger"), "color: var(--ks-color-danger-600)"
  end

  def test_tone_danger_text_reads_the_danger_400_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-danger-400\)/m, block(".ks-tone-danger"))
  end

  def test_tone_warning_text_reads_the_warning_600_colour_role
    assert_includes block(".ks-tone-warning"), "color: var(--ks-color-warning-600)"
  end

  def test_tone_warning_text_reads_the_warning_400_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-warning-400\)/m, block(".ks-tone-warning"))
  end

  def test_tone_info_text_reads_the_info_600_colour_role
    assert_includes block(".ks-tone-info"), "color: var(--ks-color-info-600)"
  end

  def test_tone_info_text_reads_the_info_400_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-info-400\)/m, block(".ks-tone-info"))
  end

  def test_chart_card_title_weight_reads_the_medium_font_weight_variable
    assert_includes block(".ks-chart-card-title"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_chart_card_title_text_reads_the_text_muted_colour_role
    assert_includes block(".ks-chart-card-title"), "color: var(--ks-color-text-muted)"
  end

  def test_chart_card_title_margin_bottom_is_4_spacing_units
    assert_includes block(".ks-chart-card-title"), "margin-bottom: calc(var(--ks-spacing) * 4)"
  end

  def test_chart_card_title_text_reads_the_text_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-muted-dark\)/m, block(".ks-chart-card-title"))
  end

  def test_link_card_radius_reads_the_surface_radius
    assert_includes block(".ks-link-card"), "border-radius: var(--ks-radius-surface)"
  end

  def test_link_card_border_width_reads_the_border_width_variable
    assert_includes block(".ks-link-card"), "border-width: var(--ks-border-width)"
  end

  def test_link_card_border_reads_the_border_colour_role
    assert_includes block(".ks-link-card"), "border-color: var(--ks-color-border)"
  end

  def test_link_card_fill_reads_the_surface_colour_role
    assert_includes block(".ks-link-card"), "background-color: var(--ks-color-surface)"
  end

  def test_link_card_border_reads_the_hover_border_colour_role_on_hover
    assert_match(/:hover.*?border-color: var\(--ks-color-hover-border\)/m, block(".ks-link-card"))
  end

  def test_link_card_border_reads_the_border_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-link-card"))
  end

  def test_link_card_fill_reads_the_surface_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-surface-dark\)/m, block(".ks-link-card"))
  end

  def test_color_hover_border_defaults_to_color_mix_in_oklab_var_color_accent_500_50_transparent
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-hover-border: color-mix\(in oklab, var\(--color-accent-500\) 50%, transparent\)/m, self.class.compiled)
  end

  def test_link_card_shadow_shadow_reads_the_surface_shadow_variable
    assert_includes block(".ks-link-card-shadow"), "--tw-shadow: var(--ks-shadow-surface)"
  end

  def test_link_card_padding_sm_padding_is_3_spacing_units
    assert_includes block(".ks-link-card-padding-sm"), "padding: calc(var(--ks-spacing) * 3)"
  end

  def test_link_card_padding_md_padding_is_4_spacing_units
    assert_includes block(".ks-link-card-padding-md"), "padding: calc(var(--ks-spacing) * 4)"
  end

  def test_link_card_padding_lg_padding_is_6_spacing_units
    assert_includes block(".ks-link-card-padding-lg"), "padding: calc(var(--ks-spacing) * 6)"
  end

  def test_cta_banner_radius_is_2_of_the_surface_radius
    assert_includes block(".ks-cta-banner"), "border-radius: calc(var(--ks-radius-surface) * 2)"
  end

  def test_cta_banner_border_width_reads_the_border_width_variable
    assert_includes block(".ks-cta-banner"), "border-width: var(--ks-border-width)"
  end

  def test_cta_banner_padding_inline_is_6_spacing_units
    assert_includes block(".ks-cta-banner"), "padding-inline: calc(var(--ks-spacing) * 6)"
  end

  def test_cta_banner_padding_block_is_12_spacing_units
    assert_includes block(".ks-cta-banner"), "padding-block: calc(var(--ks-spacing) * 12)"
  end

  def test_cta_banner_border_reads_the_border_subtle_colour_role
    assert_includes block(".ks-cta-banner"), "border-color: var(--ks-color-border-subtle)"
  end

  def test_cta_banner_fill_reads_the_fill_muted_colour_role
    assert_includes block(".ks-cta-banner"), "background-color: var(--ks-color-fill-muted)"
  end

  def test_cta_banner_padding_inline_is_16_spacing_units_on_large_screens
    assert_match(/width >= 64rem.*?padding-inline: calc\(var\(--ks-spacing\) \* 16\)/m, block(".ks-cta-banner"))
  end

  def test_cta_banner_padding_block_is_16_spacing_units_on_large_screens
    assert_match(/width >= 64rem.*?padding-block: calc\(var\(--ks-spacing\) \* 16\)/m, block(".ks-cta-banner"))
  end

  def test_cta_banner_border_reads_the_border_subtle_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-subtle-dark\)/m, block(".ks-cta-banner"))
  end

  def test_cta_banner_fill_reads_the_fill_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-fill-muted-dark\)/m, block(".ks-cta-banner"))
  end

  def test_color_border_subtle_defaults_to_var_color_surface_200
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-border-subtle: var\(--ks-color-border\)/m, self.class.compiled)
  end

  def test_color_border_subtle_dark_defaults_to_var_color_surface_700
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-border-subtle-dark: var\(--ks-color-border-dark\)/m, self.class.compiled)
  end

  def test_color_fill_muted_defaults_to_var_color_surface_50
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-fill-muted: var\(--ks-color-hover\)/m, self.class.compiled)
  end

  def test_color_fill_muted_dark_defaults_to_var_color_surface_800
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-fill-muted-dark: var\(--ks-color-hover-dark\)/m, self.class.compiled)
  end

  def test_cta_banner_title_margin_bottom_is_4_spacing_units
    assert_includes block(".ks-cta-banner-title"), "margin-bottom: calc(var(--ks-spacing) * 4)"
  end

  def test_cta_banner_title_weight_is_one_step_above_the_heading_font_weight
    assert_includes block(".ks-cta-banner-title"), "font-weight: calc(var(--ks-font-weight-heading) + 100)"
  end

  def test_cta_banner_title_text_reads_the_text_display_colour_role
    assert_includes block(".ks-cta-banner-title"), "color: var(--ks-color-text-display)"
  end

  def test_cta_banner_title_text_reads_the_text_display_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-display-dark\)/m, block(".ks-cta-banner-title"))
  end

  def test_color_text_display_defaults_to_var_color_surface_900
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-display: var\(--ks-color-text\)/m, self.class.compiled)
  end

  def test_color_text_display_dark_defaults_to_var_color_white
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-display-dark: var\(--ks-color-text-dark\)/m, self.class.compiled)
  end

  def test_cta_banner_subtitle_margin_bottom_is_8_spacing_units
    assert_includes block(".ks-cta-banner-subtitle"), "margin-bottom: calc(var(--ks-spacing) * 8)"
  end

  def test_cta_banner_subtitle_text_reads_the_text_display_muted_colour_role
    assert_includes block(".ks-cta-banner-subtitle"), "color: var(--ks-color-text-display-muted)"
  end

  def test_cta_banner_subtitle_text_reads_the_text_display_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-display-muted-dark\)/m, block(".ks-cta-banner-subtitle"))
  end

  def test_color_text_display_muted_defaults_to_var_color_surface_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-display-muted: var\(--ks-color-text-muted\)/m, self.class.compiled)
  end

  def test_color_text_display_muted_dark_defaults_to_var_color_surface_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-display-muted-dark: var\(--ks-color-text-muted-dark\)/m, self.class.compiled)
  end

  def test_cta_banner_actions_gap_is_4_spacing_units
    assert_includes block(".ks-cta-banner-actions"), "gap: calc(var(--ks-spacing) * 4)"
  end

  def test_feature_grid_gap_is_6_spacing_units
    assert_includes block(".ks-feature-grid"), "gap: calc(var(--ks-spacing) * 6)"
  end

  def test_feature_grid_title_margin_bottom_is_4_spacing_units
    assert_includes block(".ks-feature-grid-title"), "margin-bottom: calc(var(--ks-spacing) * 4)"
  end

  def test_feature_grid_title_weight_is_one_step_above_the_heading_font_weight
    assert_includes block(".ks-feature-grid-title"), "font-weight: calc(var(--ks-font-weight-heading) + 100)"
  end

  def test_feature_grid_title_text_reads_the_text_display_colour_role
    assert_includes block(".ks-feature-grid-title"), "color: var(--ks-color-text-display)"
  end

  def test_feature_grid_title_text_reads_the_text_display_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-display-dark\)/m, block(".ks-feature-grid-title"))
  end

  def test_feature_grid_subtitle_margin_bottom_is_16_spacing_units
    assert_includes block(".ks-feature-grid-subtitle"), "margin-bottom: calc(var(--ks-spacing) * 16)"
  end

  def test_feature_grid_subtitle_text_reads_the_text_display_muted_colour_role
    assert_includes block(".ks-feature-grid-subtitle"), "color: var(--ks-color-text-display-muted)"
  end

  def test_feature_grid_subtitle_text_reads_the_text_display_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-display-muted-dark\)/m, block(".ks-feature-grid-subtitle"))
  end

  def test_feature_card_radius_is_1_5_of_the_surface_radius
    assert_includes block(".ks-feature-card"), "border-radius: calc(var(--ks-radius-surface) * 1.5)"
  end

  def test_feature_card_border_width_reads_the_border_width_variable
    assert_includes block(".ks-feature-card"), "border-width: var(--ks-border-width)"
  end

  def test_feature_card_padding_is_6_spacing_units
    assert_includes block(".ks-feature-card"), "padding: calc(var(--ks-spacing) * 6)"
  end

  def test_feature_card_border_reads_the_border_subtle_colour_role
    assert_includes block(".ks-feature-card"), "border-color: var(--ks-color-border-subtle)"
  end

  def test_feature_card_fill_reads_the_raised_colour_role
    assert_includes block(".ks-feature-card"), "background-color: var(--ks-color-raised)"
  end

  def test_feature_card_border_reads_the_hover_border_colour_role_on_hover
    assert_match(/:hover.*?border-color: var\(--ks-color-hover-border\)/m, block(".ks-feature-card"))
  end

  def test_feature_card_border_reads_the_border_subtle_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-subtle-dark\)/m, block(".ks-feature-card"))
  end

  def test_feature_card_fill_reads_the_raised_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-raised-dark\)/m, block(".ks-feature-card"))
  end

  def test_color_raised_defaults_to_var_color_white
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-raised: var\(--ks-color-overlay\)/m, self.class.compiled)
  end

  def test_color_raised_dark_defaults_to_var_color_surface_800
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-raised-dark: var\(--ks-color-overlay-dark\)/m, self.class.compiled)
  end

  def test_feature_card_icon_margin_bottom_is_4_spacing_units
    assert_includes block(".ks-feature-card-icon"), "margin-bottom: calc(var(--ks-spacing) * 4)"
  end

  def test_feature_card_icon_radius_reads_the_surface_radius
    assert_includes block(".ks-feature-card-icon"), "border-radius: var(--ks-radius-surface)"
  end

  def test_feature_card_icon_fill_reads_the_tint_colour_role
    assert_includes block(".ks-feature-card-icon"), "background-color: var(--ks-color-tint)"
  end

  def test_feature_card_icon_text_reads_the_link_colour_role
    assert_includes block(".ks-feature-card-icon"), "color: var(--ks-color-link)"
  end

  def test_feature_card_icon_text_reads_the_link_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-link-dark\)/m, block(".ks-feature-card-icon"))
  end

  def test_color_tint_defaults_to_color_mix_in_oklab_var_color_accent_500_10_transparent
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-tint: color-mix\(in oklab, var\(--color-accent-500\) 10%, transparent\)/m, self.class.compiled)
  end

  def test_feature_card_title_margin_bottom_is_2_spacing_units
    assert_includes block(".ks-feature-card-title"), "margin-bottom: calc(var(--ks-spacing) * 2)"
  end

  def test_feature_card_title_weight_reads_the_heading_font_weight_variable
    assert_includes block(".ks-feature-card-title"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_feature_card_title_text_reads_the_text_display_colour_role
    assert_includes block(".ks-feature-card-title"), "color: var(--ks-color-text-display)"
  end

  def test_feature_card_title_text_reads_the_text_display_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-display-dark\)/m, block(".ks-feature-card-title"))
  end

  def test_feature_card_description_text_reads_the_text_display_muted_colour_role
    assert_includes block(".ks-feature-card-description"), "color: var(--ks-color-text-display-muted)"
  end

  def test_feature_card_description_text_reads_the_text_display_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-display-muted-dark\)/m, block(".ks-feature-card-description"))
  end

  def test_hero_padding_top_is_24_spacing_units
    assert_includes block(".ks-hero"), "padding-top: calc(var(--ks-spacing) * 24)"
  end

  def test_hero_inner_padding_inline_is_6_spacing_units
    assert_includes block(".ks-hero-inner"), "padding-inline: calc(var(--ks-spacing) * 6)"
  end

  def test_hero_inner_padding_block_is_24_spacing_units
    assert_includes block(".ks-hero-inner"), "padding-block: calc(var(--ks-spacing) * 24)"
  end

  def test_hero_inner_padding_block_is_32_spacing_units_on_large_screens
    assert_match(/width >= 64rem.*?padding-block: calc\(var\(--ks-spacing\) \* 32\)/m, block(".ks-hero-inner"))
  end

  def test_hero_content_gap_is_8_spacing_units
    assert_includes block(".ks-hero-content"), "gap: calc(var(--ks-spacing) * 8)"
  end

  def test_hero_split_gap_is_12_spacing_units
    assert_includes block(".ks-hero-split"), "gap: calc(var(--ks-spacing) * 12)"
  end

  def test_hero_split_gap_is_16_spacing_units_on_large_screens
    assert_match(/width >= 64rem.*?gap: calc\(var\(--ks-spacing\) \* 16\)/m, block(".ks-hero-split"))
  end

  def test_hero_title_weight_is_one_step_above_the_heading_font_weight
    assert_includes block(".ks-hero-title"), "font-weight: calc(var(--ks-font-weight-heading) + 100)"
  end

  def test_hero_title_text_reads_the_text_display_colour_role
    assert_includes block(".ks-hero-title"), "color: var(--ks-color-text-display)"
  end

  def test_hero_title_text_reads_the_text_display_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-display-dark\)/m, block(".ks-hero-title"))
  end

  def test_hero_subtitle_text_reads_the_text_display_muted_colour_role
    assert_includes block(".ks-hero-subtitle"), "color: var(--ks-color-text-display-muted)"
  end

  def test_hero_subtitle_text_reads_the_text_display_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-display-muted-dark\)/m, block(".ks-hero-subtitle"))
  end

  def test_hero_badge_gap_is_2_spacing_units
    assert_includes block(".ks-hero-badge"), "gap: calc(var(--ks-spacing) * 2)"
  end

  def test_hero_badge_radius_reads_the_pill_radius
    assert_includes block(".ks-hero-badge"), "border-radius: var(--ks-radius-pill)"
  end

  def test_hero_badge_border_width_reads_the_border_width_variable
    assert_includes block(".ks-hero-badge"), "border-width: var(--ks-border-width)"
  end

  def test_hero_badge_padding_inline_is_4_spacing_units
    assert_includes block(".ks-hero-badge"), "padding-inline: calc(var(--ks-spacing) * 4)"
  end

  def test_hero_badge_padding_block_is_1_5_spacing_units
    assert_includes block(".ks-hero-badge"), "padding-block: calc(var(--ks-spacing) * 1.5)"
  end

  def test_hero_badge_border_reads_the_tint_border_colour_role
    assert_includes block(".ks-hero-badge"), "border-color: var(--ks-color-tint-border)"
  end

  def test_hero_badge_fill_reads_the_tint_colour_role
    assert_includes block(".ks-hero-badge"), "background-color: var(--ks-color-tint)"
  end

  def test_hero_badge_text_reads_the_link_colour_role
    assert_includes block(".ks-hero-badge"), "color: var(--ks-color-link)"
  end

  def test_hero_badge_text_reads_the_link_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-link-dark\)/m, block(".ks-hero-badge"))
  end

  def test_color_tint_border_defaults_to_color_mix_in_oklab_var_color_accent_500_20_transparent
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-tint-border: color-mix\(in oklab, var\(--color-accent-500\) 20%, transparent\)/m, self.class.compiled)
  end

  def test_hero_actions_gap_is_4_spacing_units
    assert_includes block(".ks-hero-actions"), "gap: calc(var(--ks-spacing) * 4)"
  end

  def test_table_radius_reads_the_surface_radius
    assert_includes block(".ks-table"), "border-radius: var(--ks-radius-surface)"
  end

  def test_table_border_width_reads_the_border_width_variable
    assert_includes block(".ks-table"), "border-width: var(--ks-border-width)"
  end

  def test_table_border_reads_the_border_colour_role
    assert_includes block(".ks-table"), "border-color: var(--ks-color-border)"
  end

  def test_table_shadow_reads_the_surface_shadow_variable
    assert_includes block(".ks-table"), "--tw-shadow: var(--ks-shadow-surface)"
  end

  def test_table_border_reads_the_border_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-table"))
  end

  def test_table_shadow_reads_the_surface_dark_shadow_variable_on_a_dark_page
    assert_match(/data-theme="dark".*?--tw-shadow: var\(--ks-shadow-surface-dark\)/m, block(".ks-table"))
  end

  def test_shadow_surface_dark_defaults_to_0_0_0000
    assert_match(/@layer base \{.*?:root \{.*?--ks-shadow-surface-dark: 0 0 #0000/m, self.class.compiled)
  end

  def test_table_head_fill_reads_the_table_head_colour_role
    assert_includes block(".ks-table-head"), "background-color: var(--ks-color-table-head)"
  end

  def test_table_head_fill_reads_the_table_head_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-table-head-dark\)/m, block(".ks-table-head"))
  end

  def test_color_table_head_defaults_to_var_color_gray_50
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-table-head: var\(--ks-color-hover\)/m, self.class.compiled)
  end

  def test_color_table_head_dark_defaults_to_color_mix_in_oklab_var_color_gray_800_75_transparent
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-table-head-dark: var\(--ks-color-hover-dark\)/m, self.class.compiled)
  end

  def test_table_body_fill_reads_the_table_body_colour_role
    assert_includes block(".ks-table-body"), "background-color: var(--ks-color-table-body)"
  end

  def test_table_body_row_dividers_read_the_border_width_variable
    assert_match(/\.ks-table-body(?![\w-]).*?:not\(:last-child\).*?border-bottom-width: calc\(var\(--ks-border-width\) \* calc\(1 - var\(--tw-divide-y-reverse\)\)\)/m, self.class.compiled)
  end

  def test_table_body_divider_reads_the_divider_colour_role
    assert_includes block(".ks-table-body"), "border-color: var(--ks-color-divider)"
  end

  def test_table_body_fill_reads_the_table_body_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-table-body-dark\)/m, block(".ks-table-body"))
  end

  def test_table_body_divider_reads_the_divider_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-divider-dark\)/m, block(".ks-table-body"))
  end

  def test_color_table_body_defaults_to_var_color_white
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-table-body: var\(--ks-color-surface\)/m, self.class.compiled)
  end

  def test_color_table_body_dark_defaults_to_color_mix_in_oklab_var_color_gray_800_50_transparent
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-table-body-dark: var\(--ks-color-surface-dark\)/m, self.class.compiled)
  end

  def test_color_divider_defaults_to_var_color_gray_200
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-divider: var\(--ks-color-border\)/m, self.class.compiled)
  end

  def test_color_divider_dark_defaults_to_color_mix_in_oklab_var_color_white_10_transparent
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-divider-dark: var\(--ks-color-border-dark\)/m, self.class.compiled)
  end

  def test_table_header_padding_block_is_3_5_spacing_units
    assert_includes block(".ks-table-header"), "padding-block: calc(var(--ks-spacing) * 3.5)"
  end

  def test_table_header_weight_reads_the_heading_font_weight_variable
    assert_includes block(".ks-table-header"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_table_header_text_reads_the_text_heading_colour_role
    assert_includes block(".ks-table-header"), "color: var(--ks-color-text-heading)"
  end

  def test_table_header_text_reads_the_text_heading_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-heading-dark\)/m, block(".ks-table-header"))
  end

  def test_table_header_first_padding_right_is_3_spacing_units
    assert_includes block(".ks-table-header-first"), "padding-right: calc(var(--ks-spacing) * 3)"
  end

  def test_table_header_first_padding_left_is_6_spacing_units
    assert_includes block(".ks-table-header-first"), "padding-left: calc(var(--ks-spacing) * 6)"
  end

  def test_table_header_middle_padding_inline_is_3_spacing_units
    assert_includes block(".ks-table-header-middle"), "padding-inline: calc(var(--ks-spacing) * 3)"
  end

  def test_table_header_last_padding_block_is_3_5_spacing_units
    assert_includes block(".ks-table-header-last"), "padding-block: calc(var(--ks-spacing) * 3.5)"
  end

  def test_table_header_last_padding_right_is_6_spacing_units
    assert_includes block(".ks-table-header-last"), "padding-right: calc(var(--ks-spacing) * 6)"
  end

  def test_table_header_last_padding_left_is_3_spacing_units
    assert_includes block(".ks-table-header-last"), "padding-left: calc(var(--ks-spacing) * 3)"
  end

  def test_table_cell_first_padding_block_is_4_spacing_units
    assert_includes block(".ks-table-cell-first"), "padding-block: calc(var(--ks-spacing) * 4)"
  end

  def test_table_cell_first_padding_right_is_3_spacing_units
    assert_includes block(".ks-table-cell-first"), "padding-right: calc(var(--ks-spacing) * 3)"
  end

  def test_table_cell_first_padding_left_is_6_spacing_units
    assert_includes block(".ks-table-cell-first"), "padding-left: calc(var(--ks-spacing) * 6)"
  end

  def test_table_cell_first_weight_reads_the_medium_font_weight_variable
    assert_includes block(".ks-table-cell-first"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_table_cell_first_text_reads_the_text_colour_role
    assert_includes block(".ks-table-cell-first"), "color: var(--ks-color-text)"
  end

  def test_table_cell_first_text_reads_the_text_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-dark\)/m, block(".ks-table-cell-first"))
  end

  def test_table_cell_middle_padding_inline_is_3_spacing_units
    assert_includes block(".ks-table-cell-middle"), "padding-inline: calc(var(--ks-spacing) * 3)"
  end

  def test_table_cell_middle_padding_block_is_4_spacing_units
    assert_includes block(".ks-table-cell-middle"), "padding-block: calc(var(--ks-spacing) * 4)"
  end

  def test_table_cell_middle_text_reads_the_text_muted_colour_role
    assert_includes block(".ks-table-cell-middle"), "color: var(--ks-color-text-muted)"
  end

  def test_table_cell_middle_text_reads_the_text_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-muted-dark\)/m, block(".ks-table-cell-middle"))
  end

  def test_table_cell_last_padding_block_is_4_spacing_units
    assert_includes block(".ks-table-cell-last"), "padding-block: calc(var(--ks-spacing) * 4)"
  end

  def test_table_cell_last_padding_right_is_6_spacing_units
    assert_includes block(".ks-table-cell-last"), "padding-right: calc(var(--ks-spacing) * 6)"
  end

  def test_table_cell_last_padding_left_is_3_spacing_units
    assert_includes block(".ks-table-cell-last"), "padding-left: calc(var(--ks-spacing) * 3)"
  end

  def test_table_cell_last_weight_reads_the_medium_font_weight_variable
    assert_includes block(".ks-table-cell-last"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_table_sort_link_gap_is_1_spacing_units
    assert_includes block(".ks-table-sort-link"), "gap: calc(var(--ks-spacing) * 1)"
  end

  def test_table_sort_icon_active_text_reads_the_text_label_colour_role
    assert_includes block(".ks-table-sort-icon-active"), "color: var(--ks-color-text-label)"
  end

  def test_table_sort_icon_active_text_reads_the_text_label_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-label-dark\)/m, block(".ks-table-sort-icon-active"))
  end

  def test_table_sort_icon_text_reads_the_icon_colour_role
    assert_includes block(".ks-table-sort-icon"), "color: var(--ks-color-icon)"
  end

  def test_table_sort_icon_text_reads_the_icon_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-icon-dark\)/m, block(".ks-table-sort-icon"))
  end

  def test_code_radius_reads_the_surface_radius
    assert_includes block(".ks-code"), "border-radius: var(--ks-radius-surface)"
  end

  def test_code_border_width_reads_the_border_width_variable
    assert_includes block(".ks-code"), "border-width: var(--ks-border-width)"
  end

  def test_code_border_reads_the_border_subtle_colour_role
    assert_includes block(".ks-code"), "border-color: var(--ks-color-border-subtle)"
  end

  def test_code_border_reads_the_border_subtle_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-subtle-dark\)/m, block(".ks-code"))
  end

  def test_code_caption_bottom_border_width_reads_the_border_width_variable
    assert_includes block(".ks-code-caption"), "border-bottom-width: var(--ks-border-width)"
  end

  def test_code_caption_border_reads_the_border_subtle_colour_role
    assert_includes block(".ks-code-caption"), "border-color: var(--ks-color-border-subtle)"
  end

  def test_code_caption_fill_reads_the_fill_muted_colour_role
    assert_includes block(".ks-code-caption"), "background-color: var(--ks-color-fill-muted)"
  end

  def test_code_caption_padding_inline_is_4_spacing_units
    assert_includes block(".ks-code-caption"), "padding-inline: calc(var(--ks-spacing) * 4)"
  end

  def test_code_caption_padding_block_is_2_spacing_units
    assert_includes block(".ks-code-caption"), "padding-block: calc(var(--ks-spacing) * 2)"
  end

  def test_code_caption_text_reads_the_text_display_muted_colour_role
    assert_includes block(".ks-code-caption"), "color: var(--ks-color-text-display-muted)"
  end

  def test_code_caption_border_reads_the_border_subtle_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-subtle-dark\)/m, block(".ks-code-caption"))
  end

  def test_code_caption_fill_reads_the_fill_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-fill-muted-dark\)/m, block(".ks-code-caption"))
  end

  def test_code_caption_text_reads_the_text_display_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-display-muted-dark\)/m, block(".ks-code-caption"))
  end

  def test_code_block_fill_reads_the_code_colour_role
    assert_includes block(".ks-code-block"), "background-color: var(--ks-color-code)"
  end

  def test_code_block_padding_is_4_spacing_units
    assert_includes block(".ks-code-block"), "padding: calc(var(--ks-spacing) * 4)"
  end

  def test_code_block_text_reads_the_text_code_colour_role
    assert_includes block(".ks-code-block"), "color: var(--ks-color-text-code)"
  end

  def test_code_block_fill_reads_the_code_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-code-dark\)/m, block(".ks-code-block"))
  end

  def test_color_code_defaults_to_var_color_surface_900
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-code: var\(--color-surface-900\)/m, self.class.compiled)
  end

  def test_color_code_dark_defaults_to_var_color_black
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-code-dark: var\(--color-black\)/m, self.class.compiled)
  end

  def test_color_text_code_defaults_to_var_color_surface_100
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-code: var\(--color-surface-100\)/m, self.class.compiled)
  end

  def test_accordion_gap_is_4_spacing_units
    assert_includes block(".ks-accordion"), "gap: calc(var(--ks-spacing) * 4)"
  end

  def test_accordion_item_radius_is_1_5_of_the_surface_radius
    assert_includes block(".ks-accordion-item"), "border-radius: calc(var(--ks-radius-surface) * 1.5)"
  end

  def test_accordion_item_border_width_reads_the_border_width_variable
    assert_includes block(".ks-accordion-item"), "border-width: var(--ks-border-width)"
  end

  def test_accordion_item_border_reads_the_border_subtle_colour_role
    assert_includes block(".ks-accordion-item"), "border-color: var(--ks-color-border-subtle)"
  end

  def test_accordion_item_border_reads_the_border_subtle_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-subtle-dark\)/m, block(".ks-accordion-item"))
  end

  def test_disclosure_radius_is_1_5_of_the_surface_radius
    assert_includes block(".ks-disclosure"), "border-radius: calc(var(--ks-radius-surface) * 1.5)"
  end

  def test_disclosure_border_width_reads_the_border_width_variable
    assert_includes block(".ks-disclosure"), "border-width: var(--ks-border-width)"
  end

  def test_disclosure_border_reads_the_border_subtle_colour_role
    assert_includes block(".ks-disclosure"), "border-color: var(--ks-color-border-subtle)"
  end

  def test_disclosure_border_reads_the_border_subtle_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-subtle-dark\)/m, block(".ks-disclosure"))
  end

  def test_accordion_button_padding_inline_is_6_spacing_units
    assert_includes block(".ks-accordion-button"), "padding-inline: calc(var(--ks-spacing) * 6)"
  end

  def test_accordion_button_padding_block_is_4_spacing_units
    assert_includes block(".ks-accordion-button"), "padding-block: calc(var(--ks-spacing) * 4)"
  end

  def test_accordion_button_weight_reads_the_heading_font_weight_variable
    assert_includes block(".ks-accordion-button"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_accordion_button_text_reads_the_text_display_colour_role
    assert_includes block(".ks-accordion-button"), "color: var(--ks-color-text-display)"
  end

  def test_accordion_button_text_reads_the_link_colour_role_on_hover
    assert_match(/:hover.*?color: var\(--ks-color-link\)/m, block(".ks-accordion-button"))
  end

  def test_accordion_button_text_reads_the_text_display_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-display-dark\)/m, block(".ks-accordion-button"))
  end

  def test_accordion_button_text_reads_the_link_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?:hover.*?color: var\(--ks-color-link-dark\)/m, block(".ks-accordion-button"))
  end

  def test_disclosure_summary_gap_is_4_spacing_units
    assert_includes block(".ks-disclosure-summary"), "gap: calc(var(--ks-spacing) * 4)"
  end

  def test_disclosure_summary_padding_inline_is_6_spacing_units
    assert_includes block(".ks-disclosure-summary"), "padding-inline: calc(var(--ks-spacing) * 6)"
  end

  def test_disclosure_summary_padding_block_is_4_spacing_units
    assert_includes block(".ks-disclosure-summary"), "padding-block: calc(var(--ks-spacing) * 4)"
  end

  def test_disclosure_summary_weight_reads_the_heading_font_weight_variable
    assert_includes block(".ks-disclosure-summary"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_disclosure_summary_text_reads_the_text_display_colour_role
    assert_includes block(".ks-disclosure-summary"), "color: var(--ks-color-text-display)"
  end

  def test_disclosure_summary_text_reads_the_text_display_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-display-dark\)/m, block(".ks-disclosure-summary"))
  end

  def test_accordion_answer_padding_inline_is_6_spacing_units
    assert_includes block(".ks-accordion-answer"), "padding-inline: calc(var(--ks-spacing) * 6)"
  end

  def test_accordion_answer_padding_bottom_is_4_spacing_units
    assert_includes block(".ks-accordion-answer"), "padding-bottom: calc(var(--ks-spacing) * 4)"
  end

  def test_accordion_answer_text_reads_the_text_body_colour_role
    assert_includes block(".ks-accordion-answer"), "color: var(--ks-color-text-body)"
  end

  def test_accordion_answer_text_reads_the_text_body_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-body-dark\)/m, block(".ks-accordion-answer"))
  end

  def test_disclosure_body_padding_inline_is_6_spacing_units
    assert_includes block(".ks-disclosure-body"), "padding-inline: calc(var(--ks-spacing) * 6)"
  end

  def test_disclosure_body_padding_bottom_is_4_spacing_units
    assert_includes block(".ks-disclosure-body"), "padding-bottom: calc(var(--ks-spacing) * 4)"
  end

  def test_disclosure_body_text_reads_the_text_body_colour_role
    assert_includes block(".ks-disclosure-body"), "color: var(--ks-color-text-body)"
  end

  def test_disclosure_body_text_reads_the_text_body_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-body-dark\)/m, block(".ks-disclosure-body"))
  end

  def test_color_text_body_defaults_to_var_color_surface_600
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-body: var\(--ks-color-text-secondary\)/m, self.class.compiled)
  end

  def test_color_text_body_dark_defaults_to_var_color_surface_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-body-dark: var\(--ks-color-text-secondary-dark\)/m, self.class.compiled)
  end

  def test_disclosure_icon_text_reads_the_icon_soft_colour_role
    assert_includes block(".ks-disclosure-icon"), "color: var(--ks-color-icon-soft)"
  end

  def test_color_icon_soft_defaults_to_var_color_surface_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-icon-soft: var\(--ks-color-icon\)/m, self.class.compiled)
  end

  def test_tab_bar_margin_bottom_is_8_spacing_units
    assert_includes block(".ks-tab-bar"), "margin-bottom: calc(var(--ks-spacing) * 8)"
  end

  def test_tab_bar_gap_is_2_spacing_units
    assert_includes block(".ks-tab-bar"), "gap: calc(var(--ks-spacing) * 2)"
  end

  def test_tab_radius_reads_the_surface_radius
    assert_includes block(".ks-tab"), "border-radius: var(--ks-radius-surface)"
  end

  def test_tab_padding_inline_is_4_spacing_units
    assert_includes block(".ks-tab"), "padding-inline: calc(var(--ks-spacing) * 4)"
  end

  def test_tab_padding_block_is_2_spacing_units
    assert_includes block(".ks-tab"), "padding-block: calc(var(--ks-spacing) * 2)"
  end

  def test_tab_weight_reads_the_heading_font_weight_variable
    assert_includes block(".ks-tab"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_tab_text_reads_the_text_muted_colour_role
    assert_includes block(".ks-tab"), "color: var(--ks-color-text-muted)"
  end

  def test_tab_text_reads_the_text_colour_role_on_hover
    assert_match(/:hover.*?color: var\(--ks-color-text\)/m, block(".ks-tab"))
  end

  def test_tab_text_reads_the_text_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-muted-dark\)/m, block(".ks-tab"))
  end

  def test_tab_text_reads_the_text_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?:hover.*?color: var\(--ks-color-text-dark\)/m, block(".ks-tab"))
  end

  def test_tab_active_fill_reads_the_tint_colour_role_when_active
    assert_match(/\.ks-tab-active(?![\w-]).*?\[data-active\].*?background-color: var\(--ks-color-tint\)/m, self.class.compiled)
  end

  def test_tab_active_text_reads_the_link_colour_role_when_active
    assert_match(/\.ks-tab-active(?![\w-]).*?\[data-active\].*?color: var\(--ks-color-link\)/m, self.class.compiled)
  end

  def test_tab_active_text_reads_the_link_dark_colour_role_on_a_dark_page_and_when_active
    assert_match(/\.ks-tab-active(?![\w-]).*?data-theme="dark".*?\[data-active\].*?color: var\(--ks-color-link-dark\)/m, self.class.compiled)
  end

  def test_progress_track_fill_reads_the_track_colour_role
    assert_includes block(".ks-progress-track"), "background-color: var(--ks-color-track)"
  end

  def test_progress_track_radius_reads_the_pill_radius
    assert_includes block(".ks-progress-track"), "border-radius: var(--ks-radius-pill)"
  end

  def test_progress_track_fill_reads_the_track_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-track-dark\)/m, block(".ks-progress-track"))
  end

  def test_color_track_defaults_to_var_color_surface_200
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-track: var\(--ks-color-border\)/m, self.class.compiled)
  end

  def test_color_track_dark_defaults_to_var_color_surface_700
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-track-dark: var\(--ks-color-border-dark\)/m, self.class.compiled)
  end

  def test_progress_bar_fill_reads_the_meter_colour_role
    assert_includes block(".ks-progress-bar"), "background-color: var(--ks-color-meter)"
  end

  def test_progress_bar_radius_reads_the_pill_radius
    assert_includes block(".ks-progress-bar"), "border-radius: var(--ks-radius-pill)"
  end

  def test_color_meter_defaults_to_var_color_accent_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-meter: var\(--color-accent-500\)/m, self.class.compiled)
  end

  def test_meter_label_margin_bottom_is_1_spacing_units
    assert_includes block(".ks-meter-label"), "margin-bottom: calc(var(--ks-spacing) * 1)"
  end

  def test_meter_label_weight_reads_the_medium_font_weight_variable
    assert_includes block(".ks-meter-label"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_meter_label_text_reads_the_text_meter_label_colour_role
    assert_includes block(".ks-meter-label"), "color: var(--ks-color-text-meter-label)"
  end

  def test_meter_label_text_reads_the_text_meter_label_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-meter-label-dark\)/m, block(".ks-meter-label"))
  end

  def test_color_text_meter_label_defaults_to_var_color_surface_700
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-meter-label: var\(--ks-color-text-label\)/m, self.class.compiled)
  end

  def test_color_text_meter_label_dark_defaults_to_var_color_surface_300
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-meter-label-dark: var\(--ks-color-text-label-dark\)/m, self.class.compiled)
  end

  def test_funnel_vertical_gap_between_children_is_2_spacing_units
    assert_match(/\.ks-funnel(?![\w-]).*?:not\(:last-child\).*?calc\(var\(--ks-spacing\) \* 2\)/m, self.class.compiled)
  end

  def test_funnel_layer_vertical_gap_between_children_is_1_spacing_units
    assert_match(/\.ks-funnel-layer(?![\w-]).*?:not\(:last-child\).*?calc\(var\(--ks-spacing\) \* 1\)/m, self.class.compiled)
  end

  def test_funnel_row_gap_is_3_spacing_units
    assert_includes block(".ks-funnel-row"), "gap: calc(var(--ks-spacing) * 3)"
  end

  def test_funnel_label_weight_reads_the_medium_font_weight_variable
    assert_includes block(".ks-funnel-label"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_funnel_label_text_reads_the_text_meter_label_colour_role
    assert_includes block(".ks-funnel-label"), "color: var(--ks-color-text-meter-label)"
  end

  def test_funnel_label_text_reads_the_text_meter_label_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-meter-label-dark\)/m, block(".ks-funnel-label"))
  end

  def test_funnel_value_weight_reads_the_heading_font_weight_variable
    assert_includes block(".ks-funnel-value"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_funnel_value_text_reads_the_text_display_colour_role
    assert_includes block(".ks-funnel-value"), "color: var(--ks-color-text-display)"
  end

  def test_funnel_value_text_reads_the_text_display_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-display-dark\)/m, block(".ks-funnel-value"))
  end

  def test_funnel_bar_radius_is_0_75_of_the_surface_radius
    assert_includes block(".ks-funnel-bar"), "border-radius: calc(var(--ks-radius-surface) * 0.75)"
  end

  def test_funnel_transition_padding_block_is_1_spacing_units
    assert_includes block(".ks-funnel-transition"), "padding-block: calc(var(--ks-spacing) * 1)"
  end

  def test_funnel_transition_text_reads_the_text_display_muted_colour_role
    assert_includes block(".ks-funnel-transition"), "color: var(--ks-color-text-display-muted)"
  end

  def test_funnel_transition_text_reads_the_text_display_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-display-muted-dark\)/m, block(".ks-funnel-transition"))
  end

  def test_funnel_bar_accent_fill_reads_the_funnel_accent_colour_role
    assert_includes block(".ks-funnel-bar-accent"), "background-color: var(--ks-color-funnel-accent)"
  end

  def test_color_funnel_accent_defaults_to_var_color_accent_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-funnel-accent: var\(--color-accent-500\)/m, self.class.compiled)
  end

  def test_funnel_bar_sky_fill_reads_the_funnel_sky_colour_role
    assert_includes block(".ks-funnel-bar-sky"), "background-color: var(--ks-color-funnel-sky)"
  end

  def test_color_funnel_sky_defaults_to_var_color_sky_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-funnel-sky: var\(--color-sky-500\)/m, self.class.compiled)
  end

  def test_funnel_bar_violet_fill_reads_the_funnel_violet_colour_role
    assert_includes block(".ks-funnel-bar-violet"), "background-color: var(--ks-color-funnel-violet)"
  end

  def test_color_funnel_violet_defaults_to_var_color_violet_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-funnel-violet: var\(--color-violet-500\)/m, self.class.compiled)
  end

  def test_funnel_bar_amber_fill_reads_the_funnel_amber_colour_role
    assert_includes block(".ks-funnel-bar-amber"), "background-color: var(--ks-color-funnel-amber)"
  end

  def test_color_funnel_amber_defaults_to_var_color_amber_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-funnel-amber: var\(--color-amber-500\)/m, self.class.compiled)
  end

  def test_funnel_bar_rose_fill_reads_the_funnel_rose_colour_role
    assert_includes block(".ks-funnel-bar-rose"), "background-color: var(--ks-color-funnel-rose)"
  end

  def test_color_funnel_rose_defaults_to_var_color_rose_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-funnel-rose: var\(--color-rose-500\)/m, self.class.compiled)
  end

  def test_bucket_gap_is_1_spacing_units
    assert_includes block(".ks-bucket"), "gap: calc(var(--ks-spacing) * 1)"
  end

  def test_bucket_series_gap_is_4_spacing_units
    assert_includes block(".ks-bucket-series"), "gap: calc(var(--ks-spacing) * 4)"
  end

  def test_bucket_label_weight_reads_the_medium_font_weight_variable
    assert_includes block(".ks-bucket-label"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_bucket_label_text_reads_the_text_label_colour_role
    assert_includes block(".ks-bucket-label"), "color: var(--ks-color-text-label)"
  end

  def test_bucket_label_text_reads_the_text_label_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-label-dark\)/m, block(".ks-bucket-label"))
  end

  def test_bucket_goal_text_reads_the_text_muted_colour_role
    assert_includes block(".ks-bucket-goal"), "color: var(--ks-color-text-muted)"
  end

  def test_bucket_goal_text_reads_the_text_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-muted-dark\)/m, block(".ks-bucket-goal"))
  end

  def test_bucket_percent_text_reads_the_text_muted_colour_role
    assert_includes block(".ks-bucket-percent"), "color: var(--ks-color-text-muted)"
  end

  def test_bucket_percent_text_reads_the_text_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-muted-dark\)/m, block(".ks-bucket-percent"))
  end

  def test_bucket_tank_top_corner_radius_is_0_5_of_the_surface_radius
    assert_includes block(".ks-bucket-tank"), "border-top-left-radius: calc(var(--ks-radius-surface) * 0.5)"
  end

  def test_bucket_tank_bottom_corner_radius_is_1_5_of_the_surface_radius
    assert_includes block(".ks-bucket-tank"), "border-bottom-left-radius: calc(var(--ks-radius-surface) * 1.5)"
  end

  def test_bucket_tank_border_width_is_2_times_the_border_width_variable
    assert_includes block(".ks-bucket-tank"), "border-width: calc(var(--ks-border-width) * 2)"
  end

  def test_bucket_tank_border_reads_the_border_strong_colour_role
    assert_includes block(".ks-bucket-tank"), "border-color: var(--ks-color-border-strong)"
  end

  def test_bucket_tank_fill_reads_the_hover_colour_role
    assert_includes block(".ks-bucket-tank"), "background-color: var(--ks-color-hover)"
  end

  def test_bucket_tank_border_reads_the_border_strong_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-strong-dark\)/m, block(".ks-bucket-tank"))
  end

  def test_bucket_tank_fill_reads_the_hover_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-hover-dark\)/m, block(".ks-bucket-tank"))
  end

  def test_bucket_actual_weight_reads_the_heading_font_weight_variable
    assert_includes block(".ks-bucket-actual"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_bucket_actual_text_reads_the_text_colour_role
    assert_includes block(".ks-bucket-actual"), "color: var(--ks-color-text)"
  end

  def test_bucket_actual_text_reads_the_text_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-dark\)/m, block(".ks-bucket-actual"))
  end

  def test_bucket_fill_fill_reads_the_meter_colour_role
    assert_includes block(".ks-bucket-fill"), "background-color: var(--ks-color-meter)"
  end

  def test_bucket_fill_over_fill_reads_the_over_goal_colour_role
    assert_includes block(".ks-bucket-fill-over"), "background-color: var(--ks-color-over-goal)"
  end

  def test_color_over_goal_defaults_to_var_color_green_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-over-goal: var\(--color-green-500\)/m, self.class.compiled)
  end

  def test_bucket_fill_over_warning_fill_reads_the_over_goal_warning_colour_role
    assert_includes block(".ks-bucket-fill-over-warning"), "background-color: var(--ks-color-over-goal-warning)"
  end

  def test_color_over_goal_warning_defaults_to_var_color_amber_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-over-goal-warning: var\(--color-amber-500\)/m, self.class.compiled)
  end

  def test_pipeline_radius_is_1_5_of_the_surface_radius
    assert_includes block(".ks-pipeline"), "border-radius: calc(var(--ks-radius-surface) * 1.5)"
  end

  def test_pipeline_border_width_reads_the_border_width_variable
    assert_includes block(".ks-pipeline"), "border-width: var(--ks-border-width)"
  end

  def test_pipeline_border_reads_the_pipeline_border_colour_role
    assert_includes block(".ks-pipeline"), "border-color: var(--ks-color-pipeline-border)"
  end

  def test_pipeline_fill_reads_the_pipeline_colour_role
    assert_includes block(".ks-pipeline"), "background-color: var(--ks-color-pipeline)"
  end

  def test_pipeline_padding_is_6_spacing_units
    assert_includes block(".ks-pipeline"), "padding: calc(var(--ks-spacing) * 6)"
  end

  def test_color_pipeline_border_defaults_to_var_color_surface_700
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-pipeline-border: var\(--color-surface-700\)/m, self.class.compiled)
  end

  def test_color_pipeline_defaults_to_var_color_surface_800
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-pipeline: var\(--color-surface-800\)/m, self.class.compiled)
  end

  def test_pipeline_header_margin_bottom_is_4_spacing_units
    assert_includes block(".ks-pipeline-header"), "margin-bottom: calc(var(--ks-spacing) * 4)"
  end

  def test_pipeline_title_weight_reads_the_heading_font_weight_variable
    assert_includes block(".ks-pipeline-title"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_pipeline_title_text_reads_the_text_on_dark_colour_role
    assert_includes block(".ks-pipeline-title"), "color: var(--ks-color-text-on-dark)"
  end

  def test_color_text_on_dark_defaults_to_var_color_white
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-on-dark: var\(--color-white\)/m, self.class.compiled)
  end

  def test_pipeline_subtitle_margin_top_is_1_spacing_units
    assert_includes block(".ks-pipeline-subtitle"), "margin-top: calc(var(--ks-spacing) * 1)"
  end

  def test_pipeline_subtitle_text_reads_the_pipeline_muted_colour_role
    assert_includes block(".ks-pipeline-subtitle"), "color: var(--ks-color-pipeline-muted)"
  end

  def test_color_pipeline_muted_defaults_to_var_color_surface_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-pipeline-muted: var\(--color-surface-400\)/m, self.class.compiled)
  end

  def test_pipeline_track_gap_is_3_spacing_units
    assert_includes block(".ks-pipeline-track"), "gap: calc(var(--ks-spacing) * 3)"
  end

  def test_pipeline_box_gap_is_2_spacing_units
    assert_includes block(".ks-pipeline-box"), "gap: calc(var(--ks-spacing) * 2)"
  end

  def test_pipeline_box_radius_reads_the_surface_radius
    assert_includes block(".ks-pipeline-box"), "border-radius: var(--ks-radius-surface)"
  end

  def test_pipeline_box_border_width_reads_the_border_width_variable
    assert_includes block(".ks-pipeline-box"), "border-width: var(--ks-border-width)"
  end

  def test_pipeline_box_border_reads_the_pipeline_border_colour_role
    assert_includes block(".ks-pipeline-box"), "border-color: var(--ks-color-pipeline-border)"
  end

  def test_pipeline_box_fill_reads_the_pipeline_box_colour_role
    assert_includes block(".ks-pipeline-box"), "background-color: var(--ks-color-pipeline-box)"
  end

  def test_pipeline_box_padding_is_4_spacing_units
    assert_includes block(".ks-pipeline-box"), "padding: calc(var(--ks-spacing) * 4)"
  end

  def test_color_pipeline_box_defaults_to_var_color_surface_900
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-pipeline-box: var\(--color-surface-900\)/m, self.class.compiled)
  end

  def test_pipeline_box_label_text_reads_the_pipeline_label_colour_role
    assert_includes block(".ks-pipeline-box-label"), "color: var(--ks-color-pipeline-label)"
  end

  def test_color_pipeline_label_defaults_to_var_color_surface_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-pipeline-label: var\(--color-surface-500\)/m, self.class.compiled)
  end

  def test_pipeline_count_weight_is_one_step_above_the_heading_font_weight
    assert_includes block(".ks-pipeline-count"), "font-weight: calc(var(--ks-font-weight-heading) + 100)"
  end

  def test_pipeline_link_healthy_text_reads_the_meter_colour_role
    assert_includes block(".ks-pipeline-link-healthy"), "color: var(--ks-color-meter)"
  end

  def test_pipeline_link_broken_text_reads_the_danger_500_colour_role
    assert_includes block(".ks-pipeline-link-broken"), "color: var(--ks-color-danger-500)"
  end

  def test_pipeline_count_amber_text_reads_the_pipeline_amber_colour_role
    assert_includes block(".ks-pipeline-count-amber"), "color: var(--ks-color-pipeline-amber)"
  end

  def test_color_pipeline_amber_defaults_to_var_color_amber_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-pipeline-amber: var\(--color-amber-400\)/m, self.class.compiled)
  end

  def test_pipeline_count_emerald_text_reads_the_info_400_colour_role
    assert_includes block(".ks-pipeline-count-emerald"), "color: var(--ks-color-info-400)"
  end

  def test_pipeline_count_danger_text_reads_the_danger_400_colour_role
    assert_includes block(".ks-pipeline-count-danger"), "color: var(--ks-color-danger-400)"
  end

  def test_pipeline_count_muted_text_reads_the_pipeline_label_colour_role
    assert_includes block(".ks-pipeline-count-muted"), "color: var(--ks-color-pipeline-label)"
  end

  def test_swipe_card_radius_is_2_of_the_surface_radius
    assert_includes block(".ks-swipe-card"), "border-radius: calc(var(--ks-radius-surface) * 2)"
  end

  def test_swipe_card_border_width_reads_the_border_width_variable
    assert_includes block(".ks-swipe-card"), "border-width: var(--ks-border-width)"
  end

  def test_swipe_card_border_reads_the_border_colour_role
    assert_includes block(".ks-swipe-card"), "border-color: var(--ks-color-border)"
  end

  def test_swipe_card_fill_reads_the_surface_colour_role
    assert_includes block(".ks-swipe-card"), "background-color: var(--ks-color-surface)"
  end

  def test_swipe_card_shadow_reads_the_overlay_shadow_variable
    assert_includes block(".ks-swipe-card"), "--tw-shadow: var(--ks-shadow-overlay)"
  end

  def test_swipe_card_padding_is_6_spacing_units
    assert_includes block(".ks-swipe-card"), "padding: calc(var(--ks-spacing) * 6)"
  end

  def test_swipe_card_border_reads_the_border_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-swipe-card"))
  end

  def test_swipe_card_fill_reads_the_surface_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-surface-dark\)/m, block(".ks-swipe-card"))
  end

  def test_swipe_empty_padding_block_is_16_spacing_units
    assert_includes block(".ks-swipe-empty"), "padding-block: calc(var(--ks-spacing) * 16)"
  end

  def test_swipe_empty_title_weight_reads_the_heading_font_weight_variable
    assert_includes block(".ks-swipe-empty-title"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_swipe_empty_title_text_reads_the_text_colour_role
    assert_includes block(".ks-swipe-empty-title"), "color: var(--ks-color-text)"
  end

  def test_swipe_empty_title_text_reads_the_text_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-dark\)/m, block(".ks-swipe-empty-title"))
  end

  def test_swipe_empty_message_margin_top_is_2_spacing_units
    assert_includes block(".ks-swipe-empty-message"), "margin-top: calc(var(--ks-spacing) * 2)"
  end

  def test_swipe_empty_message_text_reads_the_text_muted_colour_role
    assert_includes block(".ks-swipe-empty-message"), "color: var(--ks-color-text-muted)"
  end

  def test_swipe_empty_message_text_reads_the_text_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-muted-dark\)/m, block(".ks-swipe-empty-message"))
  end

  def test_swipe_actions_gap_is_8_spacing_units
    assert_includes block(".ks-swipe-actions"), "gap: calc(var(--ks-spacing) * 8)"
  end

  def test_swipe_actions_margin_top_is_8_spacing_units
    assert_includes block(".ks-swipe-actions"), "margin-top: calc(var(--ks-spacing) * 8)"
  end

  def test_swipe_button_radius_reads_the_pill_radius
    assert_includes block(".ks-swipe-button"), "border-radius: var(--ks-radius-pill)"
  end

  def test_swipe_button_border_width_is_2_times_the_border_width_variable
    assert_includes block(".ks-swipe-button"), "border-width: calc(var(--ks-border-width) * 2)"
  end

  def test_swipe_button_border_reads_the_border_strong_colour_role
    assert_includes block(".ks-swipe-button"), "border-color: var(--ks-color-border-strong)"
  end

  def test_swipe_button_text_reads_the_close_colour_role
    assert_includes block(".ks-swipe-button"), "color: var(--ks-color-close)"
  end

  def test_swipe_button_border_reads_the_border_strong_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-strong-dark\)/m, block(".ks-swipe-button"))
  end

  def test_swipe_button_reject_border_reads_the_danger_400_colour_role_on_hover
    assert_match(/\.ks-swipe-button-reject(?![\w-]).*?:hover.*?border-color: var\(--ks-color-danger-400\)/m, self.class.compiled)
  end

  def test_swipe_button_reject_text_reads_the_danger_400_colour_role_on_hover
    assert_match(/\.ks-swipe-button-reject(?![\w-]).*?:hover.*?\scolor: var\(--ks-color-danger-400\)/m, self.class.compiled)
  end

  def test_swipe_button_accept_border_reads_the_success_400_colour_role_on_hover
    assert_match(/\.ks-swipe-button-accept(?![\w-]).*?:hover.*?border-color: var\(--ks-color-success-400\)/m, self.class.compiled)
  end

  def test_swipe_button_accept_text_reads_the_success_400_colour_role_on_hover
    assert_match(/\.ks-swipe-button-accept(?![\w-]).*?:hover.*?\scolor: var\(--ks-color-success-400\)/m, self.class.compiled)
  end

  def test_color_nav_defaults_to_var_base_bg_low_var_color_white
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav: var\(--base-bg-low, var\(--ks-color-surface\)\)/m, self.class.compiled)
  end

  def test_color_nav_dark_defaults_to_var_base_bg_low_var_color_zinc_900
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-dark: var\(--base-bg-low, var\(--ks-color-surface-dark\)\)/m, self.class.compiled)
  end

  def test_color_nav_border_defaults_to_var_base_border_tertiary_var_color_gray_200
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-border: var\(--base-border-tertiary, var\(--ks-color-border\)\)/m, self.class.compiled)
  end

  def test_color_nav_border_dark_defaults_to_var_base_border_tertiary_var_color_zinc_700
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-border-dark: var\(--base-border-tertiary, var\(--ks-color-border-dark\)\)/m, self.class.compiled)
  end

  def test_color_nav_text_defaults_to_var_base_text_tertiary_var_color_gray_500
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-text: var\(--base-text-tertiary, var\(--ks-color-text-muted\)\)/m, self.class.compiled)
  end

  def test_color_nav_text_dark_defaults_to_var_base_text_tertiary_var_color_gray_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-text-dark: var\(--base-text-tertiary, var\(--ks-color-text-muted-dark\)\)/m, self.class.compiled)
  end

  def test_color_nav_text_hover_defaults_to_var_base_text_secondary_var_color_gray_700
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-text-hover: var\(--base-text-secondary, var\(--ks-color-text-label\)\)/m, self.class.compiled)
  end

  def test_color_nav_text_hover_dark_defaults_to_var_base_text_secondary_var_color_gray_300
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-text-hover-dark: var\(--base-text-secondary, var\(--ks-color-text-label-dark\)\)/m, self.class.compiled)
  end

  def test_color_nav_active_defaults_to_var_text_primary_var_color_accent_600
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-active: var\(--text-primary, var\(--ks-color-link\)\)/m, self.class.compiled)
  end

  def test_color_nav_active_dark_defaults_to_var_text_primary_var_color_accent_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-active-dark: var\(--text-primary, var\(--ks-color-link-dark\)\)/m, self.class.compiled)
  end

  def test_color_nav_link_defaults_to_var_base_text_var_color_gray_900
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-link: var\(--base-text, var\(--ks-color-text\)\)/m, self.class.compiled)
  end

  def test_color_nav_link_dark_defaults_to_var_base_text_var_color_white
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-link-dark: var\(--base-text, var\(--ks-color-text-dark\)\)/m, self.class.compiled)
  end

  def test_color_nav_indicator_defaults_to_var_border_primary_var_color_accent_600
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-indicator: var\(--border-primary, var\(--ks-color-link\)\)/m, self.class.compiled)
  end

  def test_color_nav_indicator_dark_defaults_to_var_border_primary_var_color_accent_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-indicator-dark: var\(--border-primary, var\(--ks-color-link-dark\)\)/m, self.class.compiled)
  end

  def test_color_nav_menu_mobile_defaults_to_var_base_bg_base_var_color_white
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-menu-mobile: var\(--base-bg-base, var\(--ks-color-surface\)\)/m, self.class.compiled)
  end

  def test_color_nav_menu_mobile_dark_defaults_to_var_base_bg_base_var_color_zinc_900
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-menu-mobile-dark: var\(--base-bg-base, var\(--ks-color-surface-dark\)\)/m, self.class.compiled)
  end

  def test_color_nav_hover_defaults_to_var_base_bg_hover_var_color_gray_50
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-hover: var\(--base-bg-hover, var\(--ks-color-hover\)\)/m, self.class.compiled)
  end

  def test_color_nav_hover_dark_defaults_to_var_base_bg_hover_var_color_zinc_800
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-nav-hover-dark: var\(--base-bg-hover, var\(--ks-color-hover-dark\)\)/m, self.class.compiled)
  end

  def test_shadow_menu_defaults_to_var_shadow_md
    assert_match(/@layer base \{.*?:root \{.*?--ks-shadow-menu: var\(--shadow-md\)/m, self.class.compiled)
  end

  def test_font_weight_normal_defaults_to_var_font_weight_normal
    assert_match(/@layer base \{.*?:root \{.*?--ks-font-weight-normal: var\(--font-weight-normal\)/m, self.class.compiled)
  end

  def test_bottom_nav_position_is_fixed
    assert_includes block(".ks-bottom-nav"), "position: fixed"
  end

  def test_bottom_nav_bottom_edge_sits_at_the_bottom_of_the_screen
    assert_includes block(".ks-bottom-nav"), "bottom: 0px"
  end

  def test_bottom_nav_left_edge_sits_at_the_left_of_the_screen
    assert_includes block(".ks-bottom-nav"), "left: 0px"
  end

  def test_bottom_nav_right_edge_sits_at_the_right_of_the_screen
    assert_includes block(".ks-bottom-nav"), "right: 0px"
  end

  def test_bottom_nav_stacking_level_is_40
    assert_includes block(".ks-bottom-nav"), "z-index: 40"
  end

  def test_bottom_nav_items_sit_in_a_row
    assert_includes block(".ks-bottom-nav"), "display: flex"
  end

  def test_bottom_nav_items_are_spaced_evenly
    assert_includes block(".ks-bottom-nav"), "justify-content: space-around"
  end

  def test_bottom_nav_bottom_padding_clears_the_safe_area
    assert_includes block(".ks-bottom-nav"), "padding-bottom: env(safe-area-inset-bottom)"
  end

  def test_bottom_nav_bar_is_hidden_on_large_screens
    assert_match(/width >= 64rem.*?display: none/m, block(".ks-bottom-nav"))
  end

  def test_bottom_nav_fill_reads_the_nav_colour_role
    assert_includes block(".ks-bottom-nav"), "background-color: var(--ks-color-nav)"
  end

  def test_bottom_nav_fill_reads_the_nav_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-nav-dark\)/m, block(".ks-bottom-nav"))
  end

  def test_bottom_nav_top_border_width_reads_the_border_width_variable
    assert_includes block(".ks-bottom-nav"), "border-top-width: var(--ks-border-width)"
  end

  def test_bottom_nav_top_border_reads_the_nav_border_colour_role
    assert_includes block(".ks-bottom-nav"), "border-top-color: var(--ks-color-nav-border)"
  end

  def test_bottom_nav_top_border_reads_the_nav_border_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-top-color: var\(--ks-color-nav-border-dark\)/m, block(".ks-bottom-nav"))
  end

  def test_bottom_nav_background_extends_below_the_screen_edge
    assert_match(/\.ks-bottom-nav::after \{.*?background: inherit/m, self.class.compiled)
  end

  def test_bottom_nav_item_content_is_laid_out_with_flex
    assert_includes block(".ks-bottom-nav-item"), "display: flex"
  end

  def test_bottom_nav_item_width_shares_the_bar_equally
    assert_includes block(".ks-bottom-nav-item"), "flex: 1"
  end

  def test_bottom_nav_item_icon_sits_above_its_label
    assert_includes block(".ks-bottom-nav-item"), "flex-direction: column"
  end

  def test_bottom_nav_item_content_is_centred_across
    assert_includes block(".ks-bottom-nav-item"), "align-items: center"
  end

  def test_bottom_nav_item_content_is_centred_down
    assert_includes block(".ks-bottom-nav-item"), "justify-content: center"
  end

  def test_bottom_nav_item_height_is_at_least_56_pixels
    assert_includes block(".ks-bottom-nav-item"), "min-height: calc(var(--spacing) * 14)"
  end

  def test_bottom_nav_item_label_is_not_underlined
    assert_includes block(".ks-bottom-nav-item"), "text-decoration-line: none"
  end

  def test_bottom_nav_item_gap_is_0_5_spacing_units
    assert_includes block(".ks-bottom-nav-item"), "gap: calc(var(--ks-spacing) * 0.5)"
  end

  def test_bottom_nav_item_padding_block_is_2_spacing_units
    assert_includes block(".ks-bottom-nav-item"), "padding-block: calc(var(--ks-spacing) * 2)"
  end

  def test_bottom_nav_item_padding_inline_is_1_spacing_units
    assert_includes block(".ks-bottom-nav-item"), "padding-inline: calc(var(--ks-spacing) * 1)"
  end

  def test_bottom_nav_item_text_reads_the_nav_text_colour_role
    assert_includes block(".ks-bottom-nav-item"), "color: var(--ks-color-nav-text)"
  end

  def test_bottom_nav_item_text_reads_the_nav_text_hover_colour_role_on_hover
    assert_match(/:hover.*?\scolor: var\(--ks-color-nav-text-hover\)/m, block(".ks-bottom-nav-item"))
  end

  def test_bottom_nav_item_text_reads_the_nav_text_hover_colour_role_while_pressed
    assert_match(/\&:active.*?\scolor: var\(--ks-color-nav-text-hover\)/m, block(".ks-bottom-nav-item"))
  end

  def test_bottom_nav_item_text_reads_the_nav_active_colour_role_when_marked_active
    assert_match(/\&\.active.*?\scolor: var\(--ks-color-nav-active\)/m, block(".ks-bottom-nav-item"))
  end

  def test_bottom_nav_item_text_reads_the_nav_text_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-nav-text-dark\)/m, block(".ks-bottom-nav-item"))
  end

  def test_bottom_nav_item_text_reads_the_nav_text_hover_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?:hover.*?\scolor: var\(--ks-color-nav-text-hover-dark\)/m, block(".ks-bottom-nav-item"))
  end

  def test_bottom_nav_item_text_reads_the_nav_text_hover_dark_colour_role_on_a_dark_page_and_while_pressed
    assert_match(/data-theme="dark".*?\&:active.*?\scolor: var\(--ks-color-nav-text-hover-dark\)/m, block(".ks-bottom-nav-item"))
  end

  def test_bottom_nav_item_text_reads_the_nav_active_dark_colour_role_on_a_dark_page_and_when_marked_active
    assert_match(/data-theme="dark".*?\&\.active.*?\scolor: var\(--ks-color-nav-active-dark\)/m, block(".ks-bottom-nav-item"))
  end

  def test_bottom_nav_item_icon_is_24_pixels_for_its_icon
    assert_match(/\& svg.*?width: calc\(var\(--spacing\) \* 6\)/m, block(".ks-bottom-nav-item"))
  end

  def test_bottom_nav_label_label_is_10_pixels
    assert_includes block(".ks-bottom-nav-label"), "font-size: 10px"
  end

  def test_bottom_nav_label_weight_reads_the_medium_font_weight_variable
    assert_includes block(".ks-bottom-nav-label"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_bottom_nav_label_label_has_no_extra_line_height
    assert_includes block(".ks-bottom-nav-label"), "line-height: 1"
  end

  def test_nav_dropdown_menu_is_placed_against_it
    assert_includes block(".ks-nav-dropdown"), "position: relative"
  end

  def test_nav_dropdown_width_fills_its_row
    assert_includes block(".ks-nav-dropdown"), "width: 100%"
  end

  def test_nav_dropdown_width_fits_its_trigger_on_large_screens
    assert_match(/width >= 64rem.*?width: auto/m, block(".ks-nav-dropdown"))
  end

  def test_nav_dropdown_trigger_content_is_laid_out_with_flex
    assert_includes block(".ks-nav-dropdown-trigger"), "display: flex"
  end

  def test_nav_dropdown_trigger_content_is_centred_down
    assert_includes block(".ks-nav-dropdown-trigger"), "align-items: center"
  end

  def test_nav_dropdown_trigger_label_and_caret_sit_at_either_end
    assert_includes block(".ks-nav-dropdown-trigger"), "justify-content: space-between"
  end

  def test_nav_dropdown_trigger_text_is_small
    assert_includes block(".ks-nav-dropdown-trigger"), "font-size: var(--text-sm)"
  end

  def test_nav_dropdown_trigger_label_stays_on_one_line
    assert_includes block(".ks-nav-dropdown-trigger"), "text-wrap: nowrap"
  end

  def test_nav_dropdown_trigger_width_fills_its_row
    assert_includes block(".ks-nav-dropdown-trigger"), "width: 100%"
  end

  def test_nav_dropdown_trigger_label_is_not_underlined
    assert_includes block(".ks-nav-dropdown-trigger"), "text-decoration-line: none"
  end

  def test_nav_dropdown_trigger_gap_is_1_spacing_units
    assert_includes block(".ks-nav-dropdown-trigger"), "gap: calc(var(--ks-spacing) * 1)"
  end

  def test_nav_dropdown_trigger_padding_inline_is_4_spacing_units
    assert_includes block(".ks-nav-dropdown-trigger"), "padding-inline: calc(var(--ks-spacing) * 4)"
  end

  def test_nav_dropdown_trigger_padding_block_is_3_spacing_units
    assert_includes block(".ks-nav-dropdown-trigger"), "padding-block: calc(var(--ks-spacing) * 3)"
  end

  def test_nav_dropdown_trigger_padding_inline_is_1_spacing_units_on_large_screens
    assert_match(/width >= 64rem.*?padding-inline: calc\(var\(--ks-spacing\) \* 1\)/m, block(".ks-nav-dropdown-trigger"))
  end

  def test_nav_dropdown_trigger_padding_block_is_2_spacing_units_on_large_screens
    assert_match(/width >= 64rem.*?padding-block: calc\(var\(--ks-spacing\) \* 2\)/m, block(".ks-nav-dropdown-trigger"))
  end

  def test_nav_dropdown_trigger_width_fits_its_label_on_large_screens
    assert_match(/width >= 64rem.*?width: auto/m, block(".ks-nav-dropdown-trigger"))
  end

  def test_nav_dropdown_trigger_text_reads_the_nav_link_colour_role
    assert_includes block(".ks-nav-dropdown-trigger"), "color: var(--ks-color-nav-link)"
  end

  def test_nav_dropdown_trigger_text_reads_the_nav_text_hover_colour_role_on_hover
    assert_match(/:hover.*?\scolor: var\(--ks-color-nav-text-hover\)/m, block(".ks-nav-dropdown-trigger"))
  end

  def test_nav_dropdown_trigger_text_reads_the_nav_active_colour_role_when_marked_active
    assert_match(/\&\.active.*?\scolor: var\(--ks-color-nav-active\)/m, block(".ks-nav-dropdown-trigger"))
  end

  def test_nav_dropdown_trigger_weight_reads_the_heading_font_weight_variable_when_marked_active
    assert_match(/\&\.active.*?font-weight: var\(--ks-font-weight-heading\)/m, block(".ks-nav-dropdown-trigger"))
  end

  def test_nav_dropdown_trigger_text_reads_the_nav_link_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-nav-link-dark\)/m, block(".ks-nav-dropdown-trigger"))
  end

  def test_nav_dropdown_trigger_text_reads_the_nav_text_hover_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?:hover.*?\scolor: var\(--ks-color-nav-text-hover-dark\)/m, block(".ks-nav-dropdown-trigger"))
  end

  def test_nav_dropdown_trigger_text_reads_the_nav_active_dark_colour_role_on_a_dark_page_and_when_marked_active
    assert_match(/data-theme="dark".*?\&\.active.*?\scolor: var\(--ks-color-nav-active-dark\)/m, block(".ks-nav-dropdown-trigger"))
  end

  def test_nav_dropdown_trigger_underline_reads_the_nav_indicator_colour_role_on_large_screens_and_when_marked_active
    assert_match(/width >= 64rem.*?\&\.active.*?inset 0 calc\(var\(--ks-border-width\) \* -4\) 0 0 var\(--tw-shadow-color, var\(--ks-color-nav-indicator\)\)/m, block(".ks-nav-dropdown-trigger"))
  end

  def test_nav_dropdown_trigger_underline_reads_the_nav_indicator_dark_colour_role_on_a_dark_page_and_on_large_screens_and_when_marked_active
    assert_match(/data-theme="dark".*?width >= 64rem.*?\&\.active.*?inset 0 calc\(var\(--ks-border-width\) \* -4\) 0 0 var\(--tw-shadow-color, var\(--ks-color-nav-indicator-dark\)\)/m, block(".ks-nav-dropdown-trigger"))
  end

  def test_nav_item_content_is_laid_out_with_flex
    assert_includes block(".ks-nav-item"), "display: flex"
  end

  def test_nav_item_content_is_centred_down
    assert_includes block(".ks-nav-item"), "align-items: center"
  end

  def test_nav_item_label_and_caret_sit_at_either_end
    assert_includes block(".ks-nav-item"), "justify-content: space-between"
  end

  def test_nav_item_text_is_small
    assert_includes block(".ks-nav-item"), "font-size: var(--text-sm)"
  end

  def test_nav_item_label_stays_on_one_line
    assert_includes block(".ks-nav-item"), "text-wrap: nowrap"
  end

  def test_nav_item_width_fills_its_row
    assert_includes block(".ks-nav-item"), "width: 100%"
  end

  def test_nav_item_label_is_not_underlined
    assert_includes block(".ks-nav-item"), "text-decoration-line: none"
  end

  def test_nav_item_gap_is_1_spacing_units
    assert_includes block(".ks-nav-item"), "gap: calc(var(--ks-spacing) * 1)"
  end

  def test_nav_item_padding_inline_is_4_spacing_units
    assert_includes block(".ks-nav-item"), "padding-inline: calc(var(--ks-spacing) * 4)"
  end

  def test_nav_item_padding_block_is_3_spacing_units
    assert_includes block(".ks-nav-item"), "padding-block: calc(var(--ks-spacing) * 3)"
  end

  def test_nav_item_padding_inline_is_1_spacing_units_on_large_screens
    assert_match(/width >= 64rem.*?padding-inline: calc\(var\(--ks-spacing\) \* 1\)/m, block(".ks-nav-item"))
  end

  def test_nav_item_padding_block_is_2_spacing_units_on_large_screens
    assert_match(/width >= 64rem.*?padding-block: calc\(var\(--ks-spacing\) \* 2\)/m, block(".ks-nav-item"))
  end

  def test_nav_item_width_fits_its_label_on_large_screens
    assert_match(/width >= 64rem.*?width: auto/m, block(".ks-nav-item"))
  end

  def test_nav_item_text_reads_the_nav_link_colour_role
    assert_includes block(".ks-nav-item"), "color: var(--ks-color-nav-link)"
  end

  def test_nav_item_text_reads_the_nav_text_hover_colour_role_on_hover
    assert_match(/:hover.*?\scolor: var\(--ks-color-nav-text-hover\)/m, block(".ks-nav-item"))
  end

  def test_nav_item_text_reads_the_nav_active_colour_role_when_marked_active
    assert_match(/\&\.active.*?\scolor: var\(--ks-color-nav-active\)/m, block(".ks-nav-item"))
  end

  def test_nav_item_weight_reads_the_heading_font_weight_variable_when_marked_active
    assert_match(/\&\.active.*?font-weight: var\(--ks-font-weight-heading\)/m, block(".ks-nav-item"))
  end

  def test_nav_item_text_reads_the_nav_link_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-nav-link-dark\)/m, block(".ks-nav-item"))
  end

  def test_nav_item_text_reads_the_nav_text_hover_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?:hover.*?\scolor: var\(--ks-color-nav-text-hover-dark\)/m, block(".ks-nav-item"))
  end

  def test_nav_item_text_reads_the_nav_active_dark_colour_role_on_a_dark_page_and_when_marked_active
    assert_match(/data-theme="dark".*?\&\.active.*?\scolor: var\(--ks-color-nav-active-dark\)/m, block(".ks-nav-item"))
  end

  def test_nav_item_underline_reads_the_nav_indicator_colour_role_on_large_screens_and_when_marked_active
    assert_match(/width >= 64rem.*?\&\.active.*?inset 0 calc\(var\(--ks-border-width\) \* -4\) 0 0 var\(--tw-shadow-color, var\(--ks-color-nav-indicator\)\)/m, block(".ks-nav-item"))
  end

  def test_nav_item_underline_reads_the_nav_indicator_dark_colour_role_on_a_dark_page_and_on_large_screens_and_when_marked_active
    assert_match(/data-theme="dark".*?width >= 64rem.*?\&\.active.*?inset 0 calc\(var\(--ks-border-width\) \* -4\) 0 0 var\(--tw-shadow-color, var\(--ks-color-nav-indicator-dark\)\)/m, block(".ks-nav-item"))
  end

  def test_nav_dropdown_caret_caret_is_16_pixels
    assert_includes block(".ks-nav-dropdown-caret"), "width: calc(var(--spacing) * 4)"
  end

  def test_nav_dropdown_caret_caret_animates_its_turn
    assert_includes block(".ks-nav-dropdown-caret"), "transition-property: transform"
  end

  def test_nav_dropdown_caret_turn_takes_200_milliseconds
    assert_includes block(".ks-nav-dropdown-caret"), "transition-duration: 200ms"
  end

  def test_nav_dropdown_caret_turn_eases
    assert_includes block(".ks-nav-dropdown-caret"), "transition-timing-function: ease"
  end

  def test_nav_dropdown_caret_turns_while_its_menu_is_open
    assert_match(/\.ks-nav-dropdown:has\(\.ks-nav-dropdown-menu:not\(\.hidden\)\) \.ks-nav-dropdown-caret \{.*?transform: rotate\(180deg\)/m, self.class.compiled)
  end

  def test_nav_dropdown_menu_position_is_relative_on_small_screens
    assert_includes block(".ks-nav-dropdown-menu"), "position: relative"
  end

  def test_nav_dropdown_menu_width_fills_its_row_on_small_screens
    assert_includes block(".ks-nav-dropdown-menu"), "width: 100%"
  end

  def test_nav_dropdown_menu_stacking_level_is_50
    assert_includes block(".ks-nav-dropdown-menu"), "z-index: 50"
  end

  def test_nav_dropdown_menu_fill_reads_the_nav_menu_mobile_colour_role
    assert_includes block(".ks-nav-dropdown-menu"), "background-color: var(--ks-color-nav-menu-mobile)"
  end

  def test_nav_dropdown_menu_fill_reads_the_nav_menu_mobile_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-nav-menu-mobile-dark\)/m, block(".ks-nav-dropdown-menu"))
  end

  def test_nav_dropdown_menu_fill_reads_the_nav_colour_role_on_large_screens
    assert_match(/width >= 64rem.*?background-color: var\(--ks-color-nav\)/m, block(".ks-nav-dropdown-menu"))
  end

  def test_nav_dropdown_menu_fill_reads_the_nav_dark_colour_role_on_a_dark_page_and_on_large_screens
    assert_match(/data-theme="dark".*?width >= 64rem.*?background-color: var\(--ks-color-nav-dark\)/m, block(".ks-nav-dropdown-menu"))
  end

  def test_nav_dropdown_menu_border_width_reads_the_border_width_variable_on_large_screens
    assert_match(/width >= 64rem.*?border-width: var\(--ks-border-width\)/m, block(".ks-nav-dropdown-menu"))
  end

  def test_nav_dropdown_menu_border_reads_the_nav_border_colour_role_on_large_screens
    assert_match(/width >= 64rem.*?border-color: var\(--ks-color-nav-border\)/m, block(".ks-nav-dropdown-menu"))
  end

  def test_nav_dropdown_menu_border_reads_the_nav_border_dark_colour_role_on_a_dark_page_and_on_large_screens
    assert_match(/data-theme="dark".*?width >= 64rem.*?border-color: var\(--ks-color-nav-border-dark\)/m, block(".ks-nav-dropdown-menu"))
  end

  def test_nav_dropdown_menu_radius_reads_the_surface_radius_on_large_screens
    assert_match(/width >= 64rem.*?border-radius: var\(--ks-radius-surface\)/m, block(".ks-nav-dropdown-menu"))
  end

  def test_nav_dropdown_menu_shadow_reads_the_menu_shadow_variable_on_large_screens
    assert_match(/width >= 64rem.*?--tw-shadow: var\(--ks-shadow-menu\)/m, block(".ks-nav-dropdown-menu"))
  end

  def test_nav_dropdown_menu_width_is_at_least_200_pixels_on_large_screens
    assert_match(/width >= 64rem.*?min-width: 200px/m, block(".ks-nav-dropdown-menu"))
  end

  def test_nav_dropdown_menu_position_floats_below_its_trigger_on_large_screens
    assert_match(/width >= 64rem.*?position: absolute/m, block(".ks-nav-dropdown-menu"))
  end

  def test_nav_dropdown_menu_top_sits_below_its_trigger_on_large_screens
    assert_match(/width >= 64rem.*?top: 100%/m, block(".ks-nav-dropdown-menu"))
  end

  def test_nav_dropdown_menu_left_edge_lines_up_with_its_trigger_on_large_screens
    assert_match(/width >= 64rem.*?left: 0px/m, block(".ks-nav-dropdown-menu"))
  end

  def test_nav_dropdown_menu_margin_top_is_1_spacing_units_on_large_screens
    assert_match(/width >= 64rem.*?margin-top: calc\(var\(--ks-spacing\) \* 1\)/m, block(".ks-nav-dropdown-menu"))
  end

  def test_nav_dropdown_menu_list_has_no_bullets
    assert_includes block(".ks-nav-dropdown-menu"), "list-style-type: none"
  end

  def test_nav_dropdown_menu_list_has_no_margin
    assert_includes block(".ks-nav-dropdown-menu"), "margin: 0px"
  end

  def test_nav_dropdown_menu_list_has_no_padding
    assert_includes block(".ks-nav-dropdown-menu"), "padding: 0px"
  end

  def test_nav_dropdown_menu_link_link_fills_its_row
    assert_includes block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"), "display: block"
  end

  def test_nav_dropdown_menu_link_text_is_small
    assert_includes block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"), "font-size: var(--text-sm)"
  end

  def test_nav_dropdown_menu_link_label_is_not_underlined
    assert_includes block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"), "text-decoration-line: none"
  end

  def test_nav_dropdown_menu_link_label_stays_on_one_line
    assert_includes block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"), "white-space: nowrap"
  end

  def test_nav_dropdown_menu_link_padding_block_is_3_spacing_units
    assert_includes block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"), "padding-block: calc(var(--ks-spacing) * 3)"
  end

  def test_nav_dropdown_menu_link_padding_right_is_4_spacing_units
    assert_includes block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"), "padding-right: calc(var(--ks-spacing) * 4)"
  end

  def test_nav_dropdown_menu_link_padding_left_is_8_spacing_units
    assert_includes block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"), "padding-left: calc(var(--ks-spacing) * 8)"
  end

  def test_nav_dropdown_menu_link_padding_block_is_2_spacing_units_on_large_screens
    assert_match(/width >= 64rem.*?padding-block: calc\(var\(--ks-spacing\) \* 2\)/m, block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"))
  end

  def test_nav_dropdown_menu_link_padding_inline_is_4_spacing_units_on_large_screens
    assert_match(/width >= 64rem.*?padding-inline: calc\(var\(--ks-spacing\) \* 4\)/m, block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"))
  end

  def test_nav_dropdown_menu_link_text_reads_the_nav_link_colour_role
    assert_includes block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"), "color: var(--ks-color-nav-link)"
  end

  def test_nav_dropdown_menu_link_fill_reads_the_nav_hover_colour_role_on_hover
    assert_match(/:hover.*?background-color: var\(--ks-color-nav-hover\)/m, block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"))
  end

  def test_nav_dropdown_menu_link_text_reads_the_nav_text_hover_colour_role_on_hover
    assert_match(/:hover.*?\scolor: var\(--ks-color-nav-text-hover\)/m, block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"))
  end

  def test_nav_dropdown_menu_link_fill_reads_the_nav_hover_colour_role_when_marked_active
    assert_match(/\&\.active.*?background-color: var\(--ks-color-nav-hover\)/m, block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"))
  end

  def test_nav_dropdown_menu_link_text_reads_the_nav_active_colour_role_when_marked_active
    assert_match(/\&\.active.*?\scolor: var\(--ks-color-nav-active\)/m, block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"))
  end

  def test_nav_dropdown_menu_link_weight_reads_the_heading_font_weight_variable_when_marked_active
    assert_match(/\&\.active.*?font-weight: var\(--ks-font-weight-heading\)/m, block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"))
  end

  def test_nav_dropdown_menu_link_text_reads_the_nav_link_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-nav-link-dark\)/m, block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"))
  end

  def test_nav_dropdown_menu_link_fill_reads_the_nav_hover_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?:hover.*?background-color: var\(--ks-color-nav-hover-dark\)/m, block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"))
  end

  def test_nav_dropdown_menu_link_text_reads_the_nav_text_hover_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?:hover.*?\scolor: var\(--ks-color-nav-text-hover-dark\)/m, block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"))
  end

  def test_nav_dropdown_menu_link_fill_reads_the_nav_hover_dark_colour_role_on_a_dark_page_and_when_marked_active
    assert_match(/data-theme="dark".*?\&\.active.*?background-color: var\(--ks-color-nav-hover-dark\)/m, block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"))
  end

  def test_nav_dropdown_menu_link_text_reads_the_nav_active_dark_colour_role_on_a_dark_page_and_when_marked_active
    assert_match(/data-theme="dark".*?\&\.active.*?\scolor: var\(--ks-color-nav-active-dark\)/m, block(".ks-nav-dropdown-menu li a, .ks-nav-dropdown-menu > a"))
  end

  def test_navbar_title_weight_reads_the_heading_font_weight_variable
    assert_includes block(".ks-navbar-title"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_navbar_title_text_reads_the_text_colour_role
    assert_includes block(".ks-navbar-title"), "color: var(--ks-color-text)"
  end

  def test_navbar_title_text_reads_the_text_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-text-dark\)/m, block(".ks-navbar-title"))
  end

  def test_mobile_header_title_weight_reads_the_heading_font_weight_variable
    assert_includes block(".ks-mobile-header-title"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_mobile_header_title_text_reads_the_text_colour_role
    assert_includes block(".ks-mobile-header-title"), "color: var(--ks-color-text)"
  end

  def test_mobile_header_title_text_reads_the_text_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-text-dark\)/m, block(".ks-mobile-header-title"))
  end

  def test_mobile_header_back_text_reads_the_text_muted_colour_role
    assert_includes block(".ks-mobile-header-back"), "color: var(--ks-color-text-muted)"
  end

  def test_mobile_header_back_text_reads_the_text_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-text-muted-dark\)/m, block(".ks-mobile-header-back"))
  end

  def test_mobile_header_subtitle_weight_reads_the_normal_font_weight_variable
    assert_includes block(".ks-mobile-header-subtitle"), "font-weight: var(--ks-font-weight-normal)"
  end

  def test_mobile_header_subtitle_text_reads_the_text_muted_colour_role
    assert_includes block(".ks-mobile-header-subtitle"), "color: var(--ks-color-text-muted)"
  end

  def test_mobile_header_subtitle_text_reads_the_text_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-text-muted-dark\)/m, block(".ks-mobile-header-subtitle"))
  end

  def test_settings_link_padding_inline_is_4_spacing_units
    assert_includes block(".ks-settings-link"), "padding-inline: calc(var(--ks-spacing) * 4)"
  end

  def test_settings_link_padding_block_is_3_spacing_units
    assert_includes block(".ks-settings-link"), "padding-block: calc(var(--ks-spacing) * 3)"
  end

  def test_settings_link_text_reads_the_text_option_colour_role
    assert_includes block(".ks-settings-link"), "color: var(--ks-color-text-option)"
  end

  def test_settings_link_fill_reads_the_hover_soft_colour_role_on_hover
    assert_match(/:hover.*?background-color: var\(--ks-color-hover-soft\)/m, block(".ks-settings-link"))
  end

  def test_settings_link_text_reads_the_text_option_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-text-option-dark\)/m, block(".ks-settings-link"))
  end

  def test_settings_link_fill_reads_the_hover_soft_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?:hover.*?background-color: var\(--ks-color-hover-soft-dark\)/m, block(".ks-settings-link"))
  end

  def test_color_hover_soft_defaults_to_var_color_gray_50
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-hover-soft: var\(--ks-color-hover\)/m, self.class.compiled)
  end

  def test_color_hover_soft_dark_defaults_to_var_color_gray_800
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-hover-soft-dark: var\(--ks-color-hover-dark\)/m, self.class.compiled)
  end

  def test_settings_link_label_weight_reads_the_medium_font_weight_variable
    assert_includes block(".ks-settings-link-label"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_main_element_clears_the_bottom_nav_on_small_screens
    assert_match(/^  main \{.*?padding-bottom: calc\(56px \+ env\(safe-area-inset-bottom\)\)/m, self.class.compiled)
  end

  def test_panel_border_width_reads_the_border_width_variable
    assert_includes block(".ks-panel"), "border-width: var(--ks-border-width)"
  end

  def test_card_border_width_reads_the_border_width_variable
    assert_includes block(".ks-card"), "border-width: var(--ks-border-width)"
  end

  def test_card_edge_side_border_width_reads_the_border_width_variable_on_wider_screens
    assert_match(/width >= 40rem.*?border-inline-width: var\(--ks-border-width\)/m, block(".ks-card-edge"))
  end

  def test_input_border_width_reads_the_border_width_variable
    assert_includes block(".ks-input"), "border-width: var(--ks-border-width)"
  end

  def test_input_text_reads_the_icon_colour_role_for_its_placeholder
    assert_match(/\&::placeholder.*?\scolor: var\(--ks-color-icon\)/m, block(".ks-input"))
  end

  def test_input_text_reads_the_icon_dark_colour_role_on_a_dark_page_and_for_its_placeholder
    assert_match(/data-theme="dark".*?\&::placeholder.*?\scolor: var\(--ks-color-icon-dark\)/m, block(".ks-input"))
  end

  def test_input_focus_ring_width_reads_the_border_width_variable_on_focus
    assert_match(/\&:focus.*?calc\(var\(--ks-border-width\) \+ var\(--tw-ring-offset-width\)\)/m, block(".ks-input"))
  end

  def test_input_border_reads_the_focus_colour_role_on_focus
    assert_match(/\&:focus.*?border-color: var\(--ks-color-focus\)/m, block(".ks-input"))
  end

  def test_input_border_reads_the_focus_dark_colour_role_on_a_dark_page_and_on_focus
    assert_match(/data-theme="dark".*?\&:focus.*?border-color: var\(--ks-color-focus-dark\)/m, block(".ks-input"))
  end

  def test_input_ring_reads_the_focus_dark_colour_role_on_a_dark_page_and_on_focus
    assert_match(/data-theme="dark".*?\&:focus.*?--tw-ring-color: var\(--ks-color-focus-dark\)/m, block(".ks-input"))
  end

  def test_color_focus_dark_defaults_to_var_color_accent_400
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-focus-dark: var\(--color-accent-400\)/m, self.class.compiled)
  end

  def test_input_disabled_fill_reads_the_hover_colour_role
    assert_includes block(".ks-input-disabled"), "background-color: var(--ks-color-hover)"
  end

  def test_input_disabled_text_reads_the_text_muted_colour_role
    assert_includes block(".ks-input-disabled"), "color: var(--ks-color-text-muted)"
  end

  def test_input_disabled_fill_reads_the_hover_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-hover-dark\)/m, block(".ks-input-disabled"))
  end

  def test_input_disabled_text_reads_the_text_muted_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-text-muted-dark\)/m, block(".ks-input-disabled"))
  end

  def test_label_weight_reads_the_medium_font_weight_variable
    assert_includes block(".ks-label"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_required_margin_left_is_0_5_spacing_units
    assert_includes block(".ks-required"), "margin-left: calc(var(--ks-spacing) * 0.5)"
  end

  def test_hint_margin_top_is_1_spacing_units
    assert_includes block(".ks-hint"), "margin-top: calc(var(--ks-spacing) * 1)"
  end

  def test_error_margin_top_is_1_spacing_units
    assert_includes block(".ks-error"), "margin-top: calc(var(--ks-spacing) * 1)"
  end

  def test_error_text_reads_the_danger_400_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-danger-400\)/m, block(".ks-error"))
  end

  def test_checkbox_radius_is_0_5_of_the_control_radius
    assert_includes block(".ks-checkbox"), "border-radius: calc(var(--ks-radius-control) * 0.5)"
  end

  def test_checkbox_border_reads_the_border_strong_colour_role
    assert_includes block(".ks-checkbox"), "border-color: var(--ks-color-border-strong)"
  end

  def test_checkbox_ring_reads_the_focus_colour_role_on_focus
    assert_match(/\&:focus.*?--tw-ring-color: var\(--ks-color-focus\)/m, block(".ks-checkbox"))
  end

  def test_checkbox_border_reads_the_border_strong_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-strong-dark\)/m, block(".ks-checkbox"))
  end

  def test_checkbox_fill_reads_the_surface_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-surface-dark\)/m, block(".ks-checkbox"))
  end

  def test_page_header_subtitle_margin_top_is_1_spacing_units
    assert_includes block(".ks-page-header-subtitle"), "margin-top: calc(var(--ks-spacing) * 1)"
  end

  def test_page_header_actions_margin_top_is_4_spacing_units
    assert_includes block(".ks-page-header-actions"), "margin-top: calc(var(--ks-spacing) * 4)"
  end

  def test_page_header_actions_margin_left_is_4_spacing_units_on_wider_screens
    assert_match(/width >= 40rem.*?margin-left: calc\(var\(--ks-spacing\) \* 4\)/m, block(".ks-page-header-actions"))
  end

  def test_section_header_margin_bottom_is_4_spacing_units
    assert_includes block(".ks-section-header"), "margin-bottom: calc(var(--ks-spacing) * 4)"
  end

  def test_section_subtitle_margin_top_is_1_spacing_units
    assert_includes block(".ks-section-subtitle"), "margin-top: calc(var(--ks-spacing) * 1)"
  end

  def test_card_summary_margin_top_is_1_spacing_units
    assert_includes block(".ks-card-summary"), "margin-top: calc(var(--ks-spacing) * 1)"
  end

  def test_section_action_text_reads_the_link_strong_hover_colour_role_on_hover
    assert_match(/:hover.*?\scolor: var\(--ks-color-link-strong-hover\)/m, block(".ks-section-action"))
  end

  def test_section_action_text_reads_the_link_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-link-dark\)/m, block(".ks-section-action"))
  end

  def test_section_action_text_reads_the_link_strong_hover_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?:hover.*?\scolor: var\(--ks-color-link-strong-hover-dark\)/m, block(".ks-section-action"))
  end

  def test_color_link_strong_hover_defaults_to_var_color_accent_900
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-link-strong-hover: var\(--color-accent-900\)/m, self.class.compiled)
  end

  def test_color_link_strong_hover_dark_defaults_to_var_color_accent_300
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-link-strong-hover-dark: var\(--color-accent-300\)/m, self.class.compiled)
  end

  def test_card_link_weight_reads_the_medium_font_weight_variable
    assert_includes block(".ks-card-link"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_card_link_text_reads_the_link_strong_hover_colour_role_on_hover
    assert_match(/:hover.*?\scolor: var\(--ks-color-link-strong-hover\)/m, block(".ks-card-link"))
  end

  def test_card_link_text_reads_the_link_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-link-dark\)/m, block(".ks-card-link"))
  end

  def test_alert_dismiss_right_margin_pulls_in_1_5_spacing_units
    assert_includes block(".ks-alert-dismiss"), "margin-right: calc(calc(var(--ks-spacing) * 1.5) * -1)"
  end

  def test_alert_dismiss_top_margin_pulls_in_1_5_spacing_units
    assert_includes block(".ks-alert-dismiss"), "margin-top: calc(calc(var(--ks-spacing) * 1.5) * -1)"
  end

  def test_alert_dismiss_radius_is_0_75_of_the_control_radius
    assert_includes block(".ks-alert-dismiss"), "border-radius: calc(var(--ks-radius-control) * 0.75)"
  end

  def test_alert_dismiss_padding_is_1_5_spacing_units
    assert_includes block(".ks-alert-dismiss"), "padding: calc(var(--ks-spacing) * 1.5)"
  end

  def test_alert_dismiss_focus_ring_is_twice_the_border_width_on_focus
    assert_match(/\&:focus.*?calc\(calc\(var\(--ks-border-width\) \* 2\) \+ var\(--tw-ring-offset-width\)\)/m, block(".ks-alert-dismiss"))
  end

  def test_alert_dismiss_focus_ring_gap_is_twice_the_border_width_on_focus
    assert_match(/\&:focus.*?--tw-ring-offset-width: calc\(var\(--ks-border-width\) \* 2\)/m, block(".ks-alert-dismiss"))
  end

  def test_badge_padding_inline_is_2_spacing_units
    assert_includes block(".ks-badge"), "padding-inline: calc(var(--ks-spacing) * 2)"
  end

  def test_badge_padding_block_is_1_spacing_units
    assert_includes block(".ks-badge"), "padding-block: calc(var(--ks-spacing) * 1)"
  end

  def test_badge_weight_reads_the_medium_font_weight_variable
    assert_includes block(".ks-badge"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_badge_neutral_text_reads_the_text_label_colour_role
    assert_includes block(".ks-badge-neutral"), "color: var(--ks-color-text-label)"
  end

  def test_badge_neutral_fill_reads_the_badge_neutral_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-badge-neutral-dark\)/m, block(".ks-badge-neutral"))
  end

  def test_badge_neutral_text_reads_the_text_label_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-text-label-dark\)/m, block(".ks-badge-neutral"))
  end

  def test_color_badge_neutral_defaults_to_var_color_gray_100
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-badge-neutral: var\(--color-gray-100\)/m, self.class.compiled)
  end

  def test_color_badge_neutral_dark_defaults_to_var_color_zinc_700
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-badge-neutral-dark: var\(--color-zinc-700\)/m, self.class.compiled)
  end

  def test_grid_gap_sm_gap_is_3_spacing_units
    assert_includes block(".ks-grid-gap-sm"), "gap: calc(var(--ks-spacing) * 3)"
  end

  def test_grid_gap_x_sm_column_gap_is_3_spacing_units
    assert_includes block(".ks-grid-gap-x-sm"), "column-gap: calc(var(--ks-spacing) * 3)"
  end

  def test_grid_gap_y_sm_row_gap_is_3_spacing_units
    assert_includes block(".ks-grid-gap-y-sm"), "row-gap: calc(var(--ks-spacing) * 3)"
  end

  def test_grid_gap_md_gap_is_4_spacing_units
    assert_includes block(".ks-grid-gap-md"), "gap: calc(var(--ks-spacing) * 4)"
  end

  def test_grid_gap_x_md_column_gap_is_4_spacing_units
    assert_includes block(".ks-grid-gap-x-md"), "column-gap: calc(var(--ks-spacing) * 4)"
  end

  def test_grid_gap_y_md_row_gap_is_4_spacing_units
    assert_includes block(".ks-grid-gap-y-md"), "row-gap: calc(var(--ks-spacing) * 4)"
  end

  def test_grid_gap_lg_gap_is_6_spacing_units
    assert_includes block(".ks-grid-gap-lg"), "gap: calc(var(--ks-spacing) * 6)"
  end

  def test_grid_gap_x_lg_column_gap_is_6_spacing_units
    assert_includes block(".ks-grid-gap-x-lg"), "column-gap: calc(var(--ks-spacing) * 6)"
  end

  def test_grid_gap_y_lg_row_gap_is_6_spacing_units
    assert_includes block(".ks-grid-gap-y-lg"), "row-gap: calc(var(--ks-spacing) * 6)"
  end

  def test_grid_gap_xl_gap_is_8_spacing_units
    assert_includes block(".ks-grid-gap-xl"), "gap: calc(var(--ks-spacing) * 8)"
  end

  def test_grid_gap_x_xl_column_gap_is_8_spacing_units
    assert_includes block(".ks-grid-gap-x-xl"), "column-gap: calc(var(--ks-spacing) * 8)"
  end

  def test_grid_gap_y_xl_row_gap_is_8_spacing_units
    assert_includes block(".ks-grid-gap-y-xl"), "row-gap: calc(var(--ks-spacing) * 8)"
  end

  def test_form_vertical_gap_between_children_is_6_spacing_units
    assert_match(/\.ks-form(?![\w-]).*?:not\(:last-child\).*?calc\(var\(--ks-spacing\) \* 6\)/m, self.class.compiled)
  end

  def test_form_field_vertical_gap_between_children_is_1_spacing_units
    assert_match(/\.ks-form-field(?![\w-]).*?:not\(:last-child\).*?calc\(var\(--ks-spacing\) \* 1\)/m, self.class.compiled)
  end

  def test_form_field_checkbox_gap_is_2_spacing_units
    assert_includes block(".ks-form-field-checkbox"), "gap: calc(var(--ks-spacing) * 2)"
  end

  def test_theme_toggle_gap_is_1_spacing_units
    assert_includes block(".ks-theme-toggle"), "gap: calc(var(--ks-spacing) * 1)"
  end

  def test_color_picker_label_margin_bottom_is_1_spacing_units
    assert_includes block(".ks-color-picker-label"), "margin-bottom: calc(var(--ks-spacing) * 1)"
  end

  def test_settings_link_chevron_text_reads_the_close_colour_role
    assert_includes block(".ks-settings-link-chevron"), "color: var(--ks-color-close)"
  end

  def test_page_title_weight_reads_the_heading_font_weight_variable
    assert_includes block(".ks-page-title"), "font-weight: var(--ks-font-weight-heading)"
  end

  def test_page_title_text_reads_the_text_colour_role
    assert_includes block(".ks-page-title"), "color: var(--ks-color-text)"
  end

  def test_page_title_text_reads_the_text_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?\scolor: var\(--ks-color-text-dark\)/m, block(".ks-page-title"))
  end

  def test_only_the_bottom_nav_rules_are_kept_to_narrow_screens
    narrow_screens = self.class.compiled[/^@media \(max-width: 1023px\) \{\n(.*?)^\}\n/m, 1].to_s

    assert_equal [ ".hotwire-native .ks-bottom-nav" ], narrow_screens.scan(/^  ([^{\n]*\.ks-[^{\n]*?) \{/).flatten
  end

  def test_radio_card_info_text_reads_the_close_colour_role
    assert_includes block(".ks-radio-card-info"), "color: var(--ks-color-close)"
  end

  def test_radio_card_info_text_reads_the_link_colour_role_on_hover
    assert_match(/:hover.*?color: var\(--ks-color-link\)/m, block(".ks-radio-card-info"))
  end

  def test_radio_card_info_text_reads_the_link_dark_colour_role_on_a_dark_page_and_on_hover
    assert_match(/data-theme="dark".*?:hover.*?color: var\(--ks-color-link-dark\)/m, block(".ks-radio-card-info"))
  end

  def test_radio_card_disclosure_margin_top_is_2_spacing_units
    assert_includes block(".ks-radio-card-disclosure"), "margin-top: calc(var(--ks-spacing) * 2)"
  end

  def test_radio_card_disclosure_radius_reads_the_surface_radius
    assert_includes block(".ks-radio-card-disclosure"), "border-radius: var(--ks-radius-surface)"
  end

  def test_radio_card_disclosure_border_width_reads_the_border_width_variable
    assert_includes block(".ks-radio-card-disclosure"), "border-width: var(--ks-border-width)"
  end

  def test_radio_card_disclosure_border_reads_the_border_colour_role
    assert_includes block(".ks-radio-card-disclosure"), "border-color: var(--ks-color-border)"
  end

  def test_radio_card_disclosure_fill_reads_the_overlay_colour_role
    assert_includes block(".ks-radio-card-disclosure"), "background-color: var(--ks-color-overlay)"
  end

  def test_radio_card_disclosure_padding_is_3_spacing_units
    assert_includes block(".ks-radio-card-disclosure"), "padding: calc(var(--ks-spacing) * 3)"
  end

  def test_radio_card_disclosure_text_reads_the_text_secondary_colour_role
    assert_includes block(".ks-radio-card-disclosure"), "color: var(--ks-color-text-secondary)"
  end

  def test_radio_card_disclosure_shadow_reads_the_overlay_shadow_variable
    assert_includes block(".ks-radio-card-disclosure"), "--tw-shadow: var(--ks-shadow-overlay)"
  end

  def test_radio_card_disclosure_border_reads_the_border_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-radio-card-disclosure"))
  end

  def test_radio_card_disclosure_fill_reads_the_overlay_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-overlay-dark\)/m, block(".ks-radio-card-disclosure"))
  end

  def test_radio_card_disclosure_text_reads_the_text_secondary_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-secondary-dark\)/m, block(".ks-radio-card-disclosure"))
  end

  def test_radio_card_disclosure_vertical_gap_between_children_is_1_spacing_units
    assert_match(/:not\(:last-child\).*?calc\(var\(--ks-spacing\) \* 1\)/m, block(".ks-radio-card-disclosure"))
  end

  def test_breakdown_lays_its_amounts_and_labels_out_on_a_grid
    assert_includes block(".ks-breakdown"), "display: grid"
  end

  def test_breakdown_gives_its_amounts_a_column_as_wide_as_the_widest_and_its_labels_the_rest
    assert_includes block(".ks-breakdown"), "grid-template-columns: max-content 1fr"
  end

  def test_breakdown_column_gap_is_3_spacing_units
    assert_includes block(".ks-breakdown"), "column-gap: calc(var(--ks-spacing) * 3)"
  end

  def test_breakdown_row_gap_is_1_spacing_units
    assert_includes block(".ks-breakdown"), "row-gap: calc(var(--ks-spacing) * 1)"
  end

  def test_breakdown_line_hands_its_amount_and_label_to_the_grid
    assert_includes block(".ks-breakdown-line"), "display: contents"
  end

  def test_breakdown_total_hands_its_amount_and_label_to_the_grid
    assert_includes block(".ks-breakdown-total"), "display: contents"
  end

  def test_breakdown_amount_lines_up_on_the_right
    assert_includes block(".ks-breakdown-amount"), "text-align: right"
  end

  def test_breakdown_amount_uses_figures_of_one_width
    assert_includes block(".ks-breakdown-amount"), "tabular-nums"
  end

  def test_breakdown_amount_never_wraps
    assert_includes block(".ks-breakdown-amount"), "white-space: nowrap"
  end

  def test_breakdown_sum_has_a_rule_above_it
    assert_includes block(".ks-breakdown-sum"), "border-top-width: var(--ks-border-width)"
  end

  def test_breakdown_sum_rule_reads_the_border_colour_role
    assert_includes block(".ks-breakdown-sum"), "border-color: var(--ks-color-border)"
  end

  def test_breakdown_sum_rule_reads_the_border_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-color: var\(--ks-color-border-dark\)/m, block(".ks-breakdown-sum"))
  end

  def test_breakdown_sum_sits_1_spacing_unit_below_its_rule
    assert_includes block(".ks-breakdown-sum"), "padding-top: calc(var(--ks-spacing) * 1)"
  end

  def test_breakdown_sum_reads_the_medium_font_weight
    assert_includes block(".ks-breakdown-sum"), "font-weight: var(--ks-font-weight-medium)"
  end

  def test_info_popup_wraps_its_text_inside_a_table
    assert_includes block(".ks-info-popup"), "white-space: normal"
  end

  def test_info_popup_never_grows_wider_than_the_screen
    assert_includes block(".ks-info-popup"), "max-width: calc(100vw - 16px)"
  end

  def test_info_popup_lines_its_text_up_on_the_left
    assert_includes block(".ks-info-popup"), "text-align: left"
  end

  def test_color_funnel_band_defaults_to_var_color_surface_800
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-funnel-band: var\(\-\-color\-surface\-800\)/m, self.class.compiled)
  end

  def test_color_funnel_band_dark_defaults_to_var_color_surface_100
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-funnel-band-dark: var\(\-\-color\-surface\-100\)/m, self.class.compiled)
  end

  def test_color_text_funnel_band_defaults_to_var_color_white
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-funnel-band: var\(\-\-color\-white\)/m, self.class.compiled)
  end

  def test_color_text_funnel_band_dark_defaults_to_var_color_surface_900
    assert_match(/@layer base \{.*?:root \{.*?--ks-color-text-funnel-band-dark: var\(\-\-color\-surface\-900\)/m, self.class.compiled)
  end

  def test_funnel_band_fill_reads_the_funnel_band_colour_role
    assert_includes block(".ks-funnel-band"), "background-color: var(--ks-color-funnel-band)"
  end

  def test_funnel_band_fill_reads_the_funnel_band_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-funnel-band-dark\)/m, block(".ks-funnel-band"))
  end

  def test_funnel_band_label_fill_reads_the_funnel_band_colour_role
    assert_includes block(".ks-funnel-band-label"), "background-color: var(--ks-color-funnel-band)"
  end

  def test_funnel_band_label_fill_reads_the_funnel_band_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-funnel-band-dark\)/m, block(".ks-funnel-band-label"))
  end

  def test_funnel_band_label_text_reads_the_text_funnel_band_colour_role
    assert_includes block(".ks-funnel-band-label"), "color: var(--ks-color-text-funnel-band)"
  end

  def test_funnel_band_label_text_reads_the_text_funnel_band_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-funnel-band-dark\)/m, block(".ks-funnel-band-label"))
  end

  def test_funnel_band_label_radius_reads_the_pill_radius
    assert_includes block(".ks-funnel-band-label"), "border-radius: var(--ks-radius-pill)"
  end

  def test_funnel_band_label_padding_inline_is_2_spacing_units
    assert_includes block(".ks-funnel-band-label"), "padding-inline: calc(var(--ks-spacing) * 2)"
  end

  def test_funnel_band_label_weight_reads_the_strong_font_weight_variable
    assert_includes block(".ks-funnel-band-label"), "font-weight: var(--ks-font-weight-strong)"
  end

  def test_funnel_joined_column_gap_is_4_spacing_units
    assert_includes block(".ks-funnel-joined"), "column-gap: calc(var(--ks-spacing) * 4)"
  end

  def test_locked_header_cell_fill_reads_the_table_head_colour_role
    assert_includes block(".ks-table-header-locked"), "background-color: var(--ks-color-table-head)"
  end

  def test_locked_header_cell_fill_reads_the_table_head_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-table-head-dark\)/m, block(".ks-table-header-locked"))
  end

  def test_locked_body_cell_fill_reads_the_table_body_colour_role
    assert_includes block(".ks-table-cell-locked"), "background-color: var(--ks-color-table-body)"
  end

  def test_locked_body_cell_fill_reads_the_table_body_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?background-color: var\(--ks-color-table-body-dark\)/m, block(".ks-table-cell-locked"))
  end

  def test_locked_header_cell_shows_an_edge_on_its_right
    assert_includes block(".ks-table-header-locked"), "border-right-width: var(--ks-border-width)"
  end

  def test_locked_header_cell_edge_reads_the_border_colour_role
    assert_includes block(".ks-table-header-locked"), "border-right-color: var(--ks-color-border)"
  end

  def test_locked_header_cell_edge_reads_the_border_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-right-color: var\(--ks-color-border-dark\)/m, block(".ks-table-header-locked"))
  end

  def test_locked_body_cell_shows_an_edge_on_its_right
    assert_includes block(".ks-table-cell-locked"), "border-right-width: var(--ks-border-width)"
  end

  def test_locked_body_cell_edge_reads_the_border_colour_role
    assert_includes block(".ks-table-cell-locked"), "border-right-color: var(--ks-color-border)"
  end

  def test_locked_body_cell_edge_reads_the_border_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?border-right-color: var\(--ks-color-border-dark\)/m, block(".ks-table-cell-locked"))
  end

  def test_table_head_shows_no_edge_on_its_right
    refute_includes block(".ks-table-head"), "border-right-width"
  end

  def test_menu_move_button_pads_its_arrow
    assert_includes block(".ks-menu-move"), "padding-inline: calc(var(--ks-spacing) * 2)"
  end

  def test_menu_move_button_reads_the_label_text_colour_role
    assert_includes block(".ks-menu-move"), "color: var(--ks-color-text-label)"
  end

  def test_menu_move_button_reads_the_label_text_dark_colour_role_on_a_dark_page
    assert_match(/data-theme="dark".*?color: var\(--ks-color-text-label-dark\)/m, block(".ks-menu-move"))
  end

  def test_menu_move_button_fills_with_the_hover_colour_role_under_the_pointer
    assert_match(/:hover.*?background-color: var\(--ks-color-hover\)/m, block(".ks-menu-move"))
  end

  def test_menu_move_button_fades_when_it_cannot_move_its_column
    assert_match(/:disabled.*?opacity: 40%/m, block(".ks-menu-move"))
  end

  private

  def block(selector)
    self.class.compiled[/^  #{Regexp.escape(selector)} \{\n(.*?)^  \}\n/m, 1].to_s
  end

  def rule(selector)
    self.class.compiled[/^\s*#{Regexp.escape(selector)}\s*\{(.*?)\}/m, 1].to_s
  end
end
