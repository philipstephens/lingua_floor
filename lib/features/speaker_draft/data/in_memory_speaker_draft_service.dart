import 'dart:async';

import 'package:lingua_floor/features/speaker_draft/domain/models/speaker_draft.dart';
import 'package:lingua_floor/features/speaker_draft/domain/services/speaker_draft_service.dart';

class InMemorySpeakerDraftService implements SpeakerDraftService {
  InMemorySpeakerDraftService({SpeakerDraft? initialDraft})
    : _draft = initialDraft;

  final StreamController<SpeakerDraft?> _controller =
      StreamController<SpeakerDraft?>.broadcast();

  SpeakerDraft? _draft;

  @override
  SpeakerDraft? get currentDraft => _draft;

  @override
  Stream<SpeakerDraft?> watchDraft() => _controller.stream;

  @override
  Future<void> initialize() async {
    _emit(_draft);
  }

  @override
  Future<void> ensureSpeaker({
    required String speakerLabel,
    required String sourceLanguage,
  }) async {
    final now = DateTime.now();
    final trimmedSpeakerLabel = speakerLabel.trim().isEmpty
        ? 'Speaker'
        : speakerLabel.trim();
    final trimmedSourceLanguage = sourceLanguage.trim();
    final currentDraft = _draft;

    if (currentDraft != null &&
        currentDraft.speakerLabel.toLowerCase() ==
            trimmedSpeakerLabel.toLowerCase()) {
      _draft = currentDraft.copyWith(
        sourceLanguage: trimmedSourceLanguage,
        updatedAt: now,
      );
      _emit(_draft);
      return;
    }

    _draft = SpeakerDraft(
      speakerLabel: trimmedSpeakerLabel,
      sourceLanguage: trimmedSourceLanguage,
      text: '',
      updatedAt: now,
    );
    _emit(_draft);
  }

  @override
  Future<void> updateText(String text) async {
    final draft = _draft;
    if (draft == null) {
      return;
    }

    _draft = draft.copyWith(text: text, updatedAt: DateTime.now());
    _emit(_draft);
  }

  @override
  Future<void> clear() async {
    final draft = _draft;
    if (draft == null) {
      return;
    }

    _draft = draft.copyWith(text: '', updatedAt: DateTime.now());
    _emit(_draft);
  }

  @override
  void dispose() {
    _controller.close();
  }

  void _emit(SpeakerDraft? draft) {
    if (!_controller.isClosed) {
      _controller.add(draft);
    }
  }
}
