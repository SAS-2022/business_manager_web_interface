import 'package:flutter/material.dart';

/// A minimal, borderless text field designed specifically for use
/// inside a grouped container (like the login screen).
/// It has no outer border, no background, and no fixed height —
/// it sizes itself naturally to fit flush inside a parent container.
class FlushTextField extends StatefulWidget {
  const FlushTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.fontSize = 14.0,
    this.maxLength,
    this.lines,
  });

  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final double fontSize;
  final int? maxLength;
  final int? lines;

  @override
  State<FlushTextField> createState() => _FlushTextFieldState();
}

class _FlushTextFieldState extends State<FlushTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      maxLength: widget.maxLength,
      maxLines: widget.lines ?? 1,
      buildCounter: widget.maxLength != null
          ? (context,
                  {required currentLength, required isFocused, maxLength}) =>
              null
          : null,
      style: TextStyle(
        fontSize: widget.fontSize,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: widget.fontSize,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        // No border at all — parent container provides the visual boundary
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        // Padding: vertical breathing room, no left pad (icon handles that)
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        isDense: true,
        // Password visibility toggle
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            : null,
      ),
    );
  }
}
