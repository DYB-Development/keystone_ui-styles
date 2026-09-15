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
<html>                     <!-- follows the operating system -->
```

The `dark:` variant in the host's own Tailwind classes follows the same rule.

## Classes

| Class | Use |
|---|---|
| `ks-button` | Every button |
| `ks-button-primary`, `ks-button-secondary`, `ks-button-danger` | Button color |
| `ks-button-sm`, `ks-button-md`, `ks-button-lg` | Button size |
| `ks-panel` | Panel border and background |
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

```html
<button class="ks-button ks-button-primary ks-button-md">Save</button>
```

## License

MIT
