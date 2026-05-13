import 'package:flutter/material.dart';
import 'package:front/styles/colors.dart';

class CrazerStepActionCard extends StatelessWidget {
  const CrazerStepActionCard({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.summary,
    required this.completed,
    required this.buttonLabel,
    required this.onPressed,
  });

  final int stepNumber;
  final String title;
  final String summary;
  final bool completed;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: CrazerColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: CrazerColors.border.withValues(alpha: 0.9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Étape $stepNumber — $title',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  completed ? Icons.check_circle : Icons.pending_outlined,
                  color: completed
                      ? CrazerColors.lime
                      : scheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(summary, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: CrazerColors.lime,
                  side: BorderSide(
                    color: CrazerColors.lime.withValues(alpha: 0.55),
                  ),
                ),
                onPressed: onPressed,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
