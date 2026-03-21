import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/hand_raise/application/hand_raise_controller.dart';
import 'package:lingua_floor/features/hand_raise/data/in_memory_hand_raise_service.dart';
import 'package:lingua_floor/features/hand_raise/domain/models/hand_raise_request.dart';
import 'package:lingua_floor/features/host/application/floor_control_controller.dart';

void main() {
  group('FloorControlController', () {
    test(
      'answers the active speaker before approving the next request',
      () async {
        final handRaiseController = HandRaiseController(
          service: InMemoryHandRaiseService(
            seedRequests: [
              _request(
                'request-maria',
                'Maria',
                status: HandRaiseRequestStatus.approved,
              ),
              _request('request-omar', 'Omar'),
            ],
          ),
          currentParticipantName: 'Host Maya',
          disposeService: true,
        );
        addTearDown(handRaiseController.dispose);

        final controller = FloorControlController(
          handRaiseController: handRaiseController,
        );
        addTearDown(controller.dispose);

        await handRaiseController.initialize();
        await controller.assignFloorToRequest(
          _findRequest(controller, 'request-omar'),
        );

        expect(
          _statusFor(controller, 'request-maria'),
          HandRaiseRequestStatus.answered,
        );
        expect(
          _statusFor(controller, 'request-omar'),
          HandRaiseRequestStatus.approved,
        );
        expect(controller.currentSpeakerRequest?.id, 'request-omar');
        expect(
          controller.recentSpeakers.map((speaker) => speaker.participantName),
          ['Maria'],
        );
      },
    );

    test(
      'dedupes recent speakers, keeps newest first, and caps the list at three',
      () async {
        final handRaiseController = HandRaiseController(
          service: InMemoryHandRaiseService(
            seedRequests: [
              _request('request-maria', 'Maria', language: 'Spanish'),
              _request('request-omar', 'Omar', language: 'Arabic'),
              _request('request-priya', 'Priya', language: 'French'),
              _request('request-chen', 'Chen', language: 'Mandarin Chinese'),
            ],
          ),
          currentParticipantName: 'Host Maya',
          disposeService: true,
        );
        addTearDown(handRaiseController.dispose);

        final controller = FloorControlController(
          handRaiseController: handRaiseController,
        );
        addTearDown(controller.dispose);

        await handRaiseController.initialize();

        await _grantAndAnswer(controller, 'request-maria');
        expect(_recentSpeakerLabels(controller), ['Maria']);

        await _grantAndAnswer(controller, 'request-omar');
        expect(_recentSpeakerLabels(controller), ['Omar', 'Maria']);

        await _grantAndAnswer(controller, 'request-priya');
        expect(_recentSpeakerLabels(controller), ['Priya', 'Omar', 'Maria']);

        await controller.giveFloorToRecentSpeaker(
          controller.visibleRecentSpeakers.firstWhere(
            (speaker) => speaker.requestId == 'request-maria',
          ),
        );

        expect(
          _statusFor(controller, 'request-maria'),
          HandRaiseRequestStatus.approved,
        );
        expect(controller.currentSpeakerRequest?.participantName, 'Maria');
        expect(_recentSpeakerLabels(controller), ['Priya', 'Omar']);

        await controller.markRequestAnswered('request-maria');
        expect(_recentSpeakerLabels(controller), ['Maria', 'Priya', 'Omar']);

        await _grantAndAnswer(controller, 'request-chen');
        expect(_recentSpeakerLabels(controller), ['Chen', 'Maria', 'Priya']);
        expect(
          controller.visibleRecentSpeakers.where(
            (speaker) => speaker.requestId == 'request-omar',
          ),
          isEmpty,
        );
      },
    );

    test(
      'debate mode auto-returns the floor when the hard timer expires',
      () async {
        var fakeNow = DateTime(2026, 1, 1, 9);
        final handRaiseController = HandRaiseController(
          service: InMemoryHandRaiseService(
            seedRequests: [_request('request-maria', 'Maria')],
          ),
          currentParticipantName: 'Host Maya',
          disposeService: true,
        );
        addTearDown(handRaiseController.dispose);

        final controller = FloorControlController(
          handRaiseController: handRaiseController,
          moderationSettings: const ModerationSettings(
            meetingMode: MeetingMode.debate,
          ),
          nowProvider: () => fakeNow,
          tickInterval: const Duration(days: 1),
          debateTurnLimit: const Duration(seconds: 30),
          debateWarningThreshold: const Duration(seconds: 10),
          debateCriticalThreshold: const Duration(seconds: 5),
        );
        addTearDown(controller.dispose);

        await handRaiseController.initialize();
        await controller.assignFloorToRequest(
          _findRequest(controller, 'request-maria'),
        );

        expect(controller.speakerTurnSnapshot.valueText, '00:30 left');

        fakeNow = fakeNow.add(const Duration(seconds: 30));
        await controller.refreshTurnTimer();

        expect(controller.currentSpeakerRequest, isNull);
        expect(
          _statusFor(controller, 'request-maria'),
          HandRaiseRequestStatus.answered,
        );
        expect(_recentSpeakerLabels(controller), ['Maria']);
      },
    );

    test(
      'staff meeting timer stays advisory and escalates by elapsed time',
      () async {
        var fakeNow = DateTime(2026, 1, 1, 9);
        final handRaiseController = HandRaiseController(
          service: InMemoryHandRaiseService(
            seedRequests: [_request('request-maria', 'Maria')],
          ),
          currentParticipantName: 'Host Maya',
          disposeService: true,
        );
        addTearDown(handRaiseController.dispose);

        final controller = FloorControlController(
          handRaiseController: handRaiseController,
          nowProvider: () => fakeNow,
          tickInterval: const Duration(days: 1),
          staffWarningThreshold: const Duration(seconds: 3),
          staffCriticalThreshold: const Duration(seconds: 5),
        );
        addTearDown(controller.dispose);

        await handRaiseController.initialize();
        await controller.assignFloorToRequest(
          _findRequest(controller, 'request-maria'),
        );

        expect(
          controller.speakerTurnSnapshot.stage,
          SpeakerTurnTimerStage.normal,
        );
        expect(controller.speakerTurnSnapshot.autoReturnsFloor, isFalse);

        fakeNow = fakeNow.add(const Duration(seconds: 4));
        await controller.refreshTurnTimer();

        expect(controller.currentSpeakerRequest?.participantName, 'Maria');
        expect(
          controller.speakerTurnSnapshot.stage,
          SpeakerTurnTimerStage.warning,
        );
        expect(controller.speakerTurnSnapshot.valueText, '00:04 elapsed');

        fakeNow = fakeNow.add(const Duration(seconds: 2));
        await controller.refreshTurnTimer();

        expect(controller.currentSpeakerRequest?.participantName, 'Maria');
        expect(
          controller.speakerTurnSnapshot.stage,
          SpeakerTurnTimerStage.critical,
        );
      },
    );
  });
}

Future<void> _grantAndAnswer(
  FloorControlController controller,
  String requestId,
) async {
  await controller.assignFloorToRequest(_findRequest(controller, requestId));
  await controller.markRequestAnswered(requestId);
}

HandRaiseRequest _findRequest(
  FloorControlController controller,
  String requestId,
) {
  return controller.requests.firstWhere((request) => request.id == requestId);
}

HandRaiseRequestStatus _statusFor(
  FloorControlController controller,
  String requestId,
) {
  return _findRequest(controller, requestId).status;
}

List<String> _recentSpeakerLabels(FloorControlController controller) {
  return controller.recentSpeakers
      .map((speaker) => speaker.participantName)
      .toList(growable: false);
}

HandRaiseRequest _request(
  String id,
  String name, {
  String? language,
  HandRaiseRequestStatus status = HandRaiseRequestStatus.pending,
}) {
  return HandRaiseRequest(
    id: id,
    participantName: name,
    participantLanguage: language,
    requestedAt: DateTime(2026, 1, 1, 9),
    status: status,
  );
}
