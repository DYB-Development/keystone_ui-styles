# keystone_ui-styles

Shared CSS for [keystone_ui](https://github.com/DYB-Development/keystone_ui) and
keystone_ui-react: keystone's color variables, its light and dark mode, and the
classes for buttons, panels and form fields.

Host apps do not install this gem directly. keystone_ui depends on it and brings it
into the host's Tailwind build.

## Requirements

- Rails 7.0 or later
- [tailwindcss-rails](https://github.com/rails/tailwindcss-rails) 4 or later

## How a host gets it

keystone_ui imports keystone_ui-styles into the host's Tailwind build through the
`keystone_source.css` file it writes at boot. A host imports nothing for
keystone_ui-styles itself.

A gem that needs the file directly can read its path from
`KeystoneUi::Styles.tailwind_file`.

## Colors

`--color-accent-50` to `--color-accent-950` default to Tailwind's blue, and
`--color-surface-50` to `--color-surface-950` default to zinc. keystone_ui-colors
overrides these variables on the page, and every class below reads them.

## Light and dark mode

A page follows the operating system's setting. Setting `data-theme` on the `html`
element overrides it:

```html
<html data-theme="dark">   <!-- always dark -->
<html data-theme="light">  <!-- always light -->
<html data-theme="custom"> <!-- drawn from a background and a text colour -->
<html>                     <!-- follows the operating system -->
```

The `dark:` variant in the host's own Tailwind classes follows the same rule, and
a custom page never takes it.

On a custom page, white is `--color-custom-background`, and every `gray-*` and
`zinc-*` shade is a blend of `--color-custom-text` into that background, from 3%
at shade 50 to 100% at shade 950. They default to white and `#18181b`, and
keystone_ui-colors sets them from the colours a user picks.

## Look variables

The classes below read these variables, so a host restyles every component that
renders them by setting the variables in a plain `:root` rule in its own
stylesheet. The defaults sit in Tailwind's base layer, so a `:root` rule outside
any layer overrides them wherever it is imported.

| Variable | Sets | Default |
|---|---|---|
| `--ks-radius-control` | Button corner radius, and three quarters of it for inputs | `--radius-lg` |
| `--ks-radius-surface` | Card and panel corner radius, and three quarters of it for alerts | `--radius-lg` |
| `--ks-shadow-surface` | Panel shadow | `--shadow-sm` |
| `--ks-font-body` | Button font family | `inherit`, so a button keeps the page's font |
| `--ks-font-weight-strong` | Button label weight | `--font-weight-semibold` |
| `--ks-font-weight-heading` | Section, card and alert title weight, and one step heavier for page titles | `--font-weight-semibold` |
| `--ks-border-width-control` | Button border width | `0px` |
| `--ks-spacing` | The unit every button, input, page, card, alert and panel padding is a multiple of | `--spacing` |
| `--ks-color-accent`, `--ks-color-accent-hover` | Primary button fill, and on hover | `--color-accent-600`, `--color-accent-500` |
| `--ks-color-neutral`, `--ks-color-neutral-hover` | Secondary button fill, and on hover | `--color-gray-500`, `--color-gray-400` |
| `--ks-color-danger`, `--ks-color-danger-hover` | Danger button fill, and on hover | `--color-red-600`, `--color-red-500` |
| `--ks-color-on-fill` | Button label colour | `--color-white` |
| `--ks-color-surface` | Panel, card and input background | `--color-white`, and `--color-surface-900` on a dark page |
| `--ks-color-border` | Panel and card border | `--color-surface-200` |
| `--ks-color-border-control` | Input border | `--color-gray-300` |
| `--ks-color-text` | Input text and page, section and card titles | `--color-surface-900` |
| `--ks-color-text-label` | Field labels | `--color-surface-700` |
| `--ks-color-text-muted` | Hints, subtitles and card summaries | `--color-surface-500` |
| `--ks-border-width` | Border and ring width of menus, dialogs, form controls and cards, doubled for radio and option cards and the file drop zone | `1px` |
| `--ks-shadow-overlay` | Menu, dialog and colour picker shadow | `--shadow-lg` |
| `--ks-font-weight-medium` | Copy button, checkbox row and radio card label weight | `--font-weight-medium` |
| `--ks-color-overlay` | Dialog, action menu, copy button and colour picker background | `--color-white` |
| `--ks-color-backdrop` | The dimmed page behind a dialog | Black at 60% |
| `--ks-color-text-heading` | Dialog title | `--color-gray-900` |
| `--ks-color-close`, `--ks-color-close-hover` | Dialog close button, and on hover | `--color-gray-400`, `--color-gray-600` |
| `--ks-color-ring` | Action menu outline | Black at 5% |
| `--ks-color-hover` | Menu option on hover | `--color-gray-50` |
| `--ks-color-hover-raised` | Copy button on hover | `--color-gray-50` |
| `--ks-color-border-strong` | Copy button, menu checkbox, colour swatch and file drop zone border | `--color-gray-300` |
| `--ks-color-focus` | Checkbox focus ring | `--color-accent-500` |
| `--ks-color-border-choice` | Checkbox row box border | `--color-surface-300` |
| `--ks-color-text-choice`, `--ks-color-text-choice-muted` | Checkbox row label and hint | `--color-surface-900`, `--color-surface-500` |
| `--ks-color-selected-border`, `--ks-color-selected` | Chosen radio card, option card and active drop zone border, and the chosen radio card background | `--color-accent-500`, `--color-accent-50` |
| `--ks-color-text-option`, `--ks-color-text-option-muted` | Radio card label and hint | `--color-gray-900`, `--color-surface-500` |
| `--ks-color-drop-active` | File drop zone background while a file is dragged over it | `--color-accent-50` |
| `--ks-color-icon` | File upload icon | `--color-gray-400` |
| `--ks-color-text-secondary` | File upload prompt | `--color-gray-600` |
| `--ks-color-link`, `--ks-color-link-hover` | File upload browse link, and on hover | `--color-accent-600`, `--color-accent-500` |

| `--ks-radius-pill` | Progress bar, hero badge and swipe button corners | Fully rounded |
| `--ks-color-hover-border` | Link card and feature card border on hover | Accent 500 at 50% |
| `--ks-color-tint`, `--ks-color-tint-border` | Feature icon, hero badge and active tab background, and the hero badge border | Accent 500 at 10% and 20% |
| `--ks-color-border-subtle` | Call to action, feature card, code, accordion and disclosure border | `--color-surface-200` |
| `--ks-color-fill-muted` | Call to action and code caption background | `--color-surface-50` |
| `--ks-color-raised` | Feature card background | `--color-white` |
| `--ks-color-text-display`, `--ks-color-text-display-muted` | Marketing titles and values, and their subtitles | `--color-surface-900`, `--color-surface-500` |
| `--ks-color-text-body` | Accordion and disclosure body text | `--color-surface-600` |
| `--ks-color-icon-soft` | Disclosure icon | `--color-surface-400` |
| `--ks-color-track`, `--ks-color-meter` | Progress track, and the progress bar, funnel accent step and bucket fill | `--color-surface-200`, `--color-accent-500` |
| `--ks-color-text-meter-label` | Progress and funnel labels | `--color-surface-700` |
| `--ks-color-funnel-accent`, `-sky`, `-violet`, `-amber`, `-rose` | The five funnel step colours | The matching Tailwind 500 shade |
| `--ks-color-funnel-band`, `--ks-color-text-funnel-band` | The joined funnel's band between steps and its percent | `--color-surface-800`, `--color-white`, and `--color-surface-100`, `--color-surface-900` on a dark page |
| `--ks-color-over-goal`, `--ks-color-over-goal-warning` | Bucket fill over its goal | `--color-green-500`, `--color-amber-500` |
| `--ks-color-table-head`, `--ks-color-table-body`, `--ks-color-divider` | Table head and body background, and the line between rows | `--color-gray-50`, `--color-white`, `--color-gray-200` |
| `--ks-shadow-surface-dark` | Table shadow on a dark page | None |
| `--ks-color-code`, `--ks-color-text-code` | Code block background and text | `--color-surface-900`, `--color-surface-100` |
| `--ks-color-pipeline`, `--ks-color-pipeline-box`, `--ks-color-pipeline-border` | Pipeline and box background, and their border | `--color-surface-800`, `--color-surface-900`, `--color-surface-700` |
| `--ks-color-text-on-dark`, `--ks-color-pipeline-muted`, `--ks-color-pipeline-label`, `--ks-color-pipeline-amber` | Pipeline title, subtitle, box label and amber count | `--color-white`, `--color-surface-400`, `--color-surface-500`, `--color-amber-400` |
| `--ks-color-nav`, `--ks-color-nav-border` | Bottom nav and desktop nav menu background and border | `--base-bg-low`, then `--color-white`; `--base-border-tertiary`, then `--color-gray-200` |
| `--ks-color-nav-text`, `--ks-color-nav-text-hover` | Bottom nav item, and nav links on hover | `--base-text-tertiary`, then `--color-gray-500`; `--base-text-secondary`, then `--color-gray-700` |
| `--ks-color-nav-link`, `--ks-color-nav-active`, `--ks-color-nav-indicator` | Nav link text, the current page's link, and its underline on wide screens | `--base-text`, `--text-primary` and `--border-primary`, then `--color-gray-900`, `--color-accent-600` and `--color-accent-600` |
| `--ks-color-nav-menu-mobile`, `--ks-color-nav-hover` | Nav menu background on small screens, and a menu link on hover | `--base-bg-base`, then `--color-white`; `--base-bg-hover`, then `--color-gray-50` |
| `--ks-shadow-menu` | Desktop nav menu shadow | `--shadow-md` |
| `--ks-font-weight-normal` | Mobile header subtitle weight | `--font-weight-normal` |
| `--ks-color-hover-soft` | Settings link on hover | `--color-gray-50` |
| `--ks-color-focus` | Input and checkbox focus border and ring | `--color-accent-500`, and `--color-accent-400` on a dark page |
| `--ks-color-link-strong-hover` | Section action and card link on hover | `--color-accent-900`, and `--color-accent-300` on a dark page |
| `--ks-color-badge-neutral` | Neutral badge background | `--color-gray-100`, and `--color-zinc-700` on a dark page |
Each colour variable in the table whose component changes on a dark page has a
`-dark` partner, such as `--ks-color-surface-dark`, that it reads there.

The navigation colours read the `--base-*` variables keystone_ui's nav used
before, when a host sets them, so a host that coloured its nav that way keeps
its colours.

Many roles default to a base role, so setting the base role recolours all of
them, and setting one of them on its own still overrides it:

| Base role | Roles that follow it |
|---|---|
| `--ks-color-text` | `text-display`, `text-heading`, `text-option`, `text-choice`, `nav-link` |
| `--ks-color-text-muted` | `text-display-muted`, `text-choice-muted`, `text-option-muted`, `nav-text` |
| `--ks-color-text-secondary` | `text-body` |
| `--ks-color-text-label` | `text-meter-label`, `nav-text-hover` |
| `--ks-color-icon` | `close`, `icon-soft` |
| `--ks-color-border` | `border-subtle`, `track`, `divider`, `nav-border` |
| `--ks-color-border-strong` | `border-control`, `border-choice` |
| `--ks-color-surface` | `table-body`, `nav`, `nav-menu-mobile` |
| `--ks-color-overlay` | `raised` |
| `--ks-color-hover` | `fill-muted`, `hover-raised`, `hover-soft`, `table-head`, `nav-hover` |
| `--ks-color-link` | `nav-active`, `nav-indicator` |

The base roles draw from the surface scale, which keystone_ui-colors sets per
account. The nav roles read the old `--base-*` variables first when a host sets
them.

Alerts and badges read a shade scale per status instead:
`--ks-color-success-*`, `--ks-color-warning-*`, `--ks-color-danger-*` and
`--ks-color-info-*`, each with shades 50, 100, 300, 400, 600, 700, 800 and 900, and 500 for danger. They
default to Tailwind's green, yellow and red, and to the accent scale for info.
An alert uses shades 50 and 800, and 900 and 300 on a dark page. A badge uses
100 and 700, and 900 and 400 on a dark page.

```css
:root {
  --ks-radius-control: 9999px;
  --ks-font-weight-strong: 500;
  --ks-color-accent: #6200ee;
  --ks-color-accent-dark: #bb86fc;
}
```

## Classes

| Class | Use |
|---|---|
| `ks-button` | Every button |
| `ks-button-primary`, `ks-button-secondary`, `ks-button-danger` | Button color |
| `ks-button-sm`, `ks-button-md`, `ks-button-lg` | Button size |
| `ks-panel` | Panel border and background |
| `ks-panel-radius-md`, `ks-panel-radius-lg`, `ks-panel-radius-xl` | Panel corner radius |
| `ks-panel-padding-sm`, `ks-panel-padding-md`, `ks-panel-padding-lg` | Panel padding |
| `ks-panel-shadow` | Panel shadow |
| `ks-input` | Text inputs, text areas and selects |
| `ks-input-disabled` | A disabled input |
| `ks-label` | Field label |
| `ks-required` | Required field marker |
| `ks-hint` | Field hint |
| `ks-error` | Field error |
| `ks-checkbox` | Checkbox |
| `ks-page` | Page padding |
| `ks-page-sm`, `ks-page-md`, `ks-page-lg`, `ks-page-xl` | Page maximum width, centered |
| `ks-page-offset-sm`, `ks-page-offset-md`, `ks-page-offset-lg`, `ks-page-offset-xl` | Space above a page |
| `ks-page-header`, `ks-page-header-title`, `ks-page-header-subtitle`, `ks-page-header-actions` | Page header and its parts |
| `ks-section-sm`, `ks-section-md`, `ks-section-lg` | Space above a section |
| `ks-section-header`, `ks-section-title`, `ks-section-subtitle`, `ks-section-action` | Section header and its parts |
| `ks-card`, `ks-card-edge` | Card, and a card that runs edge to edge on small screens |
| `ks-card-body`, `ks-card-title`, `ks-card-summary`, `ks-card-cta`, `ks-card-link` | Card parts |
| `ks-alert` | Every alert |
| `ks-alert-info`, `ks-alert-success`, `ks-alert-warning`, `ks-alert-error` | Alert color |
| `ks-alert-body`, `ks-alert-content`, `ks-alert-title`, `ks-alert-message`, `ks-alert-message-titled`, `ks-alert-dismiss` | Alert parts |
| `ks-badge` | Every badge |
| `ks-badge-neutral`, `ks-badge-success`, `ks-badge-danger`, `ks-badge-warning`, `ks-badge-info` | Badge color |
| `ks-modal-backdrop`, `ks-modal-panel`, `ks-modal-header`, `ks-modal-title`, `ks-modal-close` | Dialog and its parts |
| `ks-action-menu`, `ks-action-menu-button` | Mobile action menu and the button that opens it |
| `ks-menu`, `ks-menu-trigger`, `ks-menu-option`, `ks-menu-checkbox` | Column picker and multi select menu and their parts |
| `ks-copy-button` | Copy button |
| `ks-theme-toggle-option` | Theme toggle button, filled when pressed |
| `ks-checkbox-row`, `ks-checkbox-row-input`, `ks-checkbox-row-label`, `ks-checkbox-row-hint` | Checkbox row and its parts |
| `ks-radio-card`, `ks-radio-card-highlight`, `ks-radio-card-label`, `ks-radio-card-hint` | Radio card and its parts |
| `ks-option-card`, `ks-option-card-selected` | Option card, and a chosen one |
| `ks-file-upload`, `ks-file-upload-drop-zone`, `ks-file-upload-drop-zone-active`, `ks-file-upload-inner`, `ks-file-upload-icon`, `ks-file-upload-prompt`, `ks-file-upload-browse`, `ks-file-upload-hint`, `ks-file-upload-file-name` | File upload and its parts |
| `ks-color-swatch`, `ks-color-picker-panel` | Colour picker swatch and its panel |
| `ks-metric-card` | Stat card and chart card |
| `ks-stat-card-header`, `ks-stat-card-label`, `ks-stat-card-value`, `ks-stat-card-suffix`, `ks-stat-card-disclosure`, `ks-stat-card-emphasis`, `ks-stat-card-change`, `ks-stat-card-info` | Stat card parts |
| `ks-tone-neutral`, `ks-tone-muted`, `ks-tone-success`, `ks-tone-danger`, `ks-tone-warning`, `ks-tone-info` | Stat card value and change colour |
| `ks-chart-card-title` | Chart card title |
| `ks-link-card`, `ks-link-card-shadow`, `ks-link-card-padding-sm`, `ks-link-card-padding-md`, `ks-link-card-padding-lg` | Card link, its shadow and its padding |
| `ks-cta-banner`, `ks-cta-banner-title`, `ks-cta-banner-subtitle`, `ks-cta-banner-actions` | Call to action banner and its parts |
| `ks-feature-grid`, `ks-feature-grid-title`, `ks-feature-grid-subtitle`, `ks-feature-card`, `ks-feature-card-icon`, `ks-feature-card-title`, `ks-feature-card-description` | Feature grid and its cards |
| `ks-hero`, `ks-hero-inner`, `ks-hero-content`, `ks-hero-split`, `ks-hero-title`, `ks-hero-subtitle`, `ks-hero-badge`, `ks-hero-actions` | Hero and its parts |
| `ks-table`, `ks-table-head`, `ks-table-body`, `ks-table-header`, `ks-table-header-first`, `ks-table-header-middle`, `ks-table-header-last`, `ks-table-cell-first`, `ks-table-cell-middle`, `ks-table-cell-last`, `ks-table-sort-link`, `ks-table-sort-icon`, `ks-table-sort-icon-active` | Data table and its parts |
| `ks-code`, `ks-code-caption`, `ks-code-block` | Code block and its caption |
| `ks-accordion`, `ks-accordion-item`, `ks-accordion-button`, `ks-accordion-answer` | Accordion and its parts |
| `ks-disclosure`, `ks-disclosure-summary`, `ks-disclosure-body`, `ks-disclosure-icon` | Disclosure and its parts |
| `ks-tab-bar`, `ks-tab`, `ks-tab-active` | Tab switcher, a tab, and the active tab |
| `ks-progress-track`, `ks-progress-bar`, `ks-meter-label` | Progress bar and its label |
| `ks-funnel`, `ks-funnel-layer`, `ks-funnel-row`, `ks-funnel-label`, `ks-funnel-value`, `ks-funnel-bar`, `ks-funnel-transition`, `ks-funnel-bar-accent`, `ks-funnel-bar-sky`, `ks-funnel-bar-violet`, `ks-funnel-bar-amber`, `ks-funnel-bar-rose`, `ks-funnel-joined`, `ks-funnel-band`, `ks-funnel-band-label` | Funnel and its parts |
| `ks-bucket`, `ks-bucket-series`, `ks-bucket-label`, `ks-bucket-goal`, `ks-bucket-percent`, `ks-bucket-tank`, `ks-bucket-actual`, `ks-bucket-fill`, `ks-bucket-fill-over`, `ks-bucket-fill-over-warning` | Bucket and its parts |
| `ks-pipeline`, `ks-pipeline-header`, `ks-pipeline-title`, `ks-pipeline-subtitle`, `ks-pipeline-track`, `ks-pipeline-box`, `ks-pipeline-box-label`, `ks-pipeline-count`, `ks-pipeline-link-healthy`, `ks-pipeline-link-broken`, `ks-pipeline-count-amber`, `ks-pipeline-count-emerald`, `ks-pipeline-count-danger`, `ks-pipeline-count-muted` | Pipeline and its parts |
| `ks-swipe-card`, `ks-swipe-empty`, `ks-swipe-empty-title`, `ks-swipe-empty-message`, `ks-swipe-actions`, `ks-swipe-button`, `ks-swipe-button-reject`, `ks-swipe-button-accept` | Swipe deck and its parts |
| `ks-bottom-nav`, `ks-bottom-nav-item`, `ks-bottom-nav-label` | Bottom nav bar, fixed to the bottom of small screens, and its items |
| `ks-nav-dropdown`, `ks-nav-dropdown-trigger`, `ks-nav-dropdown-caret`, `ks-nav-dropdown-menu` | Nav dropdown and its parts, including the links inside the menu |
| `ks-nav-item` | A nav link |
| `ks-navbar-title` | Navbar title on small screens |
| `ks-mobile-header-title`, `ks-mobile-header-back`, `ks-mobile-header-subtitle` | Mobile header parts |
| `ks-settings-link`, `ks-settings-link-label` | Settings link and its label |
| `ks-grid-gap-sm`, `ks-grid-gap-md`, `ks-grid-gap-lg`, `ks-grid-gap-xl`, and the same with `-x-` and `-y-` | Grid gaps, both ways, across or down |
| `ks-form`, `ks-form-field`, `ks-form-field-checkbox` | Space between a form's fields, inside a field, and beside a checkbox |
| `ks-theme-toggle` | Space between the theme toggle's buttons |
| `ks-color-picker-label` | Space under the colour picker's label |
| `ks-settings-link-chevron` | Settings link arrow colour |
| `ks-page-title` | Form page and show page title |

On small screens the page's `main` element is padded to clear the bottom nav,
and a page inside Hotwire Native hides the bottom nav and drops that padding.

```html
<button class="ks-button ks-button-primary ks-button-md">Save</button>
```

## License

MIT
