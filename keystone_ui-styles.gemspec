# frozen_string_literal: true

require_relative "lib/keystone_ui/styles/version"

Gem::Specification.new do |spec|
  spec.name = "keystone_ui-styles"
  spec.version = KeystoneUi::Styles::VERSION
  spec.authors = [ "Tyler Schneider" ]
  spec.email = [ "tylercschneider@gmail.com" ]

  spec.summary = "Shared CSS for keystone_ui and keystone_ui-react."
  spec.description = "Color variables, light and dark mode, and component classes shared by keystone_ui and keystone_ui-react."
  spec.homepage = "https://github.com/DYB-Development/keystone_ui-styles"
  spec.license = "MIT"

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "#{spec.homepage}#readme"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir["lib/**/*", "app/**/*"] + [ "MIT-LICENSE" ]
  spec.require_paths = [ "lib" ]

  spec.add_dependency "railties", ">= 7.0"
end
