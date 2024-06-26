import 'package:flutter/material.dart';


class RadiusTextFormField extends StatelessWidget {
  const RadiusTextFormField({
    super.key,
    required this.controller,
    this.inputStyle,
    this.labelStyle,
    this.labelText,
    this.borderRadius=50,
    this.fillColor,
  });

  final TextEditingController controller;
  final TextStyle? inputStyle;
  final TextStyle? labelStyle;
  final String? labelText;
  final double borderRadius;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: inputStyle ?? const TextStyle(fontSize: 16),
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: labelStyle ?? TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(150)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          // borderSide: BorderSide.none,
        ),
        fillColor: fillColor ?? Theme.of(context).colorScheme.background.withAlpha(150),
      ),
    );
  }
}