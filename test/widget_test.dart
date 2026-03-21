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
import 'package:lingua_floor/features/host/presentation/polls_screen.dart';
import 'package:lingua_floor/features/microphone/domain/models/linux_offline_dictation_diagnostics.dart';
import 'package:lingua_floor/features/microphone/domain/models/voice_dictation_state.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/microphone/domain/services/voice_dictation_service.dart';
import 'package:lingua_floor/features/microphone/presentation/widgets/voice_dictation_composer.dart';
import 'package:lingua_floor/features/participant/presentation/participant_room_screen.dart';
import 'package:lingua_floor/features/speaker_draft/application/speaker_draft_controller.dart';
import 'package:lingua_floor/features/speaker_draft/data/in_memory_speaker_draft_service.dart';
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
  int startListeningCallCount = 0;
  int stopListeningCallCount = 0;

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
    startListeningCallCount += 1;
    _state =
        startListeningState ??
        VoiceDictationState(
          status: VoiceDictationStatus.listening,
          recognizedText: existingText.isEmpty
              ? 'Please raise my hand for the next question.'
              : existingText,
          isAvailable: true,
          activeLocaleId: localeId,
        );
    _controller.add(_state);
  }

  @override
  Future<void> stopListening() async {
    stopListeningCallCount += 1;
    _state = _state.copyWith(status: VoiceDictationStatus.ready);
    _controller.add(_state);
  }

  void emitState(VoiceDictationState nextState) {
    _state = nextState;
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
    transcriptRetentionPolicy: TranscriptRetentionPolicy.days30,
  );
}

Future<void> _openLanguagePicker(WidgetTester tester, Key fieldKey) async {
  final fieldFinder = find.byKey(fieldKey);
  await tester.pumpAndSettle();
  await tester.ensureVisible(fieldFinder.first);
  await tester.pumpAndSettle();
  await tester.tap(fieldFinder.first);
  await tester.pumpAndSettle();
}

Future<void> _pickLanguageOption(
  WidgetTester tester, {
  required String searchTerm,
  required String language,
}) async {
  await tester.enterText(
    find.byKey(const Key('language-picker-search-field')),
    searchTerm,
  );
  await tester.pump();

  final optionFinder = find.byKey(Key('language-picker-option-$language'));
  await tester.ensureVisible(optionFinder.first);
  await tester.tap(optionFinder.first);
  await tester.pumpAndSettle();
}

Future<void> _addCustomLanguageFromPicker(
  WidgetTester tester,
  String language,
) async {
  await tester.enterText(
    find.byKey(const Key('language-picker-custom-language-field')),
    language,
  );
  await tester.tap(find.byKey(const Key('language-picker-add-custom-button')));
  await tester.pumpAndSettle();
}

