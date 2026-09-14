# Changelog

## [Unreleased]

## [0.1.1] - 2026-09-14

### Fixed
- Host apps no longer get a generated `app/assets/builds/tailwind/keystone_ui_styles.css`. With `stylesheet_link_tag :app`, that file made the browser request a path inside the installed gem and raise a routing error.

### Added
- `KeystoneUi::Styles.tailwind_file` returns the path of the Tailwind file.

### Upgrading
- Delete a leftover `app/assets/builds/tailwind/keystone_ui_styles.css`, or run `rails tailwindcss:clobber` once.

## [0.1.0] - 2026-09-14

Initial release.

- Color variables for the accent and surface scales.
- Light and dark mode that follows the operating system unless the page sets `data-theme`.
- Button, panel and form field classes.
- A Rails engine so tailwindcss-rails compiles the entry file in host apps.
