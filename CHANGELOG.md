# Changelog

## [Unreleased]

## [0.2.0] - 2026-09-15

### Added
- Shared classes for keystone_ui's page, page header, section, card, alert and badge, matching how keystone_ui styles those components today.

## [0.1.2] - 2026-09-14

### Fixed
- A host app that ran its Tailwind build with keystone_ui-styles 0.1.0 no longer keeps `app/assets/builds/tailwind/keystone_ui_styles.css` after upgrading. The gem deletes that file when the host app boots, and leaves the folder's other files alone.

### Upgrading
- No manual step. The 0.1.1 advice to run `rails tailwindcss:clobber` did not remove this file, and deleting it by hand is no longer needed.

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
