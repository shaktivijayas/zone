# ZONE — Full App Completion Design

**Date:** 2026-08-16
**Scope:** Complete the entire ZONE app per the original Review-0 spec in a single day: Map, Feed, Community, Profile modules; Node.js/Express backend; Firebase (Realtime DB, Firestore, Cloud Messaging, Storage); Groq AI moderation/flair/digest; push notifications; admin dashboard; deployment.

## Background

Prior slices (splash, onboarding, app shell with placeholder tabs) are built and pushed. The original Review-0 presentation (`Downloads/ZONE - Mobile Application Development - Review 0.pptx`) specifies a 12-week phased build; the user needs the entire spec functional today for a course deadline, not the phased timeline. This is explicitly an accelerated MVP: every spec bullet gets a working implementation, but without the multi-week hardening (extensive test coverage, load testing, production-grade auth) that a real 12-week build would include.

## Constraints accepted for the one-day timeline

- **OTP/phone verification is simulated**: real UI flow, but any 6-digit code (or a fixed test code) is accepted instead of real SMS delivery — avoids a paid SMS provider approval wait.
- **Firebase Spark (free) plan** — sufficient for Realtime DB, Firestore, Storage, FCM at this scale; no billing account needed for Firebase itself.
- **Google Maps API key + billing account**: user is provisioning this now.
- **Groq API key**: user is provisioning this now (free).
- Deployment (Railway for backend, Vercel for admin dashboard) happens last, after core functionality is verified locally/on emulator.

## Architecture

```
ZONE Mobile App (Flutter)
  Map / Feed / Community / Profile tabs
        |  REST calls (posts, comments, moderation)
        v
Node.js / Express Backend  ---->  Groq LLM API (moderation, flair, digest)
  REST API, rate limiting, cron jobs
        |
        v
Firebase
  Realtime DB   -> live map pins, decay, upvote-extension
  Firestore     -> posts, comments, history, digests
  Cloud Messaging -> push: alerts, replies, daily digest
  Storage       -> images
```

- **Device identity**: existing `DeviceService` (hashed UUID) is the anonymous identity used for both Flutter-side local state and as the caller identity sent to backend endpoints — no accounts, no login.
- **Pin decay**: 30-minute base life, +5 minutes per upvote, 2-hour cap — computed server-side via a Realtime DB cron job (or Cloud Function-equivalent cron on the Express server), consistent with the Waze-style model in the spec.
- **Moderation gate**: every new pin/post/comment is sent to the backend, which calls Groq to classify (allow/reject) before writing to Firebase. Rejected content never reaches Firestore/RTDB.
- **Flair suggestion**: Groq call suggests a flair (Alert/Hot/Info/Chill) client can accept or override before posting.
- **Daily digest**: scheduled cron job on the backend aggregates the day's top pins/posts, asks Groq to summarize, writes result to Firestore, and triggers an FCM push to all devices.

## Components

1. **Backend** (`zone-backend/`, new repo/dir): Express REST API — `/pins`, `/posts`, `/comments`, `/moderate`, `/digest`; Firebase Admin SDK for RTDB/Firestore/FCM/Storage; node-cron for decay + trending-zone + digest jobs; Groq SDK for moderation/flair/digest calls.
2. **Map module** (`lib/features/map/`): Google Maps SDK view, pin drop UI, pin list synced from RTDB, decay-aware rendering (opacity/fade as pins age).
3. **Feed module** (`lib/features/feed/`): post composer with flair picker (AI-suggested), Firestore-backed post list, upvote + comment UI.
4. **Community module** (`lib/features/community/`): Ask & Answer (question/answer, accepted-answer marking, upvotes) and Project Showcase (card grid, tech-stack chips, bookmark), both Firestore-backed.
5. **Profile module** (`lib/features/profile/`): local karma total (derived from user's own posts/pins upvotes), saved items list, settings screen (dark mode toggle, OTP-verification entry point).
6. **Push notifications**: FCM wiring in Flutter (`firebase_messaging`) for alert pins near the user, replies to the user's own posts/comments, and the daily digest.
7. **Admin dashboard** (`zone-admin/`, new minimal Next.js app): read-only view of moderation queue outcomes, pin/post volume, trending zones — deployed to Vercel.

## Data flow example (posting a pin)

1. User drops a pin in the Map tab → Flutter sends `{ text, lat, lng, hashedDeviceId }` to `POST /pins`.
2. Backend calls Groq moderation; if rejected, returns 422 with a reason, nothing is persisted.
3. If allowed, backend suggests a flair via Groq (client may override), writes the pin to Realtime DB with `createdAt`, `expiresAt = createdAt + 30min`, `upvotes: 0`.
4. Flutter's Map tab listens to the RTDB pins node in real time and renders the new pin immediately.
5. Upvotes call `PATCH /pins/:id/upvote`, which extends `expiresAt` by 5 minutes (capped at `createdAt + 2h`) and increments `upvotes`.
6. The decay cron job periodically deletes pins where `now > expiresAt`.

## Testing approach (accelerated)

- Backend: focused unit tests on decay-time math, rate-limit logic, and Groq-response parsing (mocked Groq calls) — not full integration/load tests.
- Flutter: existing widget-test pattern continues for new screens (a test-local `GoRouter`/provider scope, no full app boot needed); Firestore/RTDB reads mocked via fake implementations, not live Firebase in unit tests.
- Manual verification pass at the end: run the app against the real (free-tier) Firebase project and walk the golden path (drop pin → see it decay/upvote-extend, post → moderate → appear in feed, ask a question → answer → accept, check profile karma updates, receive a push).

## Out of scope even for today

- Multi-campus support, monetization, native desktop client — explicitly out of scope per the original spec's own "Aim and Scope" slide.
- Real SMS-based OTP (simulated instead, see Constraints).
- Production-grade security hardening, load testing, and full CI/CD — a working, demoable MVP is the bar for today, not a production launch.
