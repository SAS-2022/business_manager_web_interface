import 'package:flutter/material.dart';
import '../../theme/responsive_utils.dart';

class RegulartButton extends StatefulWidget {
  const RegulartButton(
      {super.key,
      this.text,
      this.width,
      this.backgroundColor,
      this.textColor,
      this.borderColor,
      this.fontSize,
      this.disabled,
      this.borderRadius,
      this.height});
  final String? text;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? fontSize;
  final bool? disabled;
  final double? borderRadius;
  final double? height;

  @override
  State<RegulartButton> createState() => _RegulartButtonState();
}

class _RegulartButtonState extends State<RegulartButton>
    with SingleTickerProviderStateMixin {
  ResponsiveUtils? responsive;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    responsive = ResponsiveUtils(context);

    return Container(
      height: widget.height ?? responsive!.screenHeight * 0.05,
      width: widget.width ?? responsive!.screenWidth * 0.75,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).colorScheme.primary,
        border: Border.all(
            color: widget.borderColor ?? Theme.of(context).colorScheme.primary),
        borderRadius: widget.borderRadius == null
            ? BorderRadius.circular(20)
            : BorderRadius.circular(widget.borderRadius!),
      ),
      child: Center(
        child: Text(
          widget.text.toString(),
          style: TextStyle(
              color: widget.textColor ?? Theme.of(context).colorScheme.primary,
              fontSize: widget.fontSize ?? 15),
        ),
      ),
    );
  }
}
