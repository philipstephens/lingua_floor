# LinguaFloor

Flutter scaffold for a multilingual event translation and moderation app.

## Included in this scaffold

- multi-platform Flutter project
- feature-oriented `lib/` structure
- placeholder join flow with runtime host/participant routing
- host dashboard shell
- participant room shell
- event timer/status banner

## Current structure

- `lib/app/` – app entry composition
- `lib/core/` – shared models
- `lib/features/auth/` – join flow scaffold
- `lib/features/host/` – host dashboard scaffold
- `lib/features/participant/` – participant room scaffold
- `lib/features/shared/` – reusable widgets

## Run locally

1. Ensure Flutter is installed
2. Run `flutter pub get`
3. Run `flutter run`

## Next recommended steps

- add state management and routing packages
- implement real authentication and event join
- connect realtime transcript and queue state
- add translation and STT service abstractions
