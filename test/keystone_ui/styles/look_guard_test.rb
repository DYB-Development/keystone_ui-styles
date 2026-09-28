# frozen_string_literal: true

require "test_helper"

class KeystoneUi::Styles::LookGuardTest < Minitest::Test
  STYLESHEET = File.expand_path("../../../app/assets/tailwind/keystone_ui_styles/engine.css", __dir__)
  LOOK_UTILITY = /\A-?(bg|text|border|rounded|shadow|ring|ring-offset|font|divide|p[xytblr]?|m[xytblr]?|gap|space-[xy])(-|\z)/
  NOT_A_LOOK_VALUE = /\A(text-(xs|sm|base|lg|\d?xl|\[\d+px\]|left|center|right|nowrap)|border-dashed|-?m[xytblr]?-(0|auto)|p[xytblr]?-0|font-mono)\z/

  def test_no_ks_class_holds_a_fixed_look_value
    assert_empty fixed_look_values
  end

  def test_every_ks_variable_a_class_reads_has_a_default
    assert_empty components_layer.scan(/--ks-[\w-]*[\w]/).uniq - defaults
  end

  private

  def defaults
    File.read(STYLESHEET)[/@layer base \{\n  :root \{(.*?)\n  \}/m, 1].scan(/(--ks-[\w-]+):/).flatten
  end

  def fixed_look_values
    ks_class_tokens.filter_map do |selector, token|
      utility = token.split(":").last
      next if token.include?("--ks-") || token.include?("env(") || NOT_A_LOOK_VALUE.match?(utility)

      "#{selector} #{token}" if LOOK_UTILITY.match?(utility)
    end
  end

  def ks_class_tokens
    components_layer.scan(/^  (\.ks-[^{]+?) \{\n    @apply ([^;]+);/).flat_map do |selector, tokens|
      tokens.split.map { |token| [ selector, token ] }
    end
  end

  def components_layer
    File.read(STYLESHEET)[/@layer components \{.*/m]
  end
end
