# Style guide

The single source of truth for how MiMalla looks and behaves. Every user story that touches the UI follows it.
The tokens live in `app/assets/tailwind/application.css` (the only file allowed to contain color values).
The decisions below were taken when US-012 was built; change them here and in that file, in the same PR.

## Principles

1. **Lean and calm**: compact, sober, information first. The grid must fit as much of the degree as possible.
2. **Recognisably UNTREF, not a copy**: UNTREF blue family shifted towards a tech tone, with the university's magenta as
   a rare accent.
3. **Accessible by default**: WCAG 2.2 AA in both themes.
4. **Tokens, never literals**: no hex/rgb values and no Tailwind palette colors (`bg-blue-500`) in views, components,
   helpers or JavaScript. `spec/style/no_hard_coded_colors_spec.rb` fails the build if one appears.

## Color

Two daisyUI themes, `untref-light` (default) and `untref-dark`, chosen automatically from the operating system
(`prefers-color-scheme`). There is no manual switch yet.

| Token (Tailwind / daisyUI) | Light | Dark | Use |
| --- | --- | --- | --- |
| `primary` | `#1D5A9E` | `#7DB4EE` | Main actions, links, focus ring, active/selected |
| `secondary` | `#0A78AB` | `#5CC4EE` | Secondary actions and highlights (UNTREF light blue family) |
| `accent` | `#C8164F` | `#FF6B97` | Rare emphasis only (news, "new"). Never for subject statuses |
| `neutral` | `#1B2430` | `#243247` | Dark surfaces (toasts, tooltips) |
| `base-100` / `base-200` / `base-300` | `#FFFFFF` / `#F2F4F7` / `#DDE2E8` | `#0F1722` / `#162131` / `#22304A` | Page, panels, borders |
| `base-content` | `#1B2430` | `#E6ECF3` | Text. Use `text-base-content/70` for secondary text, never lighter |
| `info` `success` `warning` `error` | see the CSS file | see the CSS file | Feedback messages and alerts |

Always pair a color with its `-content` token (`bg-primary text-primary-content`). On `base-200` use `text-primary`
for links, not `text-secondary` (secondary only reaches AA on white).

### Subject status colors

Used from US-030 on. Never rely on color alone: show the status name (or an icon with a text alternative) next to it.

| Status | Token | Meaning |
| --- | --- | --- |
| Pending | `status-pending` | Not started (neutral gray-blue) |
| In progress | `status-in-progress` | Being taken now (blue) |
| Regular | `status-regular` | Course passed, final pending (amber) |
| Approved | `status-approved` | Passed (green) |
| Promoted | `status-promoted` | Passed without final exam (teal) |
| Free | `status-free` | Free student (violet) |
| Retaking | `status-retaking` | Taking it again (orange) |
| Dropped | `status-dropped` | Abandoned (red) |

Use as `bg-status-approved text-status-content` (filled) or `text-status-approved` / `border-status-approved`.

## Typography

- **Inter** (variable, latin subset), self-hosted in `app/assets/fonts/` and declared in the Tailwind CSS. No request to
  third parties. The OFL license allows redistribution.
- Page title `text-2xl font-semibold`; panel title `text-xl font-semibold`; section title `font-semibold`;
  body `text-sm` inside dense areas (grid, panels), default size elsewhere; secondary text `text-xs`/`text-sm` with
  `text-base-content/70`.
- Subject codes are shown as plain text in secondary style (no monospace font).

## Shape and density ("compact and sober")

- Radius: `rounded-box` for cards and panels (0.375rem), fields and buttons use the theme radius (0.25rem).
- No shadows (`--depth: 0`); separate surfaces with a 1px `border-base-300`.
- Spacing scale: `gap-3`/`space-y-2` inside the grid, `space-y-4` inside panels, `py-6` for page headings.
- Use daisyUI components first (`btn`, `link`, `badge`, `alert`, `modal`, `progress`); write custom Tailwind only for
  layout.
- Components: any UI piece used twice becomes a ViewComponent with a component spec.

## Behavior

- **Subject detail** opens in a **side panel**: a `turbo-frame#subject_detail` next to the grid on large screens
  (`lg:`), full-screen on small ones. The same content is reachable at its own URL (`/subjects/:id`).
- Links that must open in the panel carry `data-turbo-frame="subject_detail"`; links that leave it use
  `data-turbo-frame="_top"`.
- When the panel opens, focus moves to its heading (`autofocus` + `tabindex="-1"`). Closing is a link back to the
  plan, so it works without JavaScript.
- Grid scrolls horizontally on narrow screens; cards are links, so they are keyboard focusable for free.
- **Forms**: one column (`max-w-md`), built with `form_with(model:, scope:, url:)`. Each field is a `fieldset` with a
  real `<label class="fieldset-legend">` and an `input w-full`, plus a hint (`<p class="label">`) tied to the input with
  `aria-describedby` when useful. Errors go in an `alert alert-error alert-soft` with `role="alert"` that lists the
  sentences; an error is never only a color. Set `autocomplete` on every field that has a standard value.
- **Account links** live in the `<header>` of the layout: "Crear cuenta" when signed out; the email and a
  "Cerrar sesión" button (not a link, sign out is `DELETE`) when signed in.
- Prefer server-rendered Turbo over custom JavaScript. Add a Stimulus controller only when Turbo cannot do it.
- Motion is small and wrapped in `motion-safe:`; `prefers-reduced-motion` is also respected globally.

## Accessibility (WCAG 2.2 AA)

- Text contrast at least 4.5:1 (3:1 for large text and UI borders) in **both** themes.
- Visible focus on everything interactive: the global `:focus-visible` outline is on; do not remove it.
- Everything works with the keyboard; the layout has a "skip to content" link.
- Landmarks and headings in order (`main`, one `h1` per page, then `h2`, `h3`).
- Never convey information by color alone (see statuses).
- Images need `alt`; icon-only buttons need an accessible name.

## Checklist for every story that touches the UI

- [ ] Only tokens and daisyUI components; no color literals (the style spec enforces it).
- [ ] Looked at in the light and the dark theme.
- [ ] Usable with the keyboard only, focus visible, contrast AA.
- [ ] Works on a narrow screen (about 360 px wide).
- [ ] Texts in I18n (es-AR).
- [ ] This guide updated if the story adds a new pattern, color or rule.

## Changing the palette

Edit the two theme blocks in `app/assets/tailwind/application.css`, check each text/background pair reaches 4.5:1
(a contrast checker is enough), update the tables above, and run `bin/test`.
