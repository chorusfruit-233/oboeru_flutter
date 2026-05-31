import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool? isCorrect;
  final VoidCallback? onTap;
  final double fontSize;

  const OptionButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
    this.fontSize = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color? textColor;
    IconData? icon;

    if (isSelected && isCorrect == true) {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
      icon = Icons.check_circle;
    } else if (isSelected && isCorrect == false) {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
      icon = Icons.cancel;
    } else if (!isSelected && isCorrect == true) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: bgColor ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          elevation: isSelected ? 0 : 1,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: textColor,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (icon != null)
                    Icon(icon, color: textColor, size: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
