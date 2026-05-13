import 'package:flutter/material.dart';
import 'package:front/styles/colors.dart';

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
