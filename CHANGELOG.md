# Changelog

## [Unreleased]

### Changed
- The `html` element tells the browser a dark page is dark, and lets the browser follow the device on a page that follows the device, so a page left on the default background turns dark with dark mode instead of showing light text on a white page.

## [0.20.0] - 2026-10-15

### Added
- `ks-value-list-row`, `ks-value-list-label`, `ks-value-list-note` and `ks-value-list-value` draw rows of a label and its value, with a line between rows, a muted note under the label and digits of equal width.
- `ks-value-list-end` on the list pushes each value to the right end of its row and aligns it right, as amounts in a ledger are.
- `ks-value-list-total` draws a row in the strong weight with its label in the text colour, for a total.

## [0.19.0] - 2026-10-15

### Added
- `ks-heading` draws a heading in the heading font, heading weight and text colour, and `ks-heading-sm`, `ks-heading-md` and `ks-heading-lg` set its size.
- `ks-heading-row` and `ks-heading-note` place a short muted note at the right end of a heading's row.
- `ks-caption` draws small, uppercase, widely spaced muted text for placing above a title or figure.
- `ks-paragraph` draws running text in the text colour with relaxed line spacing.

## [0.18.0] - 2026-10-15

### Added
- `--ks-color-page` and `--ks-color-on-page` and their `-dark` partners set the `html` element background and text, defaulting to transparent and the browser text colour so a page looks as it did.
- `--ks-color-on-accent`, `--ks-color-on-neutral` and `--ks-color-on-danger` and their `-dark` partners set the primary, secondary and danger button labels, defaulting to `--ks-color-on-fill`.
- `--ks-color-on-overlay` and its `-dark` partner set the text of the dialog, action menu and colour picker, defaulting to the colour each inherits.
- `--ks-color-on-overlay-muted` and its `-dark` partner set the text of the radio card and stat card disclosures, defaulting to `--ks-color-text-secondary`.
- `--ks-color-on-surface` and its `-dark` partner set the text of the menu, defaulting to the colour it inherits.
- `--ks-color-on-hover` and its `-dark` partner set the text of a hovered settings link and tab, defaulting to `--ks-color-text`.
- `--ks-color-on-hover-muted` and its `-dark` partner set the text of a hovered menu option, menu move button and copy button, defaulting to `--ks-color-text-label`.
- The `body` element reads `--ks-font-body` for its font, which still defaults to `inherit` so the page keeps its font.
- `--ks-font-heading` sets the page, page header, section, card, modal and navbar title font, defaulting to `--ks-font-body`.
- `--ks-font-mono` holds a theme's mono font, defaulting to the font list Tailwind gives code, and code keeps reading Tailwind's `--default-mono-font-family`, which a theme writer sets from it.
- `--ks-letter-spacing` sets the `body` element letter spacing, defaulting to `normal`.

## [0.17.0] - 2026-10-14

### Added
- `--ks-color-chart-1` to `--ks-color-chart-5` and their `-dark` partners give charts five series colours, chart 1 from the accent and charts 2 to 5 teal, amber, violet and rose, which a look or palette can replace.

## [0.16.0] - 2026-10-13

### Added
- `ks-sidebar-group-tabs` draws a rounded border in the nav border colour around an open sidebar group's links, inset under the group label, light and dark.
- Each sidebar tab after the first inside `ks-sidebar-group-tabs` has a dividing line above it in the nav border colour, light and dark, while a tab outside any group has none.
- Each `ks-nav-item` after the first inside `ks-nav-dropdown-menu` has a dividing line above it in the nav border colour, light and dark.

## [0.15.0] - 2026-10-10

### Added
- `ks-sidebar-logo` gives the sidebar's logo its own padding and removes its underline.

### Fixed
- The sidebar's tabs show no underline whatever the host's link styles, each tab takes the same height, and groups are spaced apart.
- The current sidebar tab is marked by a straight bar along its edge, visible in light and dark.
- The sidebar draws a border on the side that faces the page content, so it stands apart from a page of the same colour.

### Changed
- `ks-sidebar-group-label` works as the label of a group that opens and closes: it hides the browser's disclosure triangle, shows a pointer, puts a caret at its far edge that turns when the group is open, and shows the group holding the current tab in the nav active colour, light and dark.

## [0.14.0] - 2026-10-10

### Added
- `ks-sidebar`, `ks-sidebar-group-label` and `ks-sidebar-tab` style a vertical navigation panel, its group labels and its tabs, with the current tab marked by `active`, in the nav colours, the spacing setting and the control radius, light and dark.

## [0.13.0] - 2026-10-07

### Added
- `ks-table-toolbar` leaves a gap between a data table and the row above it that holds its Columns menu.

