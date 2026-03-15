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

### Linux desktop note

Linux desktop now builds with the normal Flutter commands:

- `flutter run -d linux`
- `flutter build linux`

Android Studio / IntelliJ users can create local `.run/` configurations if they
want IDE shortcuts for these commands.

Those run configurations are intentionally gitignored, so a fresh checkout will
not include shared `.run/` files.

For debugger-attached Linux desktop runs in the IDE, select the Linux desktop
device and create a Flutter run configuration targeting `lib/main.dart`.

## Ownership and licensing

LinguaFloor is currently being developed as a proprietary project.

Copyright © 2026 Philip Stephens. All rights reserved.

This repository does not grant permission to copy, modify, or redistribute the app code unless separate written permission is provided. The app may include third-party open-source components that remain available under their own licenses and notices.

## Next recommended steps

- add state management and routing packages
- implement real authentication and event join
- connect realtime transcript and queue state
- add translation and STT service abstractions
