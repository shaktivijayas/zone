# ZONE — Splash + Onboarding Figma Design Spec

**Date:** 2026-07-23
**Scope:** First feature slice of the ZONE mobile app Figma design. Covers only the Splash screen and the 3-slide Onboarding carousel. All other features (Map, Feed, Community, Profile, backend, admin dashboard) are out of scope and will be brainstormed as separate slices.

## Background

The user provided a full Flutter build spec for "ZONE," an anonymous campus social app for Chennai Institute of Technology. The text spec's dark theme and color palette are explicitly **not** used. Instead, the visual design is a faithful recreation of a reference screenshot (`zone ui.png`) the user attached, which shows a clean, light-first UI. This spec covers only the structural/visual design work to be built in Figma — no Flutter/backend implementation.

## Decisions

- **Fidelity:** Match the reference screenshot closely — same background tones, text colors, card treatment, button style, and copy. This is a faithful recreation, not a loose reinterpretation.
- **No invented accent color:** An earlier suggestion to add a green/terracotta accent color for CTA buttons was explicitly rejected. CTAs (Skip, Next, Get Started) stay solid black on white, exactly as shown in the reference.
- **Figma target:** A new Figma file named "ZONE" will be created for this design.
- **Frame size:** iPhone-standard 393×852 (iPhone 15 frame), matching the reference screenshot's proportions.

## Shared Style Tokens

| Token | Value | Notes |
|---|---|---|
| Background (onboarding) | `#FAFAFA` | Off-white, not pure white |
| Background (splash) | Dim campus photo + dark scrim overlay | Photographic, not flat color |
| Text primary | `#111111` | Near-black |
| Text secondary | `#6B7280` | Grey, for subtext/timestamps |
| Card surface | `#FFFFFF` with `#E5E7EB` hairline border | Soft drop shadow |
| CTA buttons | Solid black `#111111` pill, white label/icon | No secondary accent color |
| Progress indicator | Black = current/filled segment, light grey = inactive | Segmented pill style, top-centered |
| Semantic tag colors | Alert = red, Hot = orange, Info = yellow, Chill = green | Carried over from the original spec since these are meaning-colors shown in the reference, not theme colors |
| Heading font | Space Grotesk (bold) | Display headings only |
| Body font | Inter | Body text, subtext, labels |

## Screens

### 1. Splash

- Full-bleed dim campus building photo background with a dark overlay/scrim for text contrast.
- Small circular outline icon (sparkle/diamond mark) top-left corner.
- Large bold "ZONE" wordmark (Space Grotesk, white), positioned lower-left-of-center.
- Tagline directly beneath wordmark: "Know your campus, before you step in." — light grey/white, regular weight, smaller than wordmark.
- Near the bottom: a thin rounded progress/loading bar, with "Loading your campus..." caption in light grey beneath it.
- Status bar rendered in dark/light-content style (white icons) to match the dark photo background.

### 2. Onboarding — Slide 1: "Your campus. Unfiltered."

- Top bar: segmented progress pill indicator (3 segments, 1st filled black, other 2 grey), centered. "Skip" text link top-right.
- Bold two-line heading: "Your campus. Unfiltered." (Space Grotesk, black, large).
- Subtext beneath in grey: "Anonymous pins on the map to keep everyone informed."
- Below subtext: a rounded photo card (white border, shadow) showing a sample map-pin mockup — a small pin-label chip reading "📌 Library AC working today" over a campus photo.
- Bottom-right: circular solid-black button with a white right-arrow icon (advances to slide 2).

### 3. Onboarding — Slide 2: "Say what you think."

- Same header pattern: progress pill (2nd segment filled), "Skip" top-right.
- Heading: "Say what you think."
- Subtext: "Share updates, ask questions and help your peers."
- Below: a realistic feed-post-card mockup — red "Alert" flair chip, "2 min ago" timestamp, bold title "Staff near C Block", one line of body text "Faculty checking IDs.", upvote count (42) and comment count (18) at the bottom, "..." overflow menu.
- Bottom-right: same circular black next-arrow button (advances to slide 3).

### 4. Onboarding — Slide 3: "Learn. Build. Show off."

- Progress pill (3rd/last segment filled), "Skip" top-right (still present per reference, even on the last slide).
- Heading: "Learn. Build. Show off."
- Subtext: "Discover projects, get help and grow together."
- Below: a project-showcase-card mockup — photo of a workspace/dashboard screens, bookmark icon top-right of the image, bold title "Campus Dashboard", tech-stack chips ("Flutter", "Firebase", "Groq"), small "Anonymous" avatar/label row.
- Bottom: full-width solid-black pill button labeled **"Get Started"** (replaces the circular next button; this is the terminal action of onboarding, leading into the Main Shell).

## Out of Scope (this slice)

- Optional College Verification (OTP) screens
- Main Shell / bottom navigation and all 4 tabs
- Any backend, Firebase, or Flutter code
- Any color/theme decisions for later features — those will be brainstormed per-feature, referencing this same reference screenshot

## Next Steps

Proceed to an implementation plan for building these 4 screens in the new "ZONE" Figma file, then move on to brainstorming the next feature slice (per user's "one feature at a time" preference).
