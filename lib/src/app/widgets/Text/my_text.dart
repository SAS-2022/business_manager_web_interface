import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:flutter/material.dart';

class MyText extends StatefulWidget {
  const MyText(
      {super.key,
      required this.text,
      this.tap,
      this.fontScale,
      this.align,
      this.fontColor,
      this.fontWeight,
      this.fontFamily,
      this.maxLines,
      this.textOverflow,
      this.softWrap,
      this.highlightText,
      this.underLine,
      this.strike,
      this.lineColor,
      this.optimalSizeEnabled});
  final String text;
  final Function? tap;
  final double? fontScale;
  final TextAlign? align;
  final Color? fontColor;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final int? maxLines;
  final TextOverflow? textOverflow;
  final bool? softWrap;
  final String? highlightText; // Text to highlight
  final bool? underLine;
  final bool? strike;
  final Color? lineColor;
  final bool? optimalSizeEnabled;

  @override
  State<MyText> createState() => _MyTextState();
}

class _MyTextState extends State<MyText> {
  ResponsiveUtils? responsive;
  double? normalFont = 12;
  double? minFont = 8, maxFont = 34;

  @override
  Widget build(BuildContext context) {
    responsive = ResponsiveUtils(context);
    if (widget.highlightText != null && widget.highlightText!.isNotEmpty) {
      return _buildHighlightedText();
    }
    return LayoutBuilder(builder: (context, constraints) {
      double fontSize = 0.0;
      if (widget.optimalSizeEnabled == null ||
          widget.optimalSizeEnabled == true) {
        fontSize = _calculateOptimalFontSize(
          constraints.maxWidth,
          widget.text,
        );
      } else {
        fontSize = widget.fontScale!;
      }

      return Text(
        widget.text,
        textAlign: widget.align ?? TextAlign.start,
        maxLines: widget.maxLines,
        overflow: widget.textOverflow ?? TextOverflow.visible,
        softWrap: widget.softWrap ?? true,
        style: TextStyle(
            overflow: TextOverflow.visible,
            fontSize: fontSize,
            fontFamily: widget.fontFamily,
            color: widget.fontColor ?? Theme.of(context).colorScheme.primary,
            fontWeight: widget.fontWeight ?? FontWeight.normal,
            decoration: _getTextDecoration(),
            decorationColor: widget.lineColor,
            decorationThickness: 4),
      );
    });
  }

  TextDecoration _getTextDecoration() {
    if (widget.underLine == true) {
      return TextDecoration.underline;
    } else if (widget.strike == true) {
      return TextDecoration.lineThrough;
    }
    return TextDecoration.none;
  }

  double _calculateOptimalFontSize(double maxWidth, String text) {
    double baseFontSize =
        widget.fontScale ?? responsive!.scaleFont(normalFont!);
    // Apply maximum font size constraint
    baseFontSize = baseFontSize.clamp(minFont!, maxFont!);
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: baseFontSize,
          fontWeight: widget.fontWeight ?? FontWeight.normal,
        ),
      ),
      maxLines: widget.maxLines ?? 1,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: maxWidth);

    if (textPainter.didExceedMaxLines || textPainter.width > maxWidth) {
      // Reduce font size until it fits
      double fontSize = baseFontSize;
      while (fontSize > minFont!) {
        fontSize -= 0.5;
        textPainter.text = TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: widget.fontWeight ?? FontWeight.normal,
          ),
        );
        textPainter.layout(maxWidth: maxWidth);

        if (!textPainter.didExceedMaxLines && textPainter.width <= maxWidth) {
          return fontSize;
        }
      }
      return minFont!;
    }

    return baseFontSize;
  }

  Widget _buildHighlightedText() {
    final pattern = widget.highlightText!.toLowerCase();
    final fullText = widget.text.toLowerCase();
    final matches = <TextSpan>[];
    int currentIndex = 0;

    while (currentIndex < fullText.length) {
      final matchIndex = fullText.indexOf(pattern, currentIndex);

      if (matchIndex == -1) {
        matches.add(_buildTextSpan(widget.text.substring(currentIndex), false));
        break;
      }

      if (matchIndex > currentIndex) {
        matches.add(_buildTextSpan(
            widget.text.substring(currentIndex, matchIndex), false));
      }

      matches.add(_buildTextSpan(
          widget.text.substring(matchIndex, matchIndex + pattern.length),
          true));
      currentIndex = matchIndex + pattern.length;
    }

    return RichText(
      textAlign: widget.align ?? TextAlign.start,
      maxLines: widget.maxLines,
      overflow: widget.textOverflow ?? TextOverflow.visible,
      softWrap: widget.softWrap ?? true,
      text: TextSpan(children: matches),
    );
  }

  TextSpan _buildTextSpan(String text, bool isHighlighted) {
    return TextSpan(
      text: text,
      style: TextStyle(
        fontSize: widget.fontScale ?? responsive!.scaleFont(14),
        color: widget.fontColor ?? Theme.of(context).colorScheme.primary,
        fontWeight: isHighlighted
            ? FontWeight.bold
            : widget.fontWeight ?? FontWeight.normal,
        backgroundColor: isHighlighted
            ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.7)
            : Colors.transparent,
      ),
    );
  }
}
