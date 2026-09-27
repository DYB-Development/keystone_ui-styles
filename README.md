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
| `--ks-font-body` | Button font family | None, so a button keeps the page's font |
| `--ks-font-weight-strong` | Button label weight | `--font-weight-semibold` |
| `--ks-font-weight-heading` | Section, card and alert title weight, and one step heavier for page titles | `--font-weight-semibold` |
| `--ks-border-width-control` | Button border width | `0px` |
| `--ks-spacing` | The unit every button, input, page, card, alert and panel padding is a multiple of | `--spacing` |
| `--ks-color-accent`, `--ks-color-accent-hover` | Primary button fill, and on hover | `--color-accent-600`, `--color-accent-500` |
| `--ks-color-neutral`, `--ks-color-neutral-hover` | Secondary button fill, and on hover | `--color-gray-500`, `--color-gray-400` |
| `--ks-color-danger`, `--ks-color-danger-hover` | Danger button fill, and on hover | `--color-red-600`, `--color-red-500` |
| `--ks-color-on-fill` | Button label colour | `--color-white` |
| `--ks-color-surface` | Panel, card and input background | `--color-white` |
| `--ks-color-border` | Panel and card border | `--color-gray-200` |
| `--ks-color-border-control` | Input border | `--color-gray-300` |
| `--ks-color-text` | Input text and page, section and card titles | `--color-gray-900` |
| `--ks-color-text-label` | Field labels | `--color-gray-700` |
| `--ks-color-text-muted` | Hints, subtitles and card summaries | `--color-gray-500` |
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

Each colour variable in the table whose component changes on a dark page has a
`-dark` partner, such as `--ks-color-surface-dark`, that it reads there.

Alerts and badges read a shade scale per status instead:
`--ks-color-success-*`, `--ks-color-warning-*`, `--ks-color-danger-*` and
`--ks-color-info-*`, each with shades 50, 100, 300, 400, 700, 800 and 900. They
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

```html
<button class="ks-button ks-button-primary ks-button-md">Save</button>
```

## License

MIT
