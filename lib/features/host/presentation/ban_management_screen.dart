import 'package:flutter/material.dart';
import 'package:lingua_floor/features/hand_raise/domain/models/hand_raise_request.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';

class BanManagementScreen extends StatelessWidget {
  const BanManagementScreen({super.key, required this.requests});

  final List<HandRaiseRequest> requests;

  void _showPlaceholder(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = requests
        .where((request) => request.status == HandRaiseRequestStatus.pending)
        .length;
    final approvedCount = requests
        .where((request) => request.status == HandRaiseRequestStatus.approved)
        .length;
    final bannedRequests = requests
        .where((request) => request.status == HandRaiseRequestStatus.banned)
        .toList(growable: false);
    final resolvedRequests = requests
        .where(
          (request) =>
              request.status == HandRaiseRequestStatus.answered ||
              request.status == HandRaiseRequestStatus.dismissed,
        )
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Ban')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Moderation snapshot',
            subtitle:
                'Review who is waiting, speaking, or recently resolved before taking action.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Queue: $pendingCount waiting')),
                Chip(label: Text('Approved: $approvedCount')),
                Chip(label: Text('Banned: ${bannedRequests.length}')),
                Chip(label: Text('Resolved: ${resolvedRequests.length}')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Ban controls',
            subtitle:
                'Keep dedicated ban and audit actions separate from the live floor board.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bannedRequests.isEmpty)
                  const Text('No banned participants yet in this demo room.'),
                if (bannedRequests.isNotEmpty) ...[
                  for (final request in bannedRequests)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_off_outlined),
                      title: Text(request.participantName),
                      subtitle: Text(request.status.label),
                    ),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('ban-participant-button'),
                  onPressed: () => _showPlaceholder(
                    context,
                    'Direct ban workflow coming soon.',
                  ),
                  icon: const Icon(Icons.gavel_outlined),
                  label: const Text('Ban participant'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('open-ban-audit-log-button'),
                  onPressed: () => _showPlaceholder(
                    context,
                    'Moderation audit log workflow coming soon.',
                  ),
                  icon: const Icon(Icons.article_outlined),
                  label: const Text('Open audit log'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Recent moderation outcomes',
            subtitle:
                'Latest answered and dismissed floor requests from the shared queue.',
            child: resolvedRequests.isEmpty
                ? const Text('No moderation outcomes yet.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final request in resolvedRequests) ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            request.status == HandRaiseRequestStatus.dismissed
                                ? Icons.person_off_outlined
                                : Icons.check_circle_outline,
                          ),
                          title: Text(request.participantName),
                          subtitle: Text(request.status.label),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
