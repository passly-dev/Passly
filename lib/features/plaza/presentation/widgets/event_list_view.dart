import 'package:flutter/material.dart';
import 'package:syshack2026/features/plaza/presentation/widgets/event_list_item.dart';

class EventListView extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final void Function(Map<String, dynamic> event)? onEventTap;

  const EventListView({super.key, required this.events, this.onEventTap});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final event = events[index];
        return EventListItem(
          eventName: event['name']?.toString() ?? '',
          date: event['date']?.toString() ?? '',
          location: event['location']?.toString() ?? '',
          onTap: onEventTap != null ? () => onEventTap!(event) : null,
        );
      },
    );
  }
}
