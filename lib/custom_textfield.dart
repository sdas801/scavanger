import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final int maxLines;
  final bool readOnly;
  final Color? fillColor;
  final double? borderRadius;
  final GestureTapCallback? onTap;
  final List<TextInputFormatter>? inputFormatters; // Added parameter
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.maxLines,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.readOnly = false,
    this.fillColor = Colors.white,
    this.borderRadius = 30,
    this.onTap,
    this.inputFormatters, // Initialize in the
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Color(0xFF153792), // Custom label color
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: inputFormatters, // Apply inputFormatters
          enabled: enabled,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.withOpacity(0.5), // Custom hint color
            ),
            filled: true,
            fillColor: fillColor, // Background color of the TextField
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius!),
              borderSide: BorderSide.none, // No border
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}
