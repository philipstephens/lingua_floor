import 'package:flutter/material.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/auth/presentation/join_screen.dart';

class LinguaFloorApp extends StatelessWidget {
  const LinguaFloorApp({super.key});

  EventSession _buildDemoSession() {
    final now = DateTime.now();
    return EventSession(
      eventName: 'Global Community Forum',
      hostLanguage: 'English',
      scheduledStartAt: now.add(const Duration(minutes: 20)),
      actualStartAt: null,
      endedAt: null,
      status: EventStatus.scheduled,
      supportedLanguages: const ['English', 'Spanish', 'French', 'Arabic'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinguaFloor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E7A)),
        scaffoldBackgroundColor: const Color(0xFFF4F7FA),
        useMaterial3: true,
      ),
      home: JoinScreen(session: _buildDemoSession()),
    );
  }
}

