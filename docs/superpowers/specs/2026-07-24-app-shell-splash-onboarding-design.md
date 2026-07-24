# ZONE — App Shell + Splash + Onboarding (Flutter) Design Spec

**Date:** 2026-07-24
**Scope:** First Flutter code slice of the ZONE app. Covers Flutter project bootstrap, theming, routing, the device identity service, the Splash screen, the 3-slide Onboarding carousel, and a placeholder Main Shell (bottom nav with 4 tabs, empty bodies). All other features (real Map/Feed/Community/Profile content, verification/OTP, backend, Firebase, Groq AI, push notifications, admin dashboard) are out of scope and will be brainstormed as separate slices.

## Background

The user provided a full Flutter build spec for "ZONE," an anonymous campus social app for Chennai Institute of Technology. The text spec's dark theme is explicitly **not** used — the visual design instead follows a reference screenshot (`zone ui.png`) showing a clean, light-first UI. A prior session (`docs/superpowers/specs/2026-07-23-splash-onboarding-design.md`) already designed the Splash + Onboarding screens as Figma mockups, but that work never got built because the Figma MCP connector's auth token was expired — no Figma file or Flutter code exists yet. This slice carries those same visual decisions forward but implements them as real Flutter code instead of Figma frames, and adds the minimum app shell (theme, routing, device identity, tab scaffold) needed for anything to run.

The user's stated preference (recorded in the prior spec's "Next Steps") is to build **one feature at a time** — this slice, then Map, then Feed, then Community, then Profile, each as its own reviewed spec/plan/build cycle — rather than attempting the entire app in one pass.

## Decisions

- **Fidelity:** Match the reference screenshot closely for Splash/Onboarding — same tones, text colors, card treatment, button style, copy. Carried over verbatim from the prior Figma spec.
- **Real code, not Figma:** This slice produces a working Flutter app, not design mockups. The Figma branch/workflow from the prior session is abandoned in favor of direct implementation.
- **Repo:** Reuse `C:\Users\shakthi\Documents\zone` (existing git repo, `main` branch) as the Flutter project root. Push to a new GitHub repo `shaktivijayas/zone` (public) once this slice runs successfully.
- **State management:** `flutter_riverpod`, per the original spec's package list.
- **Routing:** `go_router`, with routes `/splash`, `/onboarding`, and `/home` (shell route hosting the 4-tab bottom nav).
- **Theme:** Light only for this slice (dark mode toggle is a Profile-tab settings feature, out of scope here).
- **Map rendering (future slices):** Placeholder illustrated campus background instead of real Google Maps, decided for later slices — noted here only so the theme/asset conventions stay consistent.

## Shared Style Tokens

| Token | Value | Notes |
|---|---|---|
| Background (onboarding/app) | `#FAFAFA` | Off-white, not pure white |
| Background (splash) | Dim campus photo + dark scrim overlay | Photographic, not flat color |
| Text primary | `#111111` | Near-black |
| Text secondary | `#6B7280` | Grey, for subtext/timestamps |
| Card surface | `#FFFFFF` with `#E5E7EB` hairline border | Soft drop shadow |
| CTA buttons | Solid black `#111111` pill, white label/icon | No secondary accent color |
| Progress indicator | Black = current/filled segment, light grey = inactive | Segmented pill style, top-centered |
| Semantic tag colors | Alert `#DC2626` (red), Hot `#EA580C` (orange), Info `#D97706` (yellow), Chill `#16A34A` (green) | Carried over — meaning-colors used on pin/flair chips across the whole app, not theme colors |
| Heading font | Space Grotesk (bold) | Display headings only |
| Body font | Inter | Body text, subtext, labels |
| Active nav item | Text primary `#111111` | Since this app is light-themed, not the original dark-theme's Electric Blue |
| Inactive nav item | Text secondary `#6B7280` | |

## Architecture

### Project structure
```
lib/
  core/
    theme/          # ThemeData, color tokens, text styles
    device/          # DeviceService (UUID + hashing)
    router/          # go_router configuration
  features/
    splash/
    onboarding/
    shell/           # bottom-nav shell + 4 placeholder tab bodies
  main.dart
```

### Device identity service
- On first run, generate a `uuid` v4, persist it in `SharedPreferences` under a fixed key.
- Expose a `hashedDeviceId` getter: `sha256(uuid + 'zone_salt_2024')`, truncated to 16 hex chars — matches the algorithm given in the original spec so later slices (Profile, karma, verification) stay compatible.
- Exposed via a Riverpod provider so any later feature can read the hashed ID without re-deriving it.

### Routing
- `/splash` (initial route) → after a 2-second delay, reads a `onboarding_complete` bool from `SharedPreferences`:
  - `false`/unset → `/onboarding`
  - `true` → `/home`
