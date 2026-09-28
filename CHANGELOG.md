# Changelog

## [Unreleased]

### Added
- Classes for the bottom nav, nav dropdown, nav item, navbar title, mobile header and settings link, which draw from `--ks-` variables and have visible colours in a host that sets none.
- The navigation colours read the old `--base-*` variables first, so a host that set them keeps its nav colours.

### Added
- Classes for the stat card, chart card, card link, call to action banner, feature grid, hero, data table, code, accordion, disclosure, tab switcher, progress, funnel, bucket, pipeline and swipe deck, which draw what those components draw today from `--ks-` variables.
- The funnel's five step colours and the bucket's over-goal colours are colour roles a look can set.

### Added
- Classes for the dialog, action menu, column picker and multi select menus, copy button, theme toggle, checkbox row, radio card, option card, file upload and colour picker, which draw what those components draw today from `--ks-` variables.

### Added
- Panels, cards, inputs, labels, hints, alerts, badges, pages, sections and page headers take their colours, corner radius, title weight and padding from `--ks-` variables, and look the same until a variable is set.
- Alerts and badges take their colours from a shade scale per status, which a look can set.
- Panel radius, padding and shadow classes that read the same variables, for keystone_ui's panel to render.

## [0.4.0] - 2026-09-27

### Added
- Buttons take their corner radius, font, label weight, border width, padding and colours from `--ks-` variables, so a host restyles every button by setting those variables. Buttons look the same until a variable is set.

## [0.3.0] - 2026-09-24

### Added
- A page marked custom is drawn from a background colour and a text colour, and stays light when the operating system is dark.

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
