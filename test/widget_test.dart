import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_floor/app/app_settings.dart';
import 'package:lingua_floor/app/lingua_floor_app.dart';
import 'package:lingua_floor/core/config/app_runtime_config.dart';
import 'package:lingua_floor/core/models/app_role.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/auth/presentation/join_screen.dart';
import 'package:lingua_floor/features/chat/application/chat_controller.dart';
import 'package:lingua_floor/features/chat/data/in_memory_chat_service.dart';
import 'package:lingua_floor/features/chat/domain/models/chat_message.dart';
import 'package:lingua_floor/features/event_setup/application/event_session_controller.dart';
import 'package:lingua_floor/features/event_setup/data/in_memory_event_session_service.dart';
import 'package:lingua_floor/features/hand_raise/application/hand_raise_controller.dart';
import 'package:lingua_floor/features/hand_raise/data/in_memory_hand_raise_service.dart';
import 'package:lingua_floor/features/hand_raise/domain/models/hand_raise_request.dart';
import 'package:lingua_floor/features/host/presentation/host_dashboard_screen.dart';
import 'package:lingua_floor/features/microphone/domain/models/linux_offline_dictation_diagnostics.dart';
import 'package:lingua_floor/features/microphone/domain/models/voice_dictation_state.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/microphone/domain/services/voice_dictation_service.dart';
import 'package:lingua_floor/features/microphone/presentation/widgets/voice_dictation_composer.dart';
import 'package:lingua_floor/features/participant/presentation/participant_room_screen.dart';
import 'package:lingua_floor/features/transcript/application/transcript_feed_controller.dart';
import 'package:lingua_floor/features/transcript/application/transcript_lane_controller.dart';
import 'package:lingua_floor/features/transcript/data/in_memory_transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/data/in_memory_transcript_lane_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FakeVoiceDictationService implements VoiceDictationService {
  FakeVoiceDictationService({
    VoiceDictationState? initialState,
    this.startListeningState,
  }) : _state =
           initialState ??
           const VoiceDictationState(
             status: VoiceDictationStatus.ready,
             recognizedText: '',
             isAvailable: true,
           );

  VoiceDictationState _state;
  final VoiceDictationState? startListeningState;

  final StreamController<VoiceDictationState> _controller =
      StreamController<VoiceDictationState>.broadcast();

  @override
  VoiceDictationState get currentState => _state;

  @override
  Stream<VoiceDictationState> watchState() => _controller.stream;

  @override
  Future<void> initialize() async {
    _controller.add(_state);
  }

  @override
  Future<void> startListening({
    String existingText = '',
    String? localeId,
  }) async {
    _state =
        startListeningState ??
        VoiceDictationState(
          status: VoiceDictationStatus.listening,
          recognizedText: 'Please raise my hand for the next question.',
          isAvailable: true,
          activeLocaleId: localeId,
        );
    _controller.add(_state);
  }

  @override
  Future<void> stopListening() async {
    _state = _state.copyWith(status: VoiceDictationStatus.ready);
    _controller.add(_state);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

class FakeLinuxDiagnosticsVoiceDictationService
    extends FakeVoiceDictationService
    implements
        LinuxOfflineDictationDiagnosticsProvider,
        LinuxOfflineDictationDiagnosticsRefreshable {
  FakeLinuxDiagnosticsVoiceDictationService({
    required LinuxOfflineDictationDiagnostics diagnostics,
    this.refreshedDiagnostics,
    super.initialState,
  }) : _diagnostics = diagnostics;

  LinuxOfflineDictationDiagnostics _diagnostics;
  final LinuxOfflineDictationDiagnostics? refreshedDiagnostics;
  final StreamController<LinuxOfflineDictationDiagnostics>
  _diagnosticsController =
      StreamController<LinuxOfflineDictationDiagnostics>.broadcast();
  int refreshCalls = 0;

  @override
  LinuxOfflineDictationDiagnostics get currentLinuxOfflineDiagnostics =>
      _diagnostics;

  @override
  Stream<LinuxOfflineDictationDiagnostics> watchLinuxOfflineDiagnostics() =>
      _diagnosticsController.stream;

  @override
  Future<void> refreshLinuxOfflineDiagnostics() async {
    refreshCalls += 1;
    final nextDiagnostics = refreshedDiagnostics;
    if (nextDiagnostics == null) {
      return;
    }

    _diagnostics = nextDiagnostics;
    _diagnosticsController.add(_diagnostics);
  }

  @override
  Future<void> initialize() async {
    await super.initialize();
    _diagnosticsController.add(_diagnostics);
  }

  @override
  void dispose() {
    _diagnosticsController.close();
    super.dispose();
  }
}

EventSession _buildTestSession() {
  return EventSession(
    eventName: 'LinguaFloor Demo',
    hostLanguage: 'English',
    eventTimeZone: 'America/Toronto',
    isDaylightSavingTimeEnabled: true,
    scheduledStartAt: DateTime(2026, 1, 1, 9),
    actualStartAt: DateTime(2026, 1, 1, 9),
    endedAt: null,
    status: EventStatus.live,
    supportedLanguages: const ['English', 'French', 'Spanish'],
  );
}

void main() {
  test('app runtime config parses the machine translation key', () {
    final config = AppRuntimeConfig.fromJsonMap({
      'machineTranslationApiKey': '  demo-key  ',
    });

    expect(config.machineTranslationApiKey, 'demo-key');
    expect(config.hasMachineTranslationApiKey, isTrue);
  });

  testWidgets('voice dictation composer can refresh Linux diagnostics', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final service = FakeLinuxDiagnosticsVoiceDictationService(
      diagnostics: const LinuxOfflineDictationDiagnostics(
        modelAssetPath: 'assets/models/vosk-model-small-en-us-0.15.zip',
        microphonePermissionStatus: LinuxOfflineDiagnosticStatus.ready,
        microphonePermissionDetail: 'Microphone permission granted.',
        runtimeStatus: LinuxOfflineDiagnosticStatus.actionRequired,
        runtimeDetail:
            'Linux audio capture tools are missing or unavailable on PATH.',
        parecordStatus: LinuxOfflineDiagnosticStatus.ready,
        parecordDetail: 'parecord found on PATH.',
        pactlStatus: LinuxOfflineDiagnosticStatus.actionRequired,
        pactlDetail: 'pactl is missing from PATH.',
        ffmpegStatus: LinuxOfflineDiagnosticStatus.ready,
        ffmpegDetail: 'ffmpeg found on PATH.',
      ),
      refreshedDiagnostics: const LinuxOfflineDictationDiagnostics(
        modelAssetPath: 'assets/models/vosk-model-small-en-us-0.15.zip',
        microphonePermissionStatus: LinuxOfflineDiagnosticStatus.ready,
        microphonePermissionDetail: 'Microphone permission granted.',
        runtimeStatus: LinuxOfflineDiagnosticStatus.ready,
        runtimeDetail: 'Local Vosk recognizer is ready.',
        parecordStatus: LinuxOfflineDiagnosticStatus.ready,
        parecordDetail: 'parecord found on PATH.',
        pactlStatus: LinuxOfflineDiagnosticStatus.ready,
        pactlDetail: 'pactl found on PATH.',
        ffmpegStatus: LinuxOfflineDiagnosticStatus.ready,
        ffmpegDetail: 'ffmpeg found on PATH.',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VoiceDictationComposer(
            service: service,
            showLinuxOfflineGuidance: true,
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('pactl • Action needed'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('linux-offline-diagnostics-refresh')),
    );
    await tester.pump();

    expect(service.refreshCalls, 1);
    expect(
      find.text(
        'Linux offline dictation checks look healthy in this app session.',
      ),
      findsOneWidget,
    );
    expect(find.text('pactl • Ready'), findsOneWidget);
    expect(find.text('pactl found on PATH.'), findsOneWidget);
  });

  testWidgets('voice dictation composer can copy Linux diagnostics', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const diagnostics = LinuxOfflineDictationDiagnostics(
      modelAssetPath: 'assets/models/vosk-model-small-en-us-0.15.zip',
      microphonePermissionStatus: LinuxOfflineDiagnosticStatus.ready,
      microphonePermissionDetail: 'Microphone permission granted.',
      runtimeStatus: LinuxOfflineDiagnosticStatus.actionRequired,
      runtimeDetail: 'Bundled model asset could not be loaded.',
      parecordStatus: LinuxOfflineDiagnosticStatus.ready,
      parecordDetail: 'parecord found on PATH.',
      pactlStatus: LinuxOfflineDiagnosticStatus.actionRequired,
      pactlDetail: 'pactl is missing from PATH.',
      ffmpegStatus: LinuxOfflineDiagnosticStatus.ready,
      ffmpegDetail: 'ffmpeg found on PATH.',
    );

    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copiedText =
              (methodCall.arguments as Map<Object?, Object?>)['text']
                  as String?;
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VoiceDictationComposer(
            service: FakeLinuxDiagnosticsVoiceDictationService(
              diagnostics: diagnostics,
            ),
            showLinuxOfflineGuidance: true,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.byKey(const Key('linux-offline-diagnostics-copy')));
    await tester.pump();

    expect(copiedText, diagnostics.summaryText);
    expect(
      copiedText,
      contains('Ubuntu/Debian: sudo apt install pulseaudio-utils'),
    );
    expect(find.text('Linux diagnostics copied to clipboard.'), findsOneWidget);
  });

  test('app runtime config falls back to empty values', () {
    final config = AppRuntimeConfig.fromJsonMap(const {});

    expect(config.machineTranslationApiKey, isEmpty);
    expect(config.hasMachineTranslationApiKey, isFalse);
  });

  test(
    'app settings controller preserves participant transcript preference when updating picker labels',
    () {
      final controller = AppSettingsController(
        initialSettings: const AppSettings(
          preferredParticipantTranscriptLanguage: 'French',
        ),
      );
      addTearDown(controller.dispose);

      controller.updatePickerLabels(
        datePickerButtonLabel: 'Choose date',
        timePickerButtonLabel: 'Choose time',
      );

      expect(
        controller.settings.preferredParticipantTranscriptLanguage,
        'French',
      );
      expect(controller.settings.datePickerButtonLabel, 'Choose date');
      expect(controller.settings.timePickerButtonLabel, 'Choose time');
    },
  );

  test('event session controller normalizes and saves event setup', () async {
    final controller = EventSessionController(
      service: InMemoryEventSessionService(
        seedSession: _buildTestSession().copyWith(
          status: EventStatus.scheduled,
          clearActualStartAt: true,
          clearEndedAt: true,
        ),
      ),
      disposeService: true,
    );
    addTearDown(controller.dispose);

    final scheduledStartAt = DateTime(2026, 1, 2, 10, 30);

    await controller.initialize();
    await controller.saveSetup(
      eventName: '  Global Town Hall  ',
      hostLanguage: 'German',
      eventTimeZone: 'Europe/Berlin',
      isDaylightSavingTimeEnabled: true,
      scheduledStartAt: scheduledStartAt,
      status: EventStatus.scheduled,
      supportedLanguages: const ['French', ' Japanese ', 'french', ''],
    );

    expect(controller.errorMessage, isNull);
    expect(controller.session.eventName, 'Global Town Hall');
    expect(controller.session.hostLanguage, 'German');
    expect(controller.session.eventTimeZone, 'Europe/Berlin');
    expect(controller.session.isDaylightSavingTimeEnabled, isTrue);
    expect(controller.session.scheduledStartAt, scheduledStartAt);
    expect(controller.session.status, EventStatus.scheduled);
    expect(controller.session.actualStartAt, isNull);
    expect(controller.session.endedAt, isNull);
    expect(controller.session.supportedLanguages, const [
      'German',
      'French',
      'Japanese',
    ]);
  });

  test('transcript feed controller stores shared transcript state', () async {
    final controller = TranscriptFeedController(
      service: InMemoryTranscriptFeedService(),
      disposeService: true,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    expect(controller.segments, isEmpty);

    final segment = TranscriptSegment(
      speakerLabel: 'Host',
      originalText: 'Shared transcript line',
      capturedAt: DateTime(2026, 1, 1, 9),
      sourceLanguage: 'English',
      status: TranscriptSegmentStatus.finalized,
    );

    await controller.replaceSegments([segment]);
    expect(controller.segments.single.originalText, 'Shared transcript line');

    await controller.clear();
    expect(controller.segments, isEmpty);
  });

  test('transcript lane controller materializes shared caption lanes', () async {
    final eventSessionService = InMemoryEventSessionService(
      seedSession: _buildTestSession(),
    );
    final transcriptFeedService = InMemoryTranscriptFeedService();
    final controller = TranscriptLaneController(
      service: InMemoryTranscriptLaneService(
        eventSessionService: eventSessionService,
        transcriptFeedService: transcriptFeedService,
      ),
      disposeService: true,
    );
    addTearDown(eventSessionService.dispose);
    addTearDown(transcriptFeedService.dispose);
    addTearDown(controller.dispose);

    await controller.initialize();
    expect(controller.lanes, isEmpty);

    await transcriptFeedService.replaceSegments([
      TranscriptSegment(
        speakerLabel: 'Host',
        originalText:
            'Welcome to LinguaFloor Demo. This mock pipeline stands in for live microphone capture.',
        translatedText: '[French] Welcome message preview.',
        capturedAt: DateTime(2026, 1, 1, 9),
        sourceLanguage: 'English',
        targetLanguage: 'French',
        status: TranscriptSegmentStatus.translated,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(
      controller.lanes.keys,
      containsAll(['English', 'French', 'Spanish']),
    );
    expect(controller.laneFor('French')?.isTranslated, isTrue);
    expect(
      controller.laneFor('French')?.segments.single.translatedText,
      'Bienvenue à LinguaFloor Demo. Ce pipeline simulé remplace actuellement la capture microphone en direct.',
    );
    expect(
      controller.laneFor('English')?.segments.single.translatedText,
      isNull,
    );
  });

  test('chat controller stores sent messages in app state', () async {
    final controller = ChatController(
      service: InMemoryChatService(),
      currentUserName: 'You',
      currentUserRole: AppRole.participant,
      disposeService: true,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    await controller.sendMessage('First in-app chat message');

    expect(controller.messages, hasLength(1));
    expect(controller.messages.single.text, 'First in-app chat message');
    expect(controller.messages.single.authorRole, AppRole.participant);
  });

  test('chat controller receives simulated incoming room messages', () async {
    final controller = ChatController(
      service: InMemoryChatService(
        simulatedIncomingMessages: [
          ChatMessage(
            id: 'incoming-host-update',
            text: 'We are opening the floor for questions now.',
            sentAt: DateTime(2026, 1, 1, 9),
            authorName: 'Host Maya',
            authorRole: AppRole.host,
          ),
        ],
        incomingMessageInterval: const Duration(milliseconds: 10),
      ),
      currentUserName: 'You',
      currentUserRole: AppRole.participant,
      disposeService: true,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(controller.messages, hasLength(1));
    expect(
      controller.messages.single.text,
      'We are opening the floor for questions now.',
    );
    expect(controller.messages.single.authorName, 'Host Maya');
    expect(controller.messages.single.authorRole, AppRole.host);
  });

  test('hand-raise controller stores requests and updates status', () async {
    final controller = HandRaiseController(
      service: InMemoryHandRaiseService(),
      currentParticipantName: 'You',
      disposeService: true,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    await controller.raiseHand();

    expect(controller.requests, hasLength(1));
    expect(controller.requests.single.participantName, 'You');
    expect(controller.requests.single.status, HandRaiseRequestStatus.pending);

    await controller.updateStatus(
      controller.requests.single.id,
      HandRaiseRequestStatus.approved,
    );
    expect(controller.activeRequest?.status, HandRaiseRequestStatus.approved);

    await controller.updateStatus(
      controller.requests.single.id,
      HandRaiseRequestStatus.answered,
    );
    expect(controller.activeRequest, isNull);
    expect(controller.requests.single.status, HandRaiseRequestStatus.answered);
  });

  testWidgets('shows LinguaFloor join scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(const LinguaFloorApp());

    expect(find.text('LinguaFloor'), findsOneWidget);
    expect(find.text('Enter as host'), findsOneWidget);
    expect(find.text('Enter as participant'), findsOneWidget);
    expect(
      find.textContaining('Saskatoon / Last used location'),
      findsOneWidget,
    );
  });

  testWidgets('join screen reflects shared event setup updates', (
    WidgetTester tester,
  ) async {
    final session = _buildTestSession();
    final eventSessionService = InMemoryEventSessionService(
      seedSession: session,
    );
    addTearDown(eventSessionService.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: JoinScreen(
          session: session,
          eventSessionService: eventSessionService,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('LinguaFloor Demo'), findsOneWidget);
    expect(find.text('Japanese'), findsNothing);

    await eventSessionService.updateSession(
      session.copyWith(
        eventName: 'Global Town Hall',
        hostLanguage: 'German',
        eventTimeZone: 'Asia/Tokyo',
        isDaylightSavingTimeEnabled: false,
        supportedLanguages: const ['German', 'Japanese'],
      ),
    );
    await tester.pump();

    expect(find.text('Global Town Hall'), findsOneWidget);
    expect(find.text('Japanese'), findsOneWidget);
    expect(find.textContaining('Tokyo'), findsOneWidget);
    expect(find.textContaining('DST off'), findsOneWidget);
  });

  testWidgets(
    'join screen opens third-party notices and the full license page',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      PackageInfo.setMockInitialValues(
        appName: 'LinguaFloor',
        packageName: 'com.example.lingua_floor',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
        installerStore: null,
      );

      await tester.pumpWidget(const LinguaFloorApp());

      await tester.tap(find.byTooltip('Third-party notices'));
      await tester.pumpAndSettle();

      expect(find.text('Third-party notices'), findsOneWidget);
      expect(find.text('Version: 1.0.0+1'), findsOneWidget);
      expect(find.text('View open-source licenses'), findsOneWidget);

      await tester.ensureVisible(find.text('View open-source licenses'));
      await tester.tap(find.text('View open-source licenses'));
      await tester.pumpAndSettle();

      expect(find.text('Licenses'), findsOneWidget);
      expect(find.text('LinguaFloor'), findsOneWidget);
    },
  );

  testWidgets('join screen opens the About screen and links to notices', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    PackageInfo.setMockInitialValues(
      appName: 'LinguaFloor',
      packageName: 'com.example.lingua_floor',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
      installerStore: null,
    );

    await tester.pumpWidget(const LinguaFloorApp());

    await tester.tap(find.byTooltip('About LinguaFloor'));
    await tester.pumpAndSettle();

    expect(find.text('About LinguaFloor'), findsOneWidget);
    expect(find.text('Version: 1.0.0+1'), findsOneWidget);
    expect(
      find.textContaining('Copyright © 2026 Philip Stephens'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('View third-party notices'));
    await tester.tap(find.text('View third-party notices'));
    await tester.pumpAndSettle();

    expect(find.text('Third-party notices'), findsOneWidget);
    expect(find.text('View open-source licenses'), findsOneWidget);
  });

  testWidgets('join screen opens settings and applies custom picker labels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LinguaFloorApp());

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('settings-date-picker-label-field')),
      'Choose date',
    );
    await tester.enterText(
      find.byKey(const Key('settings-time-picker-label-field')),
      'Choose time',
    );
    await tester.tap(find.byKey(const Key('save-settings-button')));
    await tester.pumpAndSettle();

    expect(find.text('Settings saved.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enter as host'));
    await tester.pumpAndSettle();

    expect(find.text('Choose date'), findsOneWidget);
    expect(find.text('Choose time'), findsOneWidget);
  });

  testWidgets('host dashboard exposes microphone support scaffold', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const LinguaFloorApp());

    await tester.tap(find.text('Enter as host'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.drag(
      find.byType(Scrollable).first,
      const Offset(0, -900),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(find.text('Microphone pipeline'), findsOneWidget);
    expect(find.text('Start capture'), findsOneWidget);
    expect(
      find.textContaining('Mock microphone/transcription service'),
      findsOneWidget,
    );
  });

  testWidgets('host can approve and resolve hand raises', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final handRaiseService = InMemoryHandRaiseService(
      seedRequests: [
        HandRaiseRequest(
          id: 'request-maria',
          participantName: 'Maria',
          requestedAt: DateTime(2026, 1, 1, 9),
          status: HandRaiseRequestStatus.pending,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HostDashboardScreen(
          session: _buildTestSession(),
          handRaiseService: handRaiseService,
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('1. Maria'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();

    expect(
      handRaiseService.currentRequests.single.status,
      HandRaiseRequestStatus.approved,
    );
    expect(find.textContaining('Approved'), findsOneWidget);
    expect(find.text('Mark answered'), findsOneWidget);

    await tester.tap(find.text('Mark answered'));
    await tester.pumpAndSettle();

    expect(find.text('Answered'), findsOneWidget);
  });

  testWidgets('host can edit event setup and save shared session state', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final seedSession = _buildTestSession();
    final eventSessionService = InMemoryEventSessionService(
      seedSession: seedSession,
    );
    final handRaiseService = InMemoryHandRaiseService();
    final appSettingsController = AppSettingsController(
      initialSettings: const AppSettings(
        datePickerButtonLabel: 'Choose date',
        timePickerButtonLabel: 'Choose time',
      ),
    );
    var pickedDateCalls = 0;
    var pickedTimeCalls = 0;
    addTearDown(eventSessionService.dispose);
    addTearDown(handRaiseService.dispose);
    addTearDown(appSettingsController.dispose);

    await tester.pumpWidget(
      AppSettingsScope(
        controller: appSettingsController,
        child: MaterialApp(
          home: HostDashboardScreen(
            session: seedSession,
            eventSessionService: eventSessionService,
            handRaiseService: handRaiseService,
            scheduledDatePicker: (context, initialDate) async {
              pickedDateCalls += 1;
              return DateTime(2026, 2, 3);
            },
            scheduledTimePicker: (context, initialTime) async {
              pickedTimeCalls += 1;
              return const TimeOfDay(hour: 14, minute: 45);
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Choose date'), findsOneWidget);
    expect(find.text('Choose time'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('event-name-field')),
      'Global Town Hall',
    );
    await tester.enterText(
      find.byKey(const Key('host-language-field')),
      'German',
    );
    await tester.enterText(
      find.byKey(const Key('supported-languages-field')),
      'French, Japanese',
    );
    await tester.pump();

    expect(find.text('Participant language preview'), findsOneWidget);
    expect(find.text('German • original'), findsOneWidget);
    expect(find.text('French • translated'), findsOneWidget);
    expect(find.text('Japanese • translated'), findsOneWidget);
    expect(
      find.text('Live translation ready: French, Japanese'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('event-status-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scheduled').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('event-timezone-field')));
    await tester.pumpAndSettle();
    expect(find.text("St. John's"), findsOneWidget);
    expect(find.text('Toronto'), findsWidgets);
    await tester.tap(find.text('Saskatoon / Last used location').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('event-dst-switch')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('pick-schedule-date-button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('pick-schedule-time-button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('save-event-setup-button')));
    await tester.pump();

    expect(pickedDateCalls, 1);
    expect(pickedTimeCalls, 1);
    expect(eventSessionService.currentSession.eventName, 'Global Town Hall');
    expect(eventSessionService.currentSession.hostLanguage, 'German');
    expect(eventSessionService.currentSession.eventTimeZone, 'America/Regina');
    expect(
      eventSessionService.currentSession.isDaylightSavingTimeEnabled,
      isFalse,
    );
    expect(eventSessionService.currentSession.status, EventStatus.scheduled);
    expect(
      eventSessionService.currentSession.scheduledStartAt,
      DateTime(2026, 2, 3, 14, 45),
    );
    expect(eventSessionService.currentSession.supportedLanguages, const [
      'German',
      'French',
      'Japanese',
    ]);
    expect(find.text('Event setup saved.'), findsOneWidget);
  });

  testWidgets(
    'host event setup preview shows original-only participant languages',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(home: HostDashboardScreen(session: _buildTestSession())),
      );
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('host-language-field')),
        'English',
      );
      await tester.enterText(
        find.byKey(const Key('supported-languages-field')),
        'French, Klingon',
      );
      await tester.pump();

      expect(find.text('English • original'), findsOneWidget);
      expect(find.text('French • translated'), findsOneWidget);
      expect(find.text('Klingon • original for now'), findsOneWidget);
      expect(find.text('Live translation ready: French'), findsOneWidget);
      expect(find.text('Showing original for now: Klingon'), findsOneWidget);
      expect(
        find.text(
          '1 translated participant language(s) will be live. 1 additional language(s) will show the original English conversation until translation is ready.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'voice dictation composer fills the text box from speech results',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceDictationComposer(service: FakeVoiceDictationService()),
          ),
        ),
      );

      await tester.tap(find.text('Start dictation'));
      await tester.pump();

      expect(
        find.text('Please raise my hand for the next question.'),
        findsOneWidget,
      );
      expect(find.text('Stop dictation'), findsOneWidget);
    },
  );

  testWidgets('voice dictation composer shows Linux offline guidance details', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VoiceDictationComposer(
            service: FakeVoiceDictationService(
              initialState: const VoiceDictationState(
                status: VoiceDictationStatus.unavailable,
                recognizedText: '',
                isAvailable: false,
                activeLocaleId: 'en-US offline',
                errorMessage:
                    'Linux offline dictation needs `parecord`, `pactl`, and `ffmpeg` available on PATH.',
              ),
            ),
            showLinuxOfflineGuidance: true,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(
      find.byKey(const Key('linux-offline-dictation-guidance')),
      findsOneWidget,
    );
    expect(find.text('Linux offline mode'), findsOneWidget);
    expect(find.text('English only'), findsOneWidget);
    expect(find.text('Local Vosk model'), findsOneWidget);
    expect(
      find.textContaining('assets/models/vosk-model-small-en-us-0.15.zip'),
      findsOneWidget,
    );
    expect(
      find.text('Required Linux tools: parecord, pactl, ffmpeg.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Speech dictation is unavailable right now. See details below.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('voice dictation composer shows Linux diagnostics readiness', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VoiceDictationComposer(
            service: FakeLinuxDiagnosticsVoiceDictationService(
              diagnostics: const LinuxOfflineDictationDiagnostics(
                modelAssetPath: 'assets/models/vosk-model-small-en-us-0.15.zip',
                microphonePermissionStatus: LinuxOfflineDiagnosticStatus.ready,
                microphonePermissionDetail: 'Microphone permission granted.',
                runtimeStatus: LinuxOfflineDiagnosticStatus.actionRequired,
                runtimeDetail: 'Bundled model asset could not be loaded.',
                parecordStatus: LinuxOfflineDiagnosticStatus.ready,
                parecordDetail: 'parecord found on PATH.',
                pactlStatus: LinuxOfflineDiagnosticStatus.actionRequired,
                pactlDetail: 'pactl is missing from PATH.',
                ffmpegStatus: LinuxOfflineDiagnosticStatus.ready,
                ffmpegDetail: 'ffmpeg found on PATH.',
              ),
            ),
            showLinuxOfflineGuidance: true,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(
      find.byKey(const Key('linux-offline-dictation-diagnostics')),
      findsOneWidget,
    );
    expect(find.text('System readiness'), findsOneWidget);
    expect(
      find.text(
        'Action is needed before Linux offline dictation is likely to work.',
      ),
      findsOneWidget,
    );
    expect(find.text('Microphone permission • Ready'), findsOneWidget);
    expect(find.text('Model + recognizer • Action needed'), findsOneWidget);
    expect(find.text('pactl • Action needed'), findsOneWidget);
    expect(find.text('pactl is missing from PATH.'), findsOneWidget);
    expect(find.text('Suggested next steps'), findsOneWidget);
    expect(
      find.byKey(const Key('linux-offline-dictation-troubleshooting')),
      findsOneWidget,
    );
    expect(
      find.text(
        'Install missing Linux audio tools: pactl. `parecord` and `pactl` usually come from `pulseaudio-utils`; `ffmpeg` comes from the `ffmpeg` package. Restart the app after installing them.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Place the bundled Vosk model zip at assets/models/vosk-model-small-en-us-0.15.zip, then restart the app.',
      ),
      findsOneWidget,
    );
    expect(find.text('Common install commands'), findsOneWidget);
    expect(
      find.byKey(const Key('linux-offline-dictation-install-hints')),
      findsOneWidget,
    );
    expect(
      find.text('Ubuntu/Debian: sudo apt install pulseaudio-utils'),
      findsOneWidget,
    );
    expect(find.text('Arch: sudo pacman -S libpulse'), findsOneWidget);
    expect(
      find.text(
        'Bundled model asset: assets/models/vosk-model-small-en-us-0.15.zip',
      ),
      findsOneWidget,
    );
  });

  testWidgets('participant can send a chat message from the composer', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ParticipantRoomScreen(
          session: _buildTestSession(),
          voiceDictationService: FakeVoiceDictationService(),
          chatService: InMemoryChatService(),
        ),
      ),
    );

    final scrollable = find.byType(Scrollable).first;

    await tester.enterText(
      find.byType(TextField),
      'Can I ask a follow-up question?',
    );
    await tester.pump();
    final sendButton = find.widgetWithText(FilledButton, 'Send chat message');
    await tester.ensureVisible(sendButton);
    await tester.pumpAndSettle();
    await tester.tap(sendButton);
    await tester.pump();

    await tester.scrollUntilVisible(
      find.textContaining('You • '),
      250,
      scrollable: scrollable,
    );

    expect(find.text('No chat messages sent yet.'), findsNothing);
    expect(find.textContaining('You • '), findsOneWidget);
    expect(find.text('Can I ask a follow-up question?'), findsOneWidget);
    expect(find.textContaining('Chat message sent:'), findsOneWidget);
  });

  testWidgets('participant room shows mock incoming room messages', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ParticipantRoomScreen(
          session: _buildTestSession(),
          voiceDictationService: FakeVoiceDictationService(),
        ),
      ),
    );
    await tester.pump();

    final scrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.text(
        'Welcome everyone — live translation is running for English, French, and Spanish.',
      ),
      250,
      scrollable: scrollable,
    );

    expect(
      find.text(
        'Welcome everyone — live translation is running for English, French, and Spanish.',
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 5));
    await tester.scrollUntilVisible(
      find.text('Could the next answer be repeated a little more slowly?'),
      250,
      scrollable: scrollable,
    );
    expect(
      find.text('Could the next answer be repeated a little more slowly?'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 5));
    await tester.scrollUntilVisible(
      find.text(
        'Absolutely — I will pause between points so the translated captions can catch up.',
      ),
      250,
      scrollable: scrollable,
    );
    expect(
      find.text(
        'Absolutely — I will pause between points so the translated captions can catch up.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('participant can switch conversation languages', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ParticipantRoomScreen(
          session: _buildTestSession(),
          voiceDictationService: FakeVoiceDictationService(),
          chatService: InMemoryChatService(),
          handRaiseService: InMemoryHandRaiseService(),
        ),
      ),
    );
    await tester.pump();

    final scrollable = find.byType(Scrollable).first;

    expect(find.text('Language: English'), findsOneWidget);
    expect(find.text('View: original'), findsOneWidget);
    expect(
      find.text(
        'Welcome to LinguaFloor Demo. Live translation is active for today\'s discussion.',
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('participant-language-French')),
      250,
      scrollable: scrollable,
    );
    await tester.ensureVisible(
      find.byKey(const Key('participant-language-French')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('participant-language-French')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.text(
        'Original: Welcome to LinguaFloor Demo. Live translation is active for today\'s discussion.',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Language: French'), findsOneWidget);
    expect(find.text('View: translated'), findsOneWidget);
    expect(
      find.text(
        'Bienvenue à LinguaFloor Demo. La traduction en direct est active pour la discussion d’aujourd’hui.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Original: Welcome to LinguaFloor Demo. Live translation is active for today\'s discussion.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'participant remembers selected conversation language across re-entry',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const LinguaFloorApp());

      await tester.tap(find.text('Enter as participant'));
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byKey(const Key('participant-language-French')),
        250,
        scrollable: scrollable,
      );
      await tester.ensureVisible(
        find.byKey(const Key('participant-language-French')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('participant-language-French')));
      await tester.pumpAndSettle();

      expect(find.text('Language: French'), findsOneWidget);
      expect(find.text('View: translated'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enter as participant'));
      await tester.pumpAndSettle();

      expect(find.text('Language: French'), findsOneWidget);
      expect(find.text('View: translated'), findsOneWidget);
    },
  );

  testWidgets(
    'participant falls back when remembered conversation language is unavailable',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fallbackSession = _buildTestSession().copyWith(
        supportedLanguages: const ['English', 'Spanish'],
      );
      final appSettingsController = AppSettingsController(
        initialSettings: const AppSettings(
          preferredParticipantTranscriptLanguage: 'French',
        ),
      );
      addTearDown(appSettingsController.dispose);

      await tester.pumpWidget(
        AppSettingsScope(
          controller: appSettingsController,
          child: MaterialApp(
            home: ParticipantRoomScreen(
              session: fallbackSession,
              voiceDictationService: FakeVoiceDictationService(),
              chatService: InMemoryChatService(),
              handRaiseService: InMemoryHandRaiseService(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byKey(const Key('participant-unavailable-language-notice')),
        250,
        scrollable: scrollable,
      );
      await tester.ensureVisible(
        find.byKey(const Key('participant-unavailable-language-notice')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Language: English'), findsOneWidget);
      expect(find.text('View: original'), findsOneWidget);
      expect(
        find.byKey(const Key('participant-unavailable-language-notice')),
        findsOneWidget,
      );
      expect(
        find.text(
          'French is not available in this room right now. Showing the conversation in English instead.',
        ),
        findsOneWidget,
      );
      expect(
        appSettingsController.settings.preferredParticipantTranscriptLanguage,
        'English',
      );
    },
  );

  testWidgets('participant sees source fallback guidance for non-ready lane', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fallbackSession = _buildTestSession().copyWith(
      supportedLanguages: const ['English', 'French', 'Klingon'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ParticipantRoomScreen(
          session: fallbackSession,
          voiceDictationService: FakeVoiceDictationService(),
          chatService: InMemoryChatService(),
          handRaiseService: InMemoryHandRaiseService(),
        ),
      ),
    );
    await tester.pump();

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byKey(const Key('participant-language-Klingon')),
      250,
      scrollable: scrollable,
    );
    await tester.ensureVisible(
      find.byKey(const Key('participant-language-Klingon')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Live translation ready: French'), findsOneWidget);
    expect(find.text('Showing original for now: Klingon'), findsOneWidget);

    await tester.tap(find.byKey(const Key('participant-language-Klingon')));
    await tester.pumpAndSettle();

    expect(find.text('Language: Klingon'), findsOneWidget);
    expect(find.text('View: original for now'), findsOneWidget);
    expect(
      find.text(
        'Klingon is configured for this event, but live translation is not ready yet.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Showing the original English conversation for now. Try one of the live translated languages: French.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Welcome to LinguaFloor Demo. Live translation is active for today\'s discussion.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('host keeps the main transcript in the host language', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final transcriptFeedService = InMemoryTranscriptFeedService(
      seedSegments: [
        TranscriptSegment(
          speakerLabel: 'Participant A',
          originalText: 'Bonjour à tout le monde.',
          translatedText: 'Hello everyone.',
          capturedAt: DateTime(2026, 1, 1, 9),
          sourceLanguage: 'French',
          targetLanguage: 'English',
          status: TranscriptSegmentStatus.translated,
        ),
      ],
    );
    addTearDown(transcriptFeedService.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: HostDashboardScreen(
          session: _buildTestSession(),
          transcriptFeedService: transcriptFeedService,
          handRaiseService: InMemoryHandRaiseService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Hello everyone.'),
      250,
      scrollable: scrollable,
    );
    await tester.ensureVisible(find.text('Hello everyone.'));
    await tester.pumpAndSettle();

    expect(find.text('Hello everyone.'), findsOneWidget);
    expect(find.text('Original French'), findsOneWidget);
    expect(find.text('Bonjour à tout le monde.'), findsOneWidget);
    expect(find.text('Conversation in English'), findsOneWidget);
  });

  testWidgets(
    'host and participant can read shared transcript lanes published from host capture',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventSessionService = InMemoryEventSessionService(
        seedSession: _buildTestSession(),
      );
      final transcriptFeedService = InMemoryTranscriptFeedService();
      final transcriptLaneService = InMemoryTranscriptLaneService(
        eventSessionService: eventSessionService,
        transcriptFeedService: transcriptFeedService,
      );
      final handRaiseService = InMemoryHandRaiseService();
      addTearDown(eventSessionService.dispose);
      addTearDown(transcriptFeedService.dispose);
      addTearDown(transcriptLaneService.dispose);
      addTearDown(handRaiseService.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: HostDashboardScreen(
            session: _buildTestSession(),
            eventSessionService: eventSessionService,
            handRaiseService: handRaiseService,
            transcriptFeedService: transcriptFeedService,
            transcriptLaneService: transcriptLaneService,
          ),
        ),
      );
      await tester.pump();

      final startCaptureButton = find.widgetWithText(
        FilledButton,
        'Start capture',
      );
      await tester.ensureVisible(startCaptureButton);
      await tester.pumpAndSettle();
      await tester.tap(startCaptureButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 3));

      expect(transcriptFeedService.currentSegments, isNotEmpty);
      expect(find.text('Conversation languages: 3 shared'), findsOneWidget);
      expect(find.text('Translated languages: 2'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: ParticipantRoomScreen(
            session: _buildTestSession(),
            eventSessionService: eventSessionService,
            voiceDictationService: FakeVoiceDictationService(),
            chatService: InMemoryChatService(),
            handRaiseService: handRaiseService,
            transcriptFeedService: transcriptFeedService,
            transcriptLaneService: transcriptLaneService,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Feed: shared live'), findsOneWidget);
      expect(
        find.text(
          'Welcome to LinguaFloor Demo. This mock pipeline stands in for live microphone capture.',
        ),
        findsOneWidget,
      );

      final participantScrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byKey(const Key('participant-language-French')),
        250,
        scrollable: participantScrollable,
      );
      await tester.ensureVisible(
        find.byKey(const Key('participant-language-French')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('participant-language-French')));
      await tester.pumpAndSettle();

      expect(find.text('Language: French'), findsOneWidget);
      expect(find.text('Feed: shared live'), findsOneWidget);
      expect(
        find.text(
          'Bienvenue à LinguaFloor Demo. Ce pipeline simulé remplace actuellement la capture microphone en direct.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('participant can raise a hand request from the room', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final handRaiseService = InMemoryHandRaiseService();

    await tester.pumpWidget(
      MaterialApp(
        home: ParticipantRoomScreen(
          session: _buildTestSession(),
          voiceDictationService: FakeVoiceDictationService(),
          chatService: InMemoryChatService(),
          handRaiseService: handRaiseService,
        ),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Raise hand'));
    await tester.tap(find.widgetWithText(FilledButton, 'Raise hand'));
    await tester.pump();

    expect(find.widgetWithText(FilledButton, 'Hand raised'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(
      find.text('Your request is waiting for host approval.'),
      findsOneWidget,
    );
    expect(handRaiseService.currentRequests, hasLength(1));
    expect(handRaiseService.currentRequests.single.participantName, 'You');
  });
}
