import 'package:flutter/material.dart';
import 'package:front/styles/colors.dart';

class CrazerStepScaffold extends StatelessWidget {
  const CrazerStepScaffold({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: children,
        ),
      ),
    );
  }
}

class CrazerPrimaryButton extends StatelessWidget {
  const CrazerPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: FilledButton(
        style: _crazerFilledButtonStyle(),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class CrazerOutlineButton extends StatelessWidget {
  const CrazerOutlineButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: CrazerColors.lime,
        side: BorderSide(color: CrazerColors.lime.withValues(alpha: 0.55)),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

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

void showCrazerSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).snackBarTheme.backgroundColor,
    ),
  );
}

ButtonStyle _crazerFilledButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: CrazerColors.lime,
    foregroundColor: Colors.black,
    disabledBackgroundColor: CrazerColors.lime.withValues(alpha: 0.4),
    disabledForegroundColor: Colors.black.withValues(alpha: 0.65),
  );
}
