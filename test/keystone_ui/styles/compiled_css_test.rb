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
end
