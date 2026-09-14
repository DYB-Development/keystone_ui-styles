# keystone_ui-styles

Shared CSS for [keystone_ui](https://github.com/DYB-Development/keystone_ui) and
keystone_ui-react: keystone's color variables, its light and dark mode, and the
classes for buttons, panels and form fields.

Host apps do not install this gem directly. keystone_ui and keystone_ui-react
depend on it, and their install generators add its stylesheet import.

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

```html
<button class="ks-button ks-button-primary ks-button-md">Save</button>
```

## License

MIT
