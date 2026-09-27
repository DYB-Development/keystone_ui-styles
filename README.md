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

## Button variables

Every button reads these variables, so a host restyles all of its buttons by
setting them in a plain `:root` rule in its own stylesheet. The defaults sit in
Tailwind's base layer, so a `:root` rule outside any layer overrides them
wherever it is imported.

| Variable | Sets | Default |
|---|---|---|
| `--ks-radius-control` | Corner radius | `--radius-lg` |
| `--ks-font-body` | Font family | None, so a button keeps the page's font |
| `--ks-font-weight-strong` | Label weight | `--font-weight-semibold` |
| `--ks-border-width-control` | Border width | `0px` |
| `--ks-spacing` | The unit every button's padding is a multiple of | `--spacing` |
| `--ks-color-accent`, `--ks-color-accent-hover` | Primary fill, and on hover | `--color-accent-600`, `--color-accent-500` |
| `--ks-color-neutral`, `--ks-color-neutral-hover` | Secondary fill, and on hover | `--color-gray-500`, `--color-gray-400` |
| `--ks-color-danger`, `--ks-color-danger-hover` | Danger fill, and on hover | `--color-red-600`, `--color-red-500` |
| `--ks-color-on-fill` | Label colour | `--color-white` |

Each colour variable has a `-dark` partner, such as `--ks-color-accent-dark`,
that a button reads on a dark page. Each partner defaults to the same value as
the light variable.

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