Future<void> _applyLanguagePicker(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('language-picker-apply-button')));
  await tester.pumpAndSettle();
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
    'app settings controller updates picker labels without affecting other settings',
    () {
      final controller = AppSettingsController();
      addTearDown(controller.dispose);

      controller.updatePickerLabels(
        datePickerButtonLabel: 'Choose date',
        timePickerButtonLabel: 'Choose time',
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
      moderationSettings: const ModerationSettings(
        formalProceduresEnabled: true,
      ),
      transcriptRetentionPolicy: TranscriptRetentionPolicy.days7,
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
    expect(
      controller.session.transcriptRetentionPolicy,
      TranscriptRetentionPolicy.days7,
    );
    expect(
      controller.session.moderationSettings,
      const ModerationSettings(formalProceduresEnabled: true),
    );
    expect(controller.session.transcriptExpiresAt, isNull);
  });

  test(
    'event session controller computes transcript expiry for ended events',
    () async {
      final endedAt = DateTime(2026, 1, 3, 14, 45);
      final controller = EventSessionController(
        service: InMemoryEventSessionService(
          seedSession: _buildTestSession().copyWith(
            status: EventStatus.ended,
            endedAt: endedAt,
          ),
        ),
        disposeService: true,
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      await controller.saveSetup(
        eventName: 'LinguaFloor Demo',
        hostLanguage: 'English',
        eventTimeZone: 'America/Toronto',
        isDaylightSavingTimeEnabled: true,
        scheduledStartAt: DateTime(2026, 1, 1, 9),
        status: EventStatus.ended,
        supportedLanguages: const ['English', 'French', 'Spanish'],
        moderationSettings: const ModerationSettings(
          meetingMode: MeetingMode.debate,
          formalProceduresEnabled: true,
        ),
        transcriptRetentionPolicy: TranscriptRetentionPolicy.days7,
      );

      expect(controller.errorMessage, isNull);
      expect(
        controller.session.transcriptExpiresAt,
        DateTime(2026, 1, 10, 14, 45),
      );
      expect(
        controller.session.moderationSettings,
        const ModerationSettings(meetingMode: MeetingMode.debate),
      );
    },
  );

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

  test(
    'speaker draft controller stores shared current-speaker draft',
    () async {
      final service = InMemorySpeakerDraftService();
      final hostController = SpeakerDraftController(
        service: service,
        disposeService: false,
      );
      final participantController = SpeakerDraftController(
        service: service,
        disposeService: false,
      );
      addTearDown(hostController.dispose);
      addTearDown(participantController.dispose);
      addTearDown(service.dispose);

      await hostController.initialize();
      await participantController.initialize();

      await hostController.ensureSpeaker(
        speakerLabel: 'Host',
        sourceLanguage: 'English',
      );
      await hostController.updateText('Welcome everyone.');

      expect(participantController.draft?.speakerLabel, 'Host');
      expect(participantController.draft?.sourceLanguage, 'English');
      expect(participantController.draft?.text, 'Welcome everyone.');

      await participantController.ensureSpeaker(
        speakerLabel: 'Maria',
        sourceLanguage: 'Spanish',
      );

      expect(hostController.draft?.speakerLabel, 'Maria');
      expect(hostController.draft?.sourceLanguage, 'Spanish');
      expect(hostController.draft?.text, isEmpty);
    },
  );

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
      currentParticipantLanguageProvider: () => 'Tagalog',
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    await controller.raiseHand();

    expect(controller.requests, hasLength(1));
    expect(controller.requests.single.participantName, 'You');
    expect(controller.requests.single.participantLanguage, 'Tagalog');
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

  test('hand-raise controller can reorder pending requests', () async {
    final controller = HandRaiseController(
      service: InMemoryHandRaiseService(
        seedRequests: [
          HandRaiseRequest(
            id: 'request-maria',
            participantName: 'Maria',
            participantLanguage: 'Spanish',
            requestedAt: DateTime(2026, 1, 1, 9, 0),
            status: HandRaiseRequestStatus.pending,
          ),
          HandRaiseRequest(
            id: 'request-omar',
            participantName: 'Omar',
            participantLanguage: 'Arabic',
            requestedAt: DateTime(2026, 1, 1, 9, 1),
            status: HandRaiseRequestStatus.pending,
          ),
          HandRaiseRequest(
            id: 'request-priya',
            participantName: 'Priya',
            participantLanguage: 'French',
            requestedAt: DateTime(2026, 1, 1, 9, 2),
            status: HandRaiseRequestStatus.approved,
          ),
        ],
      ),
      currentParticipantName: 'Host',
      disposeService: true,
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(
      controller.requests.map((request) => request.participantName).toList(),
      const ['Maria', 'Omar', 'Priya'],
    );

    await controller.moveRequestUp('request-omar');
    expect(
      controller.requests.map((request) => request.participantName).toList(),
      const ['Omar', 'Maria', 'Priya'],
    );

    await controller.moveRequestDown('request-omar');
    expect(
      controller.requests.map((request) => request.participantName).toList(),
      const ['Maria', 'Omar', 'Priya'],
    );
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
    expect(find.text('🇯🇵 JA'), findsOneWidget);
    expect(find.textContaining('Tokyo'), findsOneWidget);
    expect(find.textContaining('DST off'), findsOneWidget);
  });

  testWidgets('join screen shows compact language chip labels', (
    WidgetTester tester,
  ) async {
    final session = _buildTestSession().copyWith(
      supportedLanguages: const ['English', 'French', 'Klingon'],
    );

    await tester.pumpWidget(MaterialApp(home: JoinScreen(session: session)));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('join-language-English')),
        matching: find.text('🇬🇧 EN'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('join-language-French')),
        matching: find.text('🇫🇷 FR'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('join-language-Klingon')),
        matching: find.text('Klingon'),
      ),
      findsOneWidget,
    );
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

  testWidgets(
    'join screen opens settings and shows only event setup controls',
    (WidgetTester tester) async {
      await tester.pumpWidget(const LinguaFloorApp());

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);

      expect(find.text('Event setup'), findsOneWidget);
      expect(find.byKey(const Key('event-name-field')), findsOneWidget);
      expect(find.byKey(const Key('event-date-time-summary')), findsOneWidget);
      expect(find.byKey(const Key('event-timezone-field')), findsOneWidget);
      expect(find.byKey(const Key('event-dst-switch')), findsOneWidget);
      expect(find.byKey(const Key('host-language-field')), findsOneWidget);
      expect(
        find.byKey(const Key('supported-languages-field')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('save-event-setup-button')), findsOneWidget);
      expect(
        find.byKey(const Key('settings-date-picker-label-field')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('settings-time-picker-label-field')),
        findsNothing,
      );
      expect(find.byKey(const Key('save-settings-button')), findsNothing);
    },
  );

  testWidgets('host dashboard exposes microphone support scaffold', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LinguaFloorApp());

    await tester.tap(find.text('Enter as host'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('host-microphone-action')));
    await tester.pumpAndSettle();

    expect(find.text('Microphone setup & testing'), findsOneWidget);
    expect(
      find.text('Start capture').evaluate().isNotEmpty ||
          find.text('Stop capture').evaluate().isNotEmpty,
      isTrue,
    );
    expect(
      find.textContaining('Mock microphone/transcription service'),
      findsOneWidget,
    );
  });

  testWidgets(
    'host dashboard app bar opens microphone, polls, ban, and settings screens',
    (WidgetTester tester) async {
      await tester.pumpWidget(const LinguaFloorApp());

      await tester.tap(find.text('Enter as host'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('host-microphone-action')), findsOneWidget);
      expect(find.byKey(const Key('host-polls-action')), findsOneWidget);
      expect(find.byKey(const Key('host-ban-action')), findsOneWidget);
      expect(find.byTooltip('Settings'), findsOneWidget);

      await tester.tap(find.byTooltip('Microphone'));
      await tester.pumpAndSettle();

      expect(find.text('Microphone setup & testing'), findsOneWidget);
      expect(find.text('Microphone pipeline'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('host-polls-action')));
      await tester.pumpAndSettle();

      expect(find.text('Moderation policy'), findsOneWidget);
      expect(find.text('Poll controls'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('host-ban-action')));
      await tester.pumpAndSettle();

      expect(find.text('Ban controls'), findsOneWidget);
      expect(find.text('Recent moderation outcomes'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Event setup'), findsOneWidget);
    },
  );

  testWidgets('host floor queue can collapse, expand, and grant floor', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2000);
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
          participantLanguage: 'Spanish',
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

    expect(find.text('Floor board'), findsNothing);
    expect(find.text('Speaker'), findsNothing);
    expect(find.text('Banned'), findsNothing);
    expect(find.text('Floor control'), findsOneWidget);
    expect(find.byTooltip('Collapse floor control'), findsNothing);
    expect(find.byTooltip('Expand floor control'), findsNothing);
    expect(find.text('Floor queue'), findsOneWidget);
    expect(find.byTooltip('Collapse floor queue'), findsOneWidget);
    expect(find.byKey(const Key('floor-queue-scroll-hint')), findsOneWidget);
    expect(
      find.text('Scroll inside this panel to see the full queue.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('host-floor-board-queue-scrollable')),
      findsOneWidget,
    );
    expect(find.textContaining('1. Maria'), findsOneWidget);
    expect(
      find.byKey(const Key('participant-language-request-maria')),
      findsOneWidget,
    );
    expect(find.text('🇪🇸 Spanish'), findsOneWidget);
    expect(find.text('Grant floor'), findsOneWidget);

    await tester.tap(find.byKey(const Key('floor-queue-toggle-button')));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Expand floor queue'), findsOneWidget);
    expect(
      find.byKey(const Key('host-floor-board-queue-scrollable')),
      findsNothing,
    );
    expect(find.byKey(const Key('floor-queue-scroll-hint')), findsNothing);
    expect(find.textContaining('1. Maria'), findsNothing);

    await tester.tap(find.byKey(const Key('floor-queue-toggle-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('grant-floor-request-maria')));
    await tester.pumpAndSettle();

    expect(
      handRaiseService.currentRequests.single.status,
      HandRaiseRequestStatus.approved,
    );
    expect(find.text('Mark answered'), findsOneWidget);
  });

  testWidgets('debate mode keeps the queue ahead of the active speaker', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2000);
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
          participantLanguage: 'Spanish',
          requestedAt: DateTime(2026, 1, 1, 9),
          status: HandRaiseRequestStatus.approved,
        ),
        HandRaiseRequest(
          id: 'request-omar',
          participantName: 'Omar',
          participantLanguage: 'Arabic',
          requestedAt: DateTime(2026, 1, 1, 9, 1),
          status: HandRaiseRequestStatus.pending,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HostDashboardScreen(
          session: _buildTestSession().copyWith(
            moderationSettings: const ModerationSettings(
              meetingMode: MeetingMode.debate,
            ),
          ),
          handRaiseService: handRaiseService,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('Strict FIFO queue with recent-speaker override'),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.text('1. Omar')).dy,
      lessThan(tester.getTopLeft(find.text('2. Maria')).dy),
    );
  });

  testWidgets(
    'host meeting dialog shows mode-aware timer and recent-speaker guidance',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HostDashboardScreen(
            key: const ValueKey('staff-host-screen'),
            session: _buildTestSession(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Elapsed turn timer'), findsOneWidget);
      expect(find.text('Host holds the floor'), findsOneWidget);
      expect(
        find.text(
          'Elapsed time is advisory only. The host decides when to end the turn.',
        ),
        findsOneWidget,
      );
      expect(find.text('Recent speakers • follow-up priority'), findsOneWidget);

      final handRaiseService = InMemoryHandRaiseService(
        seedRequests: [
          HandRaiseRequest(
            id: 'request-maria',
            participantName: 'Maria',
            participantLanguage: 'Spanish',
            requestedAt: DateTime(2026, 1, 1, 9),
            status: HandRaiseRequestStatus.approved,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HostDashboardScreen(
            key: const ValueKey('debate-host-screen'),
            session: _buildTestSession().copyWith(
              moderationSettings: const ModerationSettings(
                meetingMode: MeetingMode.debate,
              ),
            ),
            handRaiseService: handRaiseService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hard turn timer'), findsOneWidget);
      expect(
        tester
            .widget<Text>(
              find.byKey(const Key('host-meeting-turn-timer-value')),
            )
            .data,
        endsWith('left'),
      );
      expect(
        find.text(
          'Auto-return at 00:00. Warning at 00:30 and critical at 00:10.',
        ),
        findsOneWidget,
      );
      expect(find.text('Recent speakers • host override'), findsOneWidget);
      expect(
        find.text(
          'Complete a turn to make recent-speaker overrides available here.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('host dashboard restores a persisted active turn snapshot', (
    WidgetTester tester,
  ) async {
    final restoredSession = _buildTestSession().copyWith(
      moderationSettings: const ModerationSettings(
        meetingMode: MeetingMode.debate,
      ),
      moderationRuntimeState: ModerationRuntimeState(
        activeFloor: ActiveFloorState(
          requestId: 'request-maria',
          speakerLabel: 'Maria',
          sourceLanguage: 'Spanish',
          startedAt: DateTime.now().subtract(
            const Duration(minutes: 1, seconds: 30),
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HostDashboardScreen(session: restoredSession)),
    );
    await tester.pump();

    expect(
      tester
          .widget<Text>(
            find.byKey(const Key('host-meeting-current-speaker-name')),
          )
          .data,
      'Maria',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('host-meeting-turn-timer-value')))
          .data,
      contains('left'),
    );
    expect(
      find.text('Maria can edit and send this draft from their own screen.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'polls screen adapts vote controls for formal procedures and debate mode',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PollsScreen(
            key: const ValueKey('formal-polls-screen'),
            session: _buildTestSession().copyWith(
              moderationSettings: const ModerationSettings(
                formalProceduresEnabled: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Polls & votes'), findsOneWidget);
      expect(find.text('Formal procedures enabled'), findsOneWidget);
      expect(
        find.byKey(const Key('open-vote-workflow-button')),
        findsOneWidget,
      );
      expect(find.text('Open formal vote'), findsOneWidget);
      expect(find.byKey(const Key('record-motion-button')), findsOneWidget);
      expect(find.byKey(const Key('approve-agenda-button')), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Carried'), 200);
      expect(find.text('For'), findsOneWidget);
      expect(find.text('Against'), findsOneWidget);
      expect(find.text('Carried'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: PollsScreen(
            key: const ValueKey('debate-polls-screen'),
            session: _buildTestSession().copyWith(
              moderationSettings: const ModerationSettings(
                meetingMode: MeetingMode.debate,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('open-vote-workflow-button')), findsNothing);
      expect(find.byKey(const Key('record-motion-button')), findsNothing);
      expect(find.byKey(const Key('approve-agenda-button')), findsNothing);
      expect(find.byKey(const Key('debate-mode-polls-helper')), findsOneWidget);
      expect(find.text('Formal procedures enabled'), findsNothing);
    },
  );

  testWidgets(
    'polls screen persists formal vote results and appends transcript summaries',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final session = _buildTestSession().copyWith(
        moderationSettings: const ModerationSettings(
          formalProceduresEnabled: true,
        ),
      );
      final eventSessionService = InMemoryEventSessionService(
        seedSession: session,
      );
      final transcriptFeedService = InMemoryTranscriptFeedService();
      addTearDown(eventSessionService.dispose);
      addTearDown(transcriptFeedService.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: PollsScreen(
            key: const ValueKey('polls-history-seed'),
            session: session,
            eventSessionService: eventSessionService,
            transcriptFeedService: transcriptFeedService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final recordMotionButton = find.byKey(const Key('record-motion-button'));
      await tester.ensureVisible(recordMotionButton);
      await tester.tap(recordMotionButton);
      await tester.pumpAndSettle();
      final incrementForButton = find.byKey(
        const Key('increment-option-0-button'),
      );
      await tester.ensureVisible(incrementForButton);
      await tester.tap(incrementForButton);
      await tester.pumpAndSettle();
      final closeVoteButton = find.byKey(
        const Key('close-formal-vote-carried-button'),
      );
      await tester.ensureVisible(closeVoteButton);
      await tester.tap(closeVoteButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('poll-history-card')), findsOneWidget);
      expect(find.text('Motion on the floor'), findsOneWidget);
      expect(find.text('Outcome: Carried'), findsOneWidget);
      expect(transcriptFeedService.currentSegments, hasLength(1));
      expect(
        transcriptFeedService.currentSegments.single.originalText,
        'Motion on the floor — Carried (For 1, Against 0, Abstain 0).',
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: PollsScreen(
            key: const ValueKey('polls-history-reopen'),
            session: session,
            eventSessionService: eventSessionService,
            transcriptFeedService: transcriptFeedService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('poll-history-card')), findsOneWidget);
      expect(find.text('Motion on the floor'), findsOneWidget);
      expect(find.text('Outcome: Carried'), findsOneWidget);
      expect(find.text('Active poll: none'), findsOneWidget);
    },
  );

  testWidgets(
    'host event welcome panel shows countdown before the event starts',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final scheduledSession = _buildTestSession().copyWith(
        eventName: 'Global Sync',
        status: EventStatus.scheduled,
        scheduledStartAt: DateTime.now().add(
          const Duration(hours: 1, minutes: 5, seconds: 55),
        ),
        clearActualStartAt: true,
      );

      await tester.pumpWidget(
        MaterialApp(home: HostDashboardScreen(session: scheduledSession)),
      );
      await tester.pump();

      expect(find.text('Event welcome'), findsOneWidget);
      expect(find.byTooltip('Collapse event welcome panel'), findsOneWidget);
      expect(find.text('Starting soon'), findsNothing);
      expect(find.byKey(const Key('host-event-welcome-message')), findsNothing);
      expect(find.text('Host/Pivot Language is: 🇬🇧 English'), findsOneWidget);
      expect(
        find.byKey(const Key('host-event-pivot-language-note')),
        findsNothing,
      );
      expect(find.text('Speaker: Host'), findsOneWidget);
      expect(find.text('Queue: 0 waiting'), findsOneWidget);
      expect(
        find.byKey(const Key('host-event-countdown-text')),
        findsOneWidget,
      );
      expect(
        find.text(
          'After the event has started this panel will show the meeting dialog.',
        ),
        findsOneWidget,
      );

      final countdownText = tester
          .widget<Text>(find.byKey(const Key('host-event-countdown-text')))
          .data!;
      expect(countdownText, contains('day'));
      expect(countdownText, contains('hour'));
      expect(countdownText, contains('minute'));
      expect(countdownText, contains('second'));

      await tester.tap(
        find.byKey(const Key('host-event-welcome-toggle-button')),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Expand event welcome panel'), findsOneWidget);
      expect(find.byKey(const Key('host-event-countdown-text')), findsNothing);
    },
  );

  testWidgets(
    'host event welcome panel lets host draft and send transcript after start',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final handRaiseService = InMemoryHandRaiseService(
        seedRequests: [
          HandRaiseRequest(
            id: 'pending-maria',
            participantName: 'Maria',
            participantLanguage: 'Spanish',
            requestedAt: DateTime(2026, 1, 1, 8, 59),
            status: HandRaiseRequestStatus.pending,
          ),
          HandRaiseRequest(
            id: 'pending-omar',
            participantName: 'Omar',
            participantLanguage: 'Arabic',
            requestedAt: DateTime(2026, 1, 1, 9, 0),
            status: HandRaiseRequestStatus.pending,
          ),
        ],
      );
      final transcriptFeedService = InMemoryTranscriptFeedService(
        seedSegments: List.generate(
          6,
          (index) => TranscriptSegment(
            speakerLabel: index.isEven ? 'Maria' : 'Host',
            originalText: 'Shared transcript line $index',
            capturedAt: DateTime(2026, 1, 1, 9, index),
            sourceLanguage: index.isEven ? 'Spanish' : 'English',
            targetLanguage: 'English',
            status: TranscriptSegmentStatus.translated,
            translatedText: 'Translated transcript line $index',
          ),
        ),
      );
      final voiceDictationService = FakeVoiceDictationService(
        startListeningState: const VoiceDictationState(
          status: VoiceDictationStatus.listening,
          recognizedText: 'Host live transcript from mic.',
          isAvailable: true,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HostDashboardScreen(
            session: _buildTestSession(),
            handRaiseService: handRaiseService,
            transcriptFeedService: transcriptFeedService,
            voiceDictationService: voiceDictationService,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Event welcome'), findsOneWidget);
      expect(
        find.byKey(const Key('host-meeting-dialog-title')),
        findsOneWidget,
      );
      expect(find.text('Meeting dialog'), findsOneWidget);
      expect(
        find.textContaining('LinguaFloor Demo event is underway'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('host-meeting-dialog-message')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('host-meeting-current-speaker-card')),
        findsOneWidget,
      );
      expect(find.text('Current speaker'), findsOneWidget);
      expect(
        find.byKey(const Key('host-meeting-current-speaker-name')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('host-meeting-current-speaker-pill')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('host-meeting-recent-speakers-label')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('host-meeting-recent-speakers-empty')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('host-meeting-current-speaker-card')),
          matching: find.byKey(
            const Key('host-meeting-speaker-megaphone-button'),
          ),
        ),
        findsNothing,
      );
      expect(
        find.byKey(const Key('host-meeting-speaker-megaphone-muted-overlay')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('host-meeting-live-message-card')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('host-meeting-live-message-card')),
          matching: find.byKey(
            const Key('host-meeting-speaker-megaphone-button'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('host-meeting-live-message-status')),
        findsOneWidget,
      );
      expect(find.text('Draft is empty'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('host-meeting-current-speaker-card')),
          matching: find.text('Host'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('host-meeting-draft-text-field')),
        findsOneWidget,
      );
      expect(find.text('Conversation'), findsOneWidget);
      expect(
        find.byKey(const Key('host-meeting-conversation-note')),
        findsOneWidget,
      );
      expect(
        find.text('Note: Host/Pivot Language is: 🇬🇧 English'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('host-meeting-dialog-conversation-scrollable')),
        findsOneWidget,
      );
      expect(find.text('Floor queue'), findsOneWidget);
      expect(
        tester
            .getTopLeft(find.byKey(const Key('host-meeting-dialog-title')))
            .dy,
        lessThan(tester.getTopLeft(find.text('Floor queue')).dy),
      );
      expect(
        tester
            .getTopLeft(
              find.byKey(const Key('host-meeting-current-speaker-card')),
            )
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(const Key('host-meeting-live-message-card')),
              )
              .dy,
        ),
      );
      expect(
        tester
            .getTopLeft(find.byKey(const Key('host-meeting-live-message-card')))
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(const Key('host-meeting-conversation-title')),
              )
              .dy,
        ),
      );
      expect(
        find.descendant(
          of: find.byKey(
            const Key('host-meeting-dialog-conversation-scrollable'),
          ),
          matching: find.text('Panel 6 • 00:05:00'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(
            const Key('host-meeting-dialog-conversation-scrollable'),
          ),
          matching: find.text('Shared transcript line 5'),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('host-meeting-speaker-megaphone-button')),
      );
      await tester.pumpAndSettle();

      expect(voiceDictationService.startListeningCallCount, 1);
      expect(
        find.byKey(const Key('host-meeting-speaker-megaphone-muted-overlay')),
        findsOneWidget,
      );
      expect(find.text('Listening on host microphone'), findsOneWidget);
      expect(
        find.byKey(const Key('host-meeting-live-message-flag')),
        findsOneWidget,
      );
      expect(find.text('🇬🇧'), findsOneWidget);
      expect(
        find.byKey(const Key('host-meeting-live-message-speaker')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('host-meeting-live-message-card')),
          matching: find.text('Host'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('host-meeting-live-message-card')),
          matching: find.text('Host live transcript from mic.'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(
            const Key('host-meeting-dialog-conversation-scrollable'),
          ),
          matching: find.text('Host live transcript from mic.'),
        ),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const Key('host-meeting-speaker-megaphone-button')),
      );
      await tester.pumpAndSettle();

      expect(voiceDictationService.stopListeningCallCount, 1);
      expect(
        find.byKey(const Key('host-meeting-speaker-megaphone-muted-overlay')),
        findsNothing,
      );
      expect(find.text('Ready to send to the live transcript'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('host-meeting-live-message-card')),
          matching: find.text('Host live transcript from mic.'),
        ),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.byKey(const Key('host-meeting-send-draft-button')),
      );
      await tester.tap(find.byKey(const Key('host-meeting-send-draft-button')));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(
            const Key('host-meeting-dialog-conversation-scrollable'),
          ),
          matching: find.text('Host live transcript from mic.'),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(
              find.byKey(const Key('host-meeting-draft-text-field')),
            )
            .controller
            ?.text,
        isEmpty,
      );
      expect(find.text('Draft is empty'), findsOneWidget);
    },
  );

  testWidgets(
    'host recent speakers chips dedupe order and cap at three while reassigning the floor',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2200);
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
            participantLanguage: 'Spanish',
            requestedAt: DateTime(2026, 1, 1, 9, 0),
            status: HandRaiseRequestStatus.pending,
          ),
          HandRaiseRequest(
            id: 'request-omar',
            participantName: 'Omar',
            participantLanguage: 'Arabic',
            requestedAt: DateTime(2026, 1, 1, 9, 1),
            status: HandRaiseRequestStatus.pending,
          ),
          HandRaiseRequest(
            id: 'request-priya',
            participantName: 'Priya',
            participantLanguage: 'French',
            requestedAt: DateTime(2026, 1, 1, 9, 2),
            status: HandRaiseRequestStatus.pending,
          ),
          HandRaiseRequest(
            id: 'request-chen',
            participantName: 'Chen',
            participantLanguage: 'Mandarin Chinese',
            requestedAt: DateTime(2026, 1, 1, 9, 3),
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

      Future<void> grantFloor(String requestId) async {
        final button = find.byKey(Key('grant-floor-$requestId'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
      }

      Future<void> markAnswered(String requestId) async {
        final button = find.byKey(Key('mark-answered-$requestId'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
      }

      Future<void> tapRecentSpeaker(String requestId) async {
        final chip = find.byKey(Key('host-meeting-recent-speaker-$requestId'));
        await tester.ensureVisible(chip);
        await tester.tap(chip);
        await tester.pumpAndSettle();
      }

      List<String> recentSpeakerLabels() {
        final chips = tester.widgetList<ActionChip>(
          find.descendant(
            of: find.byKey(const Key('host-meeting-recent-speakers-section')),
            matching: find.byType(ActionChip),
          ),
        );
        return chips
            .map((chip) => ((chip.label as Text).data ?? '').trim())
            .where((label) => label.isNotEmpty)
            .toList(growable: false);
      }

      expect(
        find.byKey(const Key('host-meeting-recent-speakers-empty')),
        findsOneWidget,
      );

      await grantFloor('request-maria');
      await markAnswered('request-maria');
      expect(recentSpeakerLabels(), ['Maria']);

      await grantFloor('request-omar');
      await markAnswered('request-omar');
      expect(recentSpeakerLabels(), ['Omar', 'Maria']);

      await grantFloor('request-priya');
      await markAnswered('request-priya');
      expect(recentSpeakerLabels(), ['Priya', 'Omar', 'Maria']);

      await tapRecentSpeaker('request-maria');

      expect(
        handRaiseService.currentRequests
            .firstWhere((request) => request.id == 'request-maria')
            .status,
        HandRaiseRequestStatus.approved,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('host-meeting-current-speaker-card')),
          matching: find.text('Maria'),
        ),
        findsOneWidget,
      );
      expect(recentSpeakerLabels(), ['Priya', 'Omar']);

      await markAnswered('request-maria');
      expect(recentSpeakerLabels(), ['Maria', 'Priya', 'Omar']);

      await grantFloor('request-chen');
      await markAnswered('request-chen');
      expect(recentSpeakerLabels(), ['Chen', 'Maria', 'Priya']);
      expect(
        find.byKey(const Key('host-meeting-recent-speaker-request-omar')),
        findsNothing,
      );
    },
  );

  testWidgets('host can ban and unban queued speakers from the floor board', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2000);
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
          participantLanguage: 'Spanish',
          requestedAt: DateTime(2026, 1, 1, 9, 0),
          status: HandRaiseRequestStatus.pending,
        ),
        HandRaiseRequest(
          id: 'request-omar',
          participantName: 'Omar',
          participantLanguage: 'Arabic',
          requestedAt: DateTime(2026, 1, 1, 9, 1),
          status: HandRaiseRequestStatus.pending,
        ),
        HandRaiseRequest(
          id: 'request-priya',
          participantName: 'Priya',
          participantLanguage: 'French',
          requestedAt: DateTime(2026, 1, 1, 9, 2),
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
    expect(find.textContaining('2. Omar'), findsOneWidget);
    expect(find.textContaining('3. Priya'), findsOneWidget);
    expect(find.text('🇪🇸 Spanish'), findsOneWidget);
    expect(find.text('🇸🇦 Arabic'), findsOneWidget);
    expect(find.text('🇫🇷 French'), findsOneWidget);
    expect(
      tester.getTopLeft(find.textContaining('1. Maria')).dy,
      lessThan(tester.getTopLeft(find.textContaining('2. Omar')).dy),
    );
    expect(
      tester.getTopLeft(find.textContaining('2. Omar')).dy,
      lessThan(tester.getTopLeft(find.textContaining('3. Priya')).dy),
    );
    expect(find.byKey(const Key('ban-request-maria')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ban-request-maria')));
    await tester.pumpAndSettle();

    expect(
      handRaiseService.currentRequests.first.status,
      HandRaiseRequestStatus.banned,
    );
    expect(find.byKey(const Key('unban-request-maria')), findsOneWidget);
    expect(find.byKey(const Key('grant-floor-request-maria')), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('unban-request-maria')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('unban-request-maria')));
    await tester.pumpAndSettle();

    expect(
      handRaiseService.currentRequests.first.status,
      HandRaiseRequestStatus.pending,
    );
    expect(find.byKey(const Key('grant-floor-request-maria')), findsOneWidget);
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

    await tester.tap(find.byKey(const Key('host-settings-action')));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.byKey(const Key('event-name-field'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('event-date-time-summary'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('event-date-time-summary'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('event-timezone-field'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('event-timezone-field'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('event-dst-switch'))).dy),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('event-dst-switch'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('host-language-field'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('host-language-field'))).dy,
      lessThan(
        tester
            .getTopLeft(find.byKey(const Key('supported-languages-field')))
            .dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('supported-languages-field'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('meeting-mode-field'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('meeting-mode-field'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('formal-procedures-switch'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('formal-procedures-switch'))).dy,
      lessThan(
        tester
            .getTopLeft(find.byKey(const Key('transcript-retention-field')))
            .dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('transcript-retention-field'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('save-event-setup-button'))).dy,
      ),
    );
    expect(find.byKey(const Key('event-status-field')), findsNothing);
    expect(find.text('Participant language preview'), findsNothing);
    expect(find.byKey(const Key('meeting-mode-field')), findsOneWidget);
    expect(find.byKey(const Key('formal-procedures-switch')), findsOneWidget);
    expect(find.byKey(const Key('transcript-retention-field')), findsOneWidget);
    expect(
      find.text('Transcript expires 30 days after the event ends.'),
      findsOneWidget,
    );

    expect(
      find.descendant(
        of: find.byKey(const Key('pick-schedule-date-button')),
        matching: find.text('Choose date'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('pick-schedule-time-button')),
        matching: find.text('Choose time'),
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('event-name-field')),
      'Global Town Hall',
    );
    await _openLanguagePicker(tester, const Key('host-language-field'));
    expect(find.text('North America'), findsOneWidget);
    expect(find.text('South America'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('North America')).dy,
      lessThan(tester.getTopLeft(find.text('South America')).dy),
    );
    await _pickLanguageOption(tester, searchTerm: 'German', language: 'German');

    await tester.tap(find.byKey(const Key('supported-languages-clear-button')));
    await tester.pumpAndSettle();
    await _openLanguagePicker(tester, const Key('supported-languages-field'));
    await _pickLanguageOption(tester, searchTerm: 'French', language: 'French');
    await _pickLanguageOption(
      tester,
      searchTerm: 'Japanese',
      language: 'Japanese',
    );
    await _applyLanguagePicker(tester);

    await tester.tap(find.byKey(const Key('event-timezone-field')));
    await tester.pumpAndSettle();
    expect(find.text("St. John's"), findsOneWidget);
    expect(find.text('Toronto'), findsWidgets);
    await tester.tap(find.text('Saskatoon / Last used location').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('meeting-mode-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Debate').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('formal-procedures-switch')), findsNothing);
    expect(
      find.text(
        'A strict FIFO queue stays primary while recent speakers remain a host override.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('transcript-retention-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forever').last);
    await tester.pumpAndSettle();
    expect(find.text('Transcript does not expire.'), findsOneWidget);

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
    expect(eventSessionService.currentSession.status, EventStatus.live);
    expect(
      eventSessionService.currentSession.scheduledStartAt,
      DateTime(2026, 2, 3, 14, 45),
    );
    expect(eventSessionService.currentSession.supportedLanguages, const [
      'German',
      'French',
      'Japanese',
    ]);
    expect(
      eventSessionService.currentSession.transcriptRetentionPolicy,
      TranscriptRetentionPolicy.forever,
    );
    expect(
      eventSessionService.currentSession.moderationSettings,
      const ModerationSettings(meetingMode: MeetingMode.debate),
    );
    expect(eventSessionService.currentSession.transcriptExpiresAt, isNull);
    expect(find.text('Event setup saved.'), findsOneWidget);
  });

  testWidgets('host settings hides preview and advanced setup controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: HostDashboardScreen(session: _buildTestSession())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('host-settings-action')));
    await tester.pumpAndSettle();

    expect(find.text('Participant language preview'), findsNothing);
    expect(
      find.byKey(const Key('host-translation-preview-English')),
      findsNothing,
    );
    expect(find.byKey(const Key('event-status-field')), findsNothing);
    expect(find.byKey(const Key('event-timezone-field')), findsOneWidget);
    expect(find.byKey(const Key('meeting-mode-field')), findsOneWidget);
    expect(find.byKey(const Key('formal-procedures-switch')), findsOneWidget);
    expect(find.byKey(const Key('transcript-retention-field')), findsOneWidget);
    expect(
      find.text('Transcript expires 30 days after the event ends.'),
      findsOneWidget,
    );
  });

  testWidgets('host settings shows an exact transcript expiry for ended events', (
    WidgetTester tester,
  ) async {
    final endedAt = DateTime(2026, 1, 5, 16, 15);
    final endedSession = _buildTestSession().copyWith(
      status: EventStatus.ended,
      endedAt: endedAt,
      transcriptRetentionPolicy: TranscriptRetentionPolicy.days7,
      transcriptExpiresAt: TranscriptRetentionPolicy.days7.expiresAtFrom(
        endedAt,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HostDashboardScreen(session: endedSession)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('host-settings-action')));
    await tester.pumpAndSettle();

    final helperContext = tester.element(
      find.byKey(const Key('transcript-retention-helper-text')),
    );
    final localizations = MaterialLocalizations.of(helperContext);
    final expiresAt = TranscriptRetentionPolicy.days7.expiresAtFrom(endedAt)!;
    final expectedHelper =
        'Transcript expires on ${localizations.formatMediumDate(expiresAt)} at ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(expiresAt))}.';

    expect(find.text(expectedHelper), findsOneWidget);
  });

  testWidgets('host event setup still supports custom participant languages', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final eventSessionService = InMemoryEventSessionService(
      seedSession: _buildTestSession(),
    );
    addTearDown(eventSessionService.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: HostDashboardScreen(
          session: _buildTestSession(),
          eventSessionService: eventSessionService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('host-settings-action')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('supported-languages-clear-button')),
    );
    await tester.tap(find.byKey(const Key('supported-languages-clear-button')));
    await tester.pumpAndSettle();
    await _openLanguagePicker(tester, const Key('supported-languages-field'));
    await _pickLanguageOption(tester, searchTerm: 'French', language: 'French');
    await _addCustomLanguageFromPicker(tester, 'Klingon');
    await _applyLanguagePicker(tester);

    await tester.tap(find.byKey(const Key('save-event-setup-button')));
    await tester.pump();

    expect(eventSessionService.currentSession.supportedLanguages, const [
      'English',
      'French',
      'Klingon',
    ]);
    expect(find.text('Event setup saved.'), findsOneWidget);
  });

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

  testWidgets('participant can edit and send the shared draft when approved', (
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
          id: 'approved-you',
          participantName: 'You',
          participantLanguage: 'English',
          requestedAt: DateTime(2026, 1, 1, 9),
          status: HandRaiseRequestStatus.approved,
        ),
      ],
    );
    final transcriptFeedService = InMemoryTranscriptFeedService();

    await tester.pumpWidget(
      MaterialApp(
        home: ParticipantRoomScreen(
          session: _buildTestSession(),
          voiceDictationService: FakeVoiceDictationService(),
          chatService: InMemoryChatService(),
          handRaiseService: handRaiseService,
          transcriptFeedService: transcriptFeedService,
          speakerDraftService: InMemorySpeakerDraftService(),
        ),
      ),
    );

    final draftField = find.byKey(
      const Key('participant-current-draft-text-field'),
    );
    await tester.ensureVisible(draftField);

    await tester.enterText(draftField, 'Can I ask a follow-up question?');
    await tester.pump();
    final sendButton = find.widgetWithText(FilledButton, 'Send to transcript');
    await tester.ensureVisible(sendButton);
    await tester.pumpAndSettle();
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(transcriptFeedService.currentSegments, hasLength(1));
    expect(transcriptFeedService.currentSegments.single.speakerLabel, 'You');
    expect(
      transcriptFeedService.currentSegments.single.originalText,
      'Can I ask a follow-up question?',
    );
    expect(find.textContaining('Transcript message sent:'), findsOneWidget);
    expect(tester.widget<TextField>(draftField).controller?.text, isEmpty);
  });

  testWidgets('host and participant stay in sync on the shared current draft', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(2200, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final session = _buildTestSession();
    final eventSessionService = InMemoryEventSessionService(
      seedSession: session,
    );
    final handRaiseService = InMemoryHandRaiseService(
      seedRequests: [
        HandRaiseRequest(
          id: 'approved-you',
          participantName: 'You',
          participantLanguage: 'English',
          requestedAt: DateTime(2026, 1, 1, 9),
          status: HandRaiseRequestStatus.approved,
        ),
      ],
    );
    final transcriptFeedService = InMemoryTranscriptFeedService();
    final speakerDraftService = InMemorySpeakerDraftService();
    final hostVoiceDictationService = FakeVoiceDictationService();
    final participantVoiceDictationService = FakeVoiceDictationService();
    addTearDown(eventSessionService.dispose);
    addTearDown(handRaiseService.dispose);
    addTearDown(transcriptFeedService.dispose);
    addTearDown(speakerDraftService.dispose);
    addTearDown(hostVoiceDictationService.dispose);
    addTearDown(participantVoiceDictationService.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            Expanded(
              child: HostDashboardScreen(
                session: session,
                eventSessionService: eventSessionService,
                handRaiseService: handRaiseService,
                transcriptFeedService: transcriptFeedService,
                speakerDraftService: speakerDraftService,
                voiceDictationService: hostVoiceDictationService,
              ),
            ),
            Expanded(
              child: ParticipantRoomScreen(
                session: session,
                eventSessionService: eventSessionService,
                handRaiseService: handRaiseService,
                transcriptFeedService: transcriptFeedService,
                speakerDraftService: speakerDraftService,
                voiceDictationService: participantVoiceDictationService,
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final hostDraftField = find.byKey(
      const Key('host-meeting-draft-text-field'),
    );
    final participantDraftField = find.byKey(
      const Key('participant-current-draft-text-field'),
    );

    expect(
      find.descendant(
        of: find.byKey(const Key('host-meeting-current-speaker-card')),
        matching: find.text('You'),
      ),
      findsOneWidget,
    );
    expect(tester.widget<TextField>(hostDraftField).readOnly, isTrue);
    expect(tester.widget<TextField>(participantDraftField).readOnly, isFalse);

    await tester.enterText(
      participantDraftField,
      'Shared draft synced between participant and host.',
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(participantDraftField).controller?.text,
      'Shared draft synced between participant and host.',
    );
    expect(
      tester.widget<TextField>(hostDraftField).controller?.text,
      'Shared draft synced between participant and host.',
    );
    expect(speakerDraftService.currentDraft?.speakerLabel, 'You');

    final participantSendButton = find.descendant(
      of: find.byType(VoiceDictationComposer),
      matching: find.widgetWithText(FilledButton, 'Send to transcript'),
    );
    await tester.tap(participantSendButton);
    await tester.pumpAndSettle();

    expect(transcriptFeedService.currentSegments, hasLength(1));
    expect(
      transcriptFeedService.currentSegments.single.originalText,
      'Shared draft synced between participant and host.',
    );
    expect(tester.widget<TextField>(hostDraftField).controller?.text, isEmpty);
    expect(
      tester.widget<TextField>(participantDraftField).controller?.text,
      isEmpty,
    );
    expect(
      find.descendant(
        of: find.byKey(
          const Key('host-meeting-dialog-conversation-scrollable'),
        ),
        matching: find.text(
          'Shared draft synced between participant and host.',
        ),
      ),
      findsOneWidget,
    );
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

    expect(find.text('Language: 🇬🇧 EN'), findsOneWidget);
    expect(find.text('View: original'), findsOneWidget);
    expect(
      find.text(
        'Welcome to LinguaFloor Demo. Live translation is active for today\'s discussion.',
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('participant-language-picker-button')),
      250,
      scrollable: scrollable,
    );
    await tester.ensureVisible(
      find.byKey(const Key('participant-language-picker-button')),
    );
    await tester.pumpAndSettle();

    await _openLanguagePicker(
      tester,
      const Key('participant-language-picker-button'),
    );
    await _pickLanguageOption(tester, searchTerm: 'French', language: 'French');

    await tester.ensureVisible(
      find.text(
        'Original: Welcome to LinguaFloor Demo. Live translation is active for today\'s discussion.',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Language: 🇫🇷 FR'), findsOneWidget);
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
        find.byKey(const Key('participant-language-picker-button')),
        250,
        scrollable: scrollable,
      );
      await tester.ensureVisible(
        find.byKey(const Key('participant-language-picker-button')),
      );
      await tester.pumpAndSettle();

      await _openLanguagePicker(
        tester,
        const Key('participant-language-picker-button'),
      );
      await _pickLanguageOption(
        tester,
        searchTerm: 'French',
        language: 'French',
      );

      expect(find.text('Language: 🇫🇷 FR'), findsOneWidget);
      expect(find.text('View: translated'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enter as participant'));
      await tester.pumpAndSettle();

      expect(find.text('Language: 🇫🇷 FR'), findsOneWidget);
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
      String? rememberedTranscriptLanguage = 'French';

      await tester.pumpWidget(
        MaterialApp(
          home: ParticipantRoomScreen(
            session: fallbackSession,
            preferredTranscriptLanguage: rememberedTranscriptLanguage,
            onPreferredTranscriptLanguageChanged: (language) async {
              rememberedTranscriptLanguage = language;
            },
            voiceDictationService: FakeVoiceDictationService(),
            chatService: InMemoryChatService(),
            handRaiseService: InMemoryHandRaiseService(),
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

      expect(find.text('Language: 🇬🇧 EN'), findsOneWidget);
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
      expect(rememberedTranscriptLanguage, 'English');
    },
  );

  testWidgets(
    'participant canonicalizes remembered original conversation when host language is omitted from supported languages',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fallbackSession = _buildTestSession().copyWith(
        supportedLanguages: const ['French', 'Spanish'],
      );
      String? rememberedTranscriptLanguage = 'english';

      await tester.pumpWidget(
        MaterialApp(
          home: ParticipantRoomScreen(
            session: fallbackSession,
            preferredTranscriptLanguage: rememberedTranscriptLanguage,
            onPreferredTranscriptLanguageChanged: (language) async {
              rememberedTranscriptLanguage = language;
            },
            voiceDictationService: FakeVoiceDictationService(),
            chatService: InMemoryChatService(),
            handRaiseService: InMemoryHandRaiseService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Language: 🇬🇧 EN'), findsOneWidget);
      expect(find.text('View: original'), findsOneWidget);
      expect(
        find.byKey(const Key('participant-unavailable-language-notice')),
        findsNothing,
      );
      expect(rememberedTranscriptLanguage, 'English');
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
      find.byKey(const Key('participant-language-picker-button')),
      250,
      scrollable: scrollable,
    );
    await tester.ensureVisible(
      find.byKey(const Key('participant-language-picker-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Live translation ready: 🇫🇷 FR'), findsOneWidget);
    expect(find.text('Showing original for now: Klingon'), findsOneWidget);

    await _openLanguagePicker(
      tester,
      const Key('participant-language-picker-button'),
    );
    await _pickLanguageOption(
      tester,
      searchTerm: 'Klingon',
      language: 'Klingon',
    );

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

  testWidgets('participant language picker shows room summary and options', (
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
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byKey(const Key('participant-language-picker-button')),
      250,
      scrollable: scrollable,
    );
    await tester.ensureVisible(
      find.byKey(const Key('participant-language-picker-button')),
    );
    await tester.pumpAndSettle();

    await _openLanguagePicker(
      tester,
      const Key('participant-language-picker-button'),
    );

    expect(
      find.text('Available in this room: 🇬🇧 EN, 🇫🇷 FR, Klingon'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('language-picker-option-English')),
      findsOneWidget,
    );
    expect(find.text('🇬🇧 English'), findsWidgets);
    expect(find.text('🇫🇷 French'), findsOneWidget);
    expect(
      find.byKey(const Key('language-picker-option-Klingon')),
      findsOneWidget,
    );
  });

  testWidgets(
    'participant still offers the original conversation when host language is omitted from supported languages',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fallbackSession = _buildTestSession().copyWith(
        supportedLanguages: const ['French', 'Spanish'],
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
        find.byKey(const Key('participant-language-picker-button')),
        250,
        scrollable: scrollable,
      );
      await tester.ensureVisible(
        find.byKey(const Key('participant-language-picker-button')),
      );
      await tester.pumpAndSettle();

      await _openLanguagePicker(
        tester,
        const Key('participant-language-picker-button'),
      );
      expect(
        find.byKey(const Key('language-picker-option-English')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('language-picker-cancel-button')));
      await tester.pumpAndSettle();
      expect(find.text('Language: 🇬🇧 EN'), findsOneWidget);

      await _openLanguagePicker(
        tester,
        const Key('participant-language-picker-button'),
      );
      await _pickLanguageOption(
        tester,
        searchTerm: 'French',
        language: 'French',
      );

      expect(find.text('Language: 🇫🇷 FR'), findsOneWidget);
      expect(find.text('View: translated'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const Key('participant-language-picker-button')),
        250,
        scrollable: scrollable,
      );
      await tester.ensureVisible(
        find.byKey(const Key('participant-language-picker-button')),
      );
      await tester.pumpAndSettle();

      await _openLanguagePicker(
        tester,
        const Key('participant-language-picker-button'),
      );
      await _pickLanguageOption(
        tester,
        searchTerm: 'English',
        language: 'English',
      );

      expect(find.text('Language: 🇬🇧 EN'), findsOneWidget);
      expect(find.text('View: original'), findsOneWidget);
    },
  );

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

    final scrollable = find.byKey(
      const Key('host-meeting-dialog-conversation-scrollable'),
    );

    expect(
      find.descendant(of: scrollable, matching: find.text('Hello everyone.')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: scrollable, matching: find.text('Original French')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: scrollable,
        matching: find.text('Bonjour à tout le monde.'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('host-meeting-dialog-content')),
        matching: find.text('Conversation in 🇬🇧 EN'),
      ),
      findsOneWidget,
    );
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

      await tester.tap(find.byKey(const Key('host-microphone-action')));
      await tester.pumpAndSettle();

      final startCaptureButton = find.widgetWithText(
        FilledButton,
        'Start capture',
      );
      final hostScrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        startCaptureButton,
        250,
        scrollable: hostScrollable,
      );
      await tester.pumpAndSettle();
      await tester.tap(startCaptureButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 3));

      expect(transcriptFeedService.currentSegments, isNotEmpty);
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('host-meeting-dialog-title')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('host-meeting-dialog-conversation-scrollable')),
        findsOneWidget,
      );

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
        find.byKey(const Key('participant-language-picker-button')),
        250,
        scrollable: participantScrollable,
      );
      await tester.ensureVisible(
        find.byKey(const Key('participant-language-picker-button')),
      );
      await tester.pumpAndSettle();

      await _openLanguagePicker(
        tester,
        const Key('participant-language-picker-button'),
      );
      await _pickLanguageOption(
        tester,
        searchTerm: 'French',
        language: 'French',
      );

      expect(find.text('Language: 🇫🇷 FR'), findsOneWidget);
      expect(find.text('Feed: shared live'), findsOneWidget);
      expect(
        find.text(
          'Bienvenue à LinguaFloor Demo. Ce pipeline simulé remplace actuellement la capture microphone en direct.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'participant cannot raise a hand request before the event starts',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final handRaiseService = InMemoryHandRaiseService();
      final scheduledSession = _buildTestSession().copyWith(
        status: EventStatus.scheduled,
        scheduledStartAt: DateTime.now().add(const Duration(hours: 1)),
        clearActualStartAt: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ParticipantRoomScreen(
            session: scheduledSession,
            voiceDictationService: FakeVoiceDictationService(),
            chatService: InMemoryChatService(),
            handRaiseService: handRaiseService,
          ),
        ),
      );
      await tester.pump();

      final raiseHandButton = find.widgetWithText(FilledButton, 'Raise hand');
      await tester.ensureVisible(raiseHandButton);

      expect(find.text('Queue closed'), findsOneWidget);
      expect(
        find.text('Hand raise will open when the event starts.'),
        findsOneWidget,
      );
      expect(tester.widget<FilledButton>(raiseHandButton).onPressed, isNull);
      expect(handRaiseService.currentRequests, isEmpty);
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
