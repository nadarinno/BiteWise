import 'package:flutter/material.dart';

class MiniCaloriesInfo extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;

  const MiniCaloriesInfo({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 21,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "$value kcal",
              style: theme.textTheme.titleSmall,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}