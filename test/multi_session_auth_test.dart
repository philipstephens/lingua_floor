import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_floor/core/models/app_role.dart';
import 'package:lingua_floor/app/lingua_floor_app.dart';
import 'package:lingua_floor/app/session_workspace_factory.dart';
import 'package:lingua_floor/features/auth/data/in_memory_auth_session_service.dart';
import 'package:lingua_floor/features/auth/presentation/join_screen.dart';
import 'package:lingua_floor/features/event_setup/data/in_memory_event_session_catalog_service.dart';

void main() {
  testWidgets(
    'multi-session join flow enforces login, creates follow-up sessions, and logs out',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1.0;
      final seededSessions = buildDefaultPersistedEventSessions(
        now: DateTime(2026, 1, 1, 9),
      );
      final authSessionService = InMemoryAuthSessionService();
      final sessionCatalogService = InMemoryEventSessionCatalogService(
        seedSessions: seededSessions,
      );
      final workspaceFactory = InMemorySessionWorkspaceFactory(
        catalogService: sessionCatalogService,
      );

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        workspaceFactory.dispose();
        sessionCatalogService.dispose();
        authSessionService.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: JoinScreen(
            session: seededSessions.first.session,
            authSessionService: authSessionService,
            sessionCatalogService: sessionCatalogService,
            sessionWorkspaceFactory: workspaceFactory,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session-card-session-staff-morning')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session-card-session-debate-afternoon')),
        findsOneWidget,
      );

      final enterParticipantButton = find.byKey(
        const Key('enter-participant-button'),
      );
      await tester.ensureVisible(enterParticipantButton);

      await tester.tap(enterParticipantButton);
      await tester.pump();
      expect(find.text('Enter your name before joining.'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('login-display-name-field')),
        'Amina',
      );
      await tester.tap(
        find.byKey(const Key('session-card-session-debate-afternoon')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add-session-button')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Follow-up'), findsWidgets);

      await tester.tap(enterParticipantButton);
      await tester.pumpAndSettle();

      expect(find.text('Participant Room'), findsOneWidget);
      await tester.tap(find.byKey(const Key('participant-logout-button')));
      await tester.pumpAndSettle();

      expect(find.text('Participant Room'), findsNothing);
      expect(find.textContaining('Logged in as Amina'), findsNothing);
      expect(find.byKey(const Key('login-display-name-field')), findsOneWidget);
    },
  );

  testWidgets(
    'participant transcript language is remembered per user, not per device',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1.0;
      final authSessionService = InMemoryAuthSessionService();

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        authSessionService.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: JoinScreen(
            session: buildDefaultEventSession(),
            authSessionService: authSessionService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login-display-name-field')),
        'Amina',
      );
      await tester.tap(find.byKey(const Key('enter-participant-button')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('participant-language-picker-button')),
      );
      await tester.tap(
        find.byKey(const Key('participant-language-picker-button')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('language-picker-search-field')),
        'French',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('language-picker-option-French')));
      await tester.pumpAndSettle();

      expect(find.text('Language: 🇫🇷 FR'), findsOneWidget);

      await tester.tap(find.byKey(const Key('participant-logout-button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login-display-name-field')),
        'Bayo',
      );
      await tester.tap(find.byKey(const Key('enter-participant-button')));
      await tester.pumpAndSettle();

      expect(find.text('Language: 🇫🇷 FR'), findsNothing);
      expect(find.text('Language: 🇬🇧 EN'), findsOneWidget);
    },
  );

  testWidgets(
    'restored auth session reselects the previously joined scheduled session',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1.0;
      final seededSessions = buildDefaultPersistedEventSessions(
        now: DateTime(2026, 1, 1, 9),
      );
      final authSessionService = InMemoryAuthSessionService();
      final sessionCatalogService = InMemoryEventSessionCatalogService(
        seedSessions: seededSessions,
      );
      final workspaceFactory = InMemorySessionWorkspaceFactory(
        catalogService: sessionCatalogService,
      );

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        workspaceFactory.dispose();
        sessionCatalogService.dispose();
        authSessionService.dispose();
      });

      await authSessionService.login(
        displayName: 'Amina',
        role: AppRole.participant,
        eventId: defaultDebateSessionId,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: JoinScreen(
            session: seededSessions.first.session,
            authSessionService: authSessionService,
            sessionCatalogService: sessionCatalogService,
            sessionWorkspaceFactory: workspaceFactory,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Logged in as Amina'), findsOneWidget);

      await tester.tap(find.byKey(const Key('enter-host-button')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Budget Priorities Debate · Afternoon Session'),
        findsWidgets,
      );
    },
  );
}
