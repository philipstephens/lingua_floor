import 'package:flutter/material.dart';
import 'package:lingua_floor/app/app_settings.dart';
import 'package:lingua_floor/core/config/app_runtime_config.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/core/translation/language_code_mapper.dart';
import 'package:lingua_floor/features/auth/presentation/join_screen.dart';
import 'package:lingua_floor/features/event_setup/data/in_memory_event_session_service.dart';
import 'package:lingua_floor/features/hand_raise/data/in_memory_hand_raise_service.dart';
import 'package:lingua_floor/features/hand_raise/domain/models/hand_raise_request.dart';
import 'package:lingua_floor/features/transcript/data/in_memory_transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/data/in_memory_transcript_lane_service.dart';

class LinguaFloorApp extends StatefulWidget {
  const LinguaFloorApp({
    super.key,
    this.runtimeConfig = AppRuntimeConfig.empty,
  });

  final AppRuntimeConfig runtimeConfig;

  @override
  State<LinguaFloorApp> createState() => _LinguaFloorAppState();
}

class _LinguaFloorAppState extends State<LinguaFloorApp> {
  late final EventSession _demoSession;
  late final AppSettingsController _appSettingsController;
  late final InMemoryEventSessionService _eventSessionService;
  late final InMemoryHandRaiseService _handRaiseService;
  late final InMemoryTranscriptFeedService _transcriptFeedService;
  late final InMemoryTranscriptLaneService _transcriptLaneService;

  @override
  void initState() {
    super.initState();
    _demoSession = _buildDemoSession();
    _appSettingsController = AppSettingsController();
    _eventSessionService = InMemoryEventSessionService(
      seedSession: _demoSession,
    );
    _handRaiseService = InMemoryHandRaiseService(
      seedRequests: _buildDemoHandRaiseRequests(),
    );
    _transcriptFeedService = InMemoryTranscriptFeedService();
    _transcriptLaneService = InMemoryTranscriptLaneService(
      eventSessionService: _eventSessionService,
      transcriptFeedService: _transcriptFeedService,
    );
  }

  EventSession _buildDemoSession() {
    final now = DateTime.now();
    return EventSession(
      eventName: 'Global Community Forum',
      hostLanguage: 'English',
      eventTimeZone: 'America/Regina',
      isDaylightSavingTimeEnabled: false,
      scheduledStartAt: now.add(const Duration(minutes: 20)),
      actualStartAt: null,
      endedAt: null,
      status: EventStatus.scheduled,
      supportedLanguages: machineTranslationFeaturedLanguages,
    );
  }

  List<HandRaiseRequest> _buildDemoHandRaiseRequests() {
    final now = DateTime.now();
    return [
      HandRaiseRequest(
        id: 'seed-maria',
        participantName: 'Maria',
        requestedAt: now.subtract(const Duration(seconds: 45)),
        status: HandRaiseRequestStatus.pending,
      ),
      HandRaiseRequest(
        id: 'seed-omar',
        participantName: 'Omar',
        requestedAt: now.subtract(const Duration(minutes: 1, seconds: 12)),
        status: HandRaiseRequestStatus.pending,
      ),
    ];
  }

  @override
  void dispose() {
    _appSettingsController.dispose();
    _transcriptLaneService.dispose();
    _eventSessionService.dispose();
    _handRaiseService.dispose();
    _transcriptFeedService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppRuntimeConfigScope(
      config: widget.runtimeConfig,
      child: AppSettingsScope(
        controller: _appSettingsController,
        child: MaterialApp(
          title: 'LinguaFloor',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B5E7A),
            ),
            scaffoldBackgroundColor: const Color(0xFFF4F7FA),
            useMaterial3: true,
          ),
          home: JoinScreen(
            session: _demoSession,
            eventSessionService: _eventSessionService,
            handRaiseService: _handRaiseService,
            transcriptFeedService: _transcriptFeedService,
            transcriptLaneService: _transcriptLaneService,
          ),
        ),
      ),
    );
  }
}