- `/onboarding` → `PageView` of 3 slides. "Skip" (visible on all slides) and "Get Started" (final slide only) both set `onboarding_complete = true` and navigate to `/home`, replacing history so back-navigation can't return to onboarding.
- `/home` → `StatefulShellRoute` (go_router) with 4 branches: Map, Feed, Community, Profile. Bottom nav bar switches branches, preserving each branch's navigation stack.

### Theming
- `ThemeData` built once in `core/theme`, exposing the token table above as named constants (not raw hex scattered through widgets).
- `google_fonts` package for Space Grotesk + Inter, loaded via `GoogleFonts.spaceGroteskTextTheme()` / `GoogleFonts.interTextTheme()` composition.

## Screens

### 1. Splash
- Full-bleed background: a dark gradient (near-black to dark slate, matching the scrim tone in the reference screenshot) with a subtle abstract geometric pattern — not a photographic image, since no licensed CIT campus photo is available and sourcing a stock photo would add an external/copyright dependency this slice doesn't need. Same visual effect (dark, moody, campus-at-night feel) without a real photo asset.
- Small circular outline sparkle/diamond icon, top-left.
- Large bold "ZONE" wordmark (Space Grotesk, white), lower-left-of-center.
- Tagline directly beneath: "Know your campus, before you step in." — light grey/white, regular weight.
- Near the bottom: thin rounded indeterminate progress bar, with "Loading your campus..." caption beneath in light grey.
- Status bar icons in light/white style (matches dark photo background).
- After 2 seconds, navigates per the routing logic above.

### 2. Onboarding — Slide 1: "Your campus. Unfiltered."
- Top bar: segmented progress pill (3 segments, 1st filled black, others grey), centered; "Skip" text link top-right.
- Bold two-line heading: "Your campus. Unfiltered." (Space Grotesk, black, large).
- Subtext: "Anonymous pins on the map to keep everyone informed." (grey).
- Rounded photo card (white bg, hairline border, shadow) showing a mock map-pin chip: "📌 Library AC working today" over a placeholder image block (solid-color gradient rectangle, not a real photo — no photo asset available for this slice).
- Bottom-right circular solid-black button, white right-arrow icon → advances to slide 2.

### 3. Onboarding — Slide 2: "Say what you think."
- Same header pattern, 2nd segment filled.
- Heading: "Say what you think." / Subtext: "Share updates, ask questions and help your peers."
- Mock feed-post-card: red "Alert" flair chip, "2 min ago", bold title "Staff near C Block", body line "Faculty checking IDs.", upvote count (42), comment count (18), "..." overflow icon.
- Same circular next-arrow button → advances to slide 3.

### 4. Onboarding — Slide 3: "Learn. Build. Show off."
- 3rd/last segment filled, "Skip" still present.
- Heading: "Learn. Build. Show off." / Subtext: "Discover projects, get help and grow together."
- Mock project-showcase card: placeholder image block (gradient rectangle, not a real photo) standing in for a workspace/dashboard screenshot, bookmark icon top-right, bold title "Campus Dashboard", tech-stack chips ("Flutter" "Firebase" "Groq"), small "Anonymous" label row.
- Full-width solid-black pill button: **"Get Started"** → completes onboarding, routes to `/home`.

### 5. Main Shell (placeholder)
- Bottom nav bar, 4 items (Map pin / Feed list / Community people / Person icons from `Icons.*` or a Material icon set — no custom icon assets needed yet), background `#FAFAFA` with a subtle top border `#E5E7EB`.
- Active tab: icon + label in `#111111`; inactive: `#9CA3AF`.
- Light haptic feedback (`HapticFeedback.selectionClick()`) on tab switch.
- Each tab body: centered text, e.g. "Map — coming in the next slice", so the shell is visibly functional without pretending the real feature exists.

## Out of Scope (this slice)

- Optional College Verification (OTP) screens
- Real Map/Feed/Community/Profile screen content
- Any backend, Firebase, Groq AI, or push notification wiring
- Dark mode / theme switching (Profile settings feature, later)
- Google Maps integration (placeholder map is a Map-tab-slice decision, not needed until that slice)

## Verification Plan

1. `flutter analyze` — zero errors/warnings introduced.
2. `flutter run -d chrome` — manually click through: Splash (auto-advances after 2s) → Onboarding slide 1 → 2 → 3 → tap "Get Started" → lands on Main Shell → tap through all 4 bottom-nav tabs and confirm active/inactive styling and placeholder text. Separately relaunch and confirm "Skip" from slide 1 also reaches Main Shell, and that a second app relaunch (with `onboarding_complete` already true) skips straight from Splash to Main Shell.
3. Visual comparison against `zone ui.png` for Splash and the 3 onboarding slides (colors, layout, copy).

## Next Steps

Once this slice is built, reviewed, and pushed to `shaktivijayas/zone`, brainstorm the next slice (Map tab, placeholder campus background) as its own spec/plan cycle.
