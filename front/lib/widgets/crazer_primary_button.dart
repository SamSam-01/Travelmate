import 'package:flutter/material.dart';
import 'package:front/styles/colors.dart';

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

ButtonStyle _crazerFilledButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: CrazerColors.lime,
    foregroundColor: Colors.black,
    disabledBackgroundColor: CrazerColors.lime.withValues(alpha: 0.4),
    disabledForegroundColor: Colors.black.withValues(alpha: 0.65),
  );
}
