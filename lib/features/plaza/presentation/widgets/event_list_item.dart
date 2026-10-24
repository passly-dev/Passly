import 'package:flutter/material.dart';
import 'package:syshack2026/common/widgets/press_feedback.dart';
import 'package:syshack2026/core/constants/app_colors.dart';

class EventListItem extends StatelessWidget {
  final String eventName;
  final String date;
  final String location;
  final VoidCallback? onTap;

  const EventListItem({
    super.key,
    required this.eventName,
    required this.date,
    required this.location,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PressFeedback(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: _buildDecoration(),
          child: Row(
            children: [
              _buildLeadingIcon(),
              const SizedBox(width: 12),
              Expanded(child: _buildEventInfo()),
              const Icon(Icons.chevron_right, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: AppColors.backgroundWhite,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0x4D3AAA3A), width: 1),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0x263AAA3A),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.event_available,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }

  Widget _buildEventInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eventName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              date,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.location_on,
              color: AppColors.textSecondary,
              size: 12,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                location,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
