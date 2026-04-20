import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final int maxLines;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    this.hintText,
    this.maxLines = 1,
    this.controller,
    this.keyboardType,
    this.suffixIcon,
    this.inputFormatters,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        textInputAction: textInputAction,
        textAlign: TextAlign.left,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.45)),
          filled: true,
          fillColor: AppTheme.pearlWhite,
          suffixIcon: suffixIcon,
          errorStyle: const TextStyle(color: AppTheme.alertRed, fontSize: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.deepNavy, width: 1.9),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.oceanBlue, width: 1.9),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.alertRed, width: 1.9),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.alertRed, width: 1.9),
          ),
        ),
      ),
    );
  }
}
