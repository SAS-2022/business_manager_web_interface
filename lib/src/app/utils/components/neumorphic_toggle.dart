import 'package:flutter/material.dart';

class NeumorphicToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? color;
  final Color? bgColor;

  const NeumorphicToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.color,
    this.bgColor,
  });

  @override
  State<NeumorphicToggle> createState() => _NeumorphicToggleState();
}

class _NeumorphicToggleState extends State<NeumorphicToggle> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: Container(
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: widget.value
              ? widget.bgColor ??
                  Theme.of(context).colorScheme.onPrimaryFixedVariant
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primaryFixed,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
            BoxShadow(
              color: Theme.of(context).colorScheme.secondary,
              blurRadius: 4,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment:
              widget.value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.value
                    ? widget.color ??
                        Theme.of(context).colorScheme.onPrimaryFixed
                    : Theme.of(context).colorScheme.primaryFixed,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
