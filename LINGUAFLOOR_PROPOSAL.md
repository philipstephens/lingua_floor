# LinguaFloor

## Multilingual Event Translation & Moderation System
**Proposal v3.1 – Single Flutter App Edition**

- **Project name:** LinguaFloor
- **Tech stack:** Flutter (Dart) + backend services + GitHub for version control/collaboration
- **Primary platforms:** Android and iOS
- **Extended platforms:** Tablets first-class; desktop/web possible later
- **Runtime roles:** Host (moderator/admin) and Participant (client/audience)

## 1. Overview
LinguaFloor is a real-time, moderated, multilingual event platform where one person speaks at a time under host-controlled floor management.

Core flow:
1. Speaker is granted the floor
2. Speech is converted to text (STT)
3. Host can review/edit the active transcript line
4. Text is translated through the host language as a pivot
5. Participants receive live transcript updates in their chosen language

Key goals:
- Low-latency live delivery
- Clear floor control and moderation
- Scalable multilingual transcript distribution
- Secure event participation with a full audit trail

## 2. Single-App Flutter Architecture
LinguaFloor will be built as **one Flutter application in Dart** with role-based behavior determined after login/join.

Benefits:
- One shared codebase across Android, iOS, and tablets
- Consistent UI/UX for hosts and participants
- Shared auth, networking, translation, and realtime logic
- Easier long-term maintenance and feature delivery

Recommended structure:
- `lib/core/` – shared services, theme, auth, websocket, translation, STT
- `lib/features/auth/` – join/login flow
- `lib/features/participant/` – transcript, raise hand, polls, language selection
- `lib/features/host/` – queue management, transcript control, moderation, logs
- `lib/features/shared/` – reusable widgets and models

Recommended packages/tools:
- State management: Riverpod
- Routing: GoRouter
- Networking: Dio or http
- Local persistence: shared_preferences initially; Hive/Drift later if needed
- Realtime backend: Supabase, Firebase, Appwrite, or custom WebSocket backend

## 3. Role Detection and App Entry
App entry begins in `main.dart`.

Join flow inputs:
- Username/password or guest name
- Event ID
- Optional event password

After backend validation, the app receives event/session data such as:
- role: `host` or `participant`
- event metadata
- allowed languages
- permissions

Navigation then routes the user to the correct home experience.
Backend must enforce role permissions; client-side guards are only a convenience.

## 4. Event Scheduling and Timer Feature
LinguaFloor should include event scheduling metadata and a visible timer.

Stored fields:
- `scheduledStartAt`
- `actualStartAt`
- `endedAt`
- `status` = `scheduled | live | ended`

Display behavior:
- **Before start:** show date/time and countdown (example: `Starts in 00:12:15`)
- **Live:** show `Live` plus elapsed time
- **Ended:** show `Ended` and final duration if desired

Usage:
- Participants see whether they are early, on time, or joining a live event
- Hosts can manually start the event even if the scheduled time has passed
- Timer appears in the top event header on both host and participant screens

## 5. Participant Mode
Main participant screen includes:
- Event name and timer/status header
- Current language selector
- Scrollable live transcript in the participant's selected language
- Raise Hand action with queue position feedback
- Microphone/floor indicator when permission is granted
- Poll access with badges for active polls

Transcript bubbles should show:
- timestamp
- speaker name
- translated text
- subtle color coding

Language selection should be searchable and persisted per device.

## 6. Host Mode
The host dashboard is the event control center.

Primary areas:
- Participant list with statuses and language info
- Raise-hand queue with FIFO defaults and drag-to-reorder support
- Grant/revoke floor controls
- Live transcript view with editable current line
- STT connection/status indicator
- Manual transcript fallback input

Host actions:
- Create and end polls
- Ban, unban, or kick participants
- Search/filter event logs
- Export transcript/log data

## 7. Polling and Moderation
Polling:
- Question text
- 1–5 options
- Optional `Other` field
- Realtime vote updates and results visualization

Moderation:
- Ban/kick with reason
- Searchable participant list
- Host-only protected actions
- Full audit/event log

## 8. Translation and Realtime Pipeline
Translation model:
- Incoming speech/transcript is normalized in the host language
- Participant output is generated per unique target language
- Frequent phrases may be cached for performance

Realtime behavior:
- Transcript deltas, queue changes, polls, and moderation events broadcast instantly
- WebSockets or backend realtime subscriptions used for low-latency updates
- Reconnect logic with exponential backoff
- Last ~100 messages cached locally for resilience

## 9. Security and Reliability
Requirements:
- TLS for all traffic
- Backend validation for every privileged action
- Optional per-event encryption strategy if needed
- Safe reconnect handling and local persistence for critical UI state

## 10. GitHub and Delivery Workflow
Recommended repository model:
- `main` – stable production-ready branch
- `develop` – integration branch
- feature branches such as `feat/host-queue` or `feat/role-routing`

Recommended CI via GitHub Actions:
- `flutter analyze`
- `flutter test`
- build validation on pull requests

Secrets such as backend keys must be stored in GitHub Secrets, never committed to the repository.

## 11. Recommended Development Phases
1. Initialize Flutter app and project structure
2. Implement join/login flow with role routing
3. Build participant room MVP
4. Build host dashboard MVP
5. Add realtime transcript sync
6. Add translation pipeline
7. Add queue control, moderation, and polls
8. Add audit log export, caching, and resilience improvements
9. Optimize for tablets and later desktop/web support

## 12. MVP Definition
A strong first MVP should include:
- event join screen
- runtime role detection
- host dashboard shell
- participant live room shell
- event timer/countdown/live state
- language selector
- mock or basic realtime transcript updates
- raise-hand queue

## 13. Summary
LinguaFloor is best implemented as a **single Flutter app in Dart** backed by a realtime service and database-enabled backend. It is designed for multilingual live events, with strong host moderation, live translation, scheduling/timer support, and room to expand from mobile/tablet into desktop later.
