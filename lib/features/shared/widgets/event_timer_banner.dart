import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lingua_floor/core/models/event_session.dart';

class EventTimerBanner extends StatefulWidget {
  const EventTimerBanner({super.key, required this.session});

  final EventSession session;

  @override
  State<EventTimerBanner> createState() => _EventTimerBannerState();
}

class _EventTimerBannerState extends State<EventTimerBanner> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration value) {
    final abs = value.abs();
    final hours = abs.inHours.toString().padLeft(2, '0');
    final minutes = (abs.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (abs.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _statusText(DateTime now) {
    switch (widget.session.status) {
      case EventStatus.scheduled:
        final remaining = widget.session.scheduledStartAt.difference(now);
        return remaining.isNegative
            ? 'Scheduled start time reached'
            : 'Starts in ${_formatDuration(remaining)}';
      case EventStatus.live:
        final start = widget.session.actualStartAt ?? widget.session.scheduledStartAt;
        return 'Live • ${_formatDuration(now.difference(start))}';
      case EventStatus.ended:
        final start = widget.session.actualStartAt ?? widget.session.scheduledStartAt;
        final end = widget.session.endedAt ?? now;
        return 'Ended • duration ${_formatDuration(end.difference(start))}';
    }
  }

  IconData _statusIcon() {
    switch (widget.session.status) {
      case EventStatus.scheduled:
        return Icons.schedule;
      case EventStatus.live:
        return Icons.graphic_eq;
      case EventStatus.ended:
        return Icons.stop_circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = MaterialLocalizations.of(context).formatShortDate(widget.session.scheduledStartAt);
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(widget.session.scheduledStartAt),
    );

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: Icon(_statusIcon()),
        title: Text(widget.session.eventName),
        subtitle: Text(
          '${_statusText(now)} • Scheduled $date at $time • ${eventTimeZoneLabel(widget.session.eventTimeZone)} • ${daylightSavingTimeLabel(widget.session.isDaylightSavingTimeEnabled)}',
        ),
        trailing: Chip(label: Text(widget.session.hostLanguage)),
      ),
    );
  }
}