## [0.12.0] - 2026-10-07

### Added
- `ks-page-back` and `ks-breadcrumbs` leave space between a page's desktop Back link or breadcrumbs and the content under them, and keep the Back link close above the breadcrumbs.

## [0.11.0] - 2026-10-06

### Changed
- `ks-menu-checkbox` is larger, with a heavy outline and an accent-coloured tick, so a ticked and an empty box read apart at a glance.

### Added
- `ks-table-header-locked` and `ks-table-cell-locked` give a locked table cell the table head's or body's background in light and dark themes, and an edge on its right side.
- `ks-menu-option-hidden` greys the name of a column the Columns menu has hidden.
- `ks-menu-move` styles the Columns menu's up and down buttons, fading a button that cannot move its column.

## [0.10.0] - 2026-10-06

### Added
- Classes and colour roles for the joined funnel: the space between its words and its shape, and the neutral band between steps with its percent label.

## [0.9.0] - 2026-10-01

### Added
- A breakdown sets its amounts out as an equation: right-aligned in one column, labels beside them, and the total below a theme-coloured rule.
- An info popup wraps its text even inside a table and is never wider than the screen.

## [0.8.0] - 2026-09-30

### Added
- A radio card's info button and the panel holding its info, styled like the stat card's info button and panel, in light and dark mode.

## [0.7.1] - 2026-09-28

### Fixed
- Grid gaps, form spacing, the theme toggle and colour picker spacing, the settings link chevron and page titles apply on wide screens again, where 0.7.0 applied them only below 1024px.

## [0.7.0] - 2026-09-28

### Changed
- Near-duplicate colour roles now default to one base role each, so a look recolours every component that shares a purpose by setting one variable. Every role still exists, so a look that sets one on its own still applies.
- The base text, muted text, secondary text, label, icon, border, strong border, surface, overlay and hover roles draw from the surface scale instead of gray and zinc, so keystone_ui-colors' per-account palette reaches every component.

### Upgrading
- Components that drew gray shades now draw the matching surface shade, which defaults to zinc, so their grays turn slightly more neutral.
- On a dark page the dialog title, table header, radio card label and checkbox row label turn white instead of light gray.
- On a dark page inputs and menu triggers get a zinc 600 border instead of zinc 700, the table head and body match the surface and hover backgrounds, the line between table rows matches the border colour, and the copy button and settings link hover match the menu hover.
- The radio card hint turns surface 400 on a dark page instead of gray 400.
- The custom theme mode blends gray and zinc, so it no longer changes the colours these roles draw.

## [0.6.0] - 2026-09-28

### Added
- The test suite fails, naming the class and value, when a `ks-` class holds a fixed colour, radius, weight, shadow, border or spacing value.
- The test suite fails, naming the variable, when a `ks-` class reads a `--ks-` variable that has no default.
- Classes for the grid's gaps, form and form field spacing, the theme toggle's gap, the colour picker's label spacing, the settings link's arrow colour and the form and show page title, so keystone_ui's remaining components can move their spacing and colours onto `--ks-` variables.

### Changed
- Every `ks-` class takes its colours, corner radius, font weight, border widths, margins and padding from `--ks-` variables, including the input focus ring and placeholder, the disabled input, the checkbox, field hints and errors, page and section spacing, section actions, card links, the alert dismiss button and badges. Nothing changes on screen until a variable is set.
- `--ks-font-body` defaults to `inherit`, so a button keeps the page's font as before.

## [0.5.0] - 2026-09-27

### Added
- Panels, cards, inputs, labels, hints, alerts, badges, pages, sections and page headers take their colours, corner radius, title weight and padding from `--ks-` variables, and look the same until a variable is set.
- Alerts and badges take their colours from a shade scale per status, which a look can set.
- Panel radius, padding and shadow classes that read the same variables, for keystone_ui's panel to render.
- Classes for the dialog, action menu, column picker and multi select menus, copy button, theme toggle, checkbox row, radio card, option card, file upload and colour picker, which draw what those components draw today from `--ks-` variables.
- Classes for the stat card, chart card, card link, call to action banner, feature grid, hero, data table, code, accordion, disclosure, tab switcher, progress, funnel, bucket, pipeline and swipe deck, which draw what those components draw today from `--ks-` variables.
- The funnel's five step colours and the bucket's over-goal colours are colour roles a look can set.
- Classes for the bottom nav, nav dropdown, nav item, navbar title, mobile header and settings link, which draw from `--ks-` variables and have visible colours in a host that sets none.
- The navigation colours read the old `--base-*` variables first, so a host that set them keeps its nav colours.

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
