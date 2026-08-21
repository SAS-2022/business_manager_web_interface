import 'package:flutter/material.dart';
import '../../theme/responsive_utils.dart';

class MyButton extends StatefulWidget {
  const MyButton(
      {super.key,
      required this.text,
      this.width,
      this.backgroundColor,
      this.textColor,
      this.borderColor,
      this.fontSize,
      this.disabled});
  final String? text;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? fontSize;
  final bool? disabled;
  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton>
    with SingleTickerProviderStateMixin {
  ResponsiveUtils? responsive;
  late AnimationController _controller;
  late Animation<Alignment> _beginAlignment;
  late Animation<Alignment> _endAlignment;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward(); //Apply once only

    _beginAlignment = Tween<Alignment>(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(_controller);

    _endAlignment = Tween<Alignment>(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
    ).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose(); // Play again
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    responsive = ResponsiveUtils(context);
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            height: responsive!.screenHeight * 0.05,
            width: widget.width ?? responsive!.screenWidth * 0.75,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color.fromARGB(255, 181, 112, 90),
                  Color.fromARGB(255, 66, 113, 170),
                ],
                begin: _beginAlignment.value,
                end: _endAlignment.value,
                stops: const [0.0, 0.4], // Optional: Control color distribution
              ),
              boxShadow: [
                BoxShadow(
                    offset: const Offset(2, 2),
                    color: Theme.of(context).colorScheme.primary,
                    spreadRadius: 1,
                    blurRadius: 1)
              ],
              border: Border.all(
                  color: widget.borderColor ??
                      Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(8),
              color: widget.disabled != null && widget.disabled!
                  ? Theme.of(context).colorScheme.surface
                  : widget.backgroundColor ??
                      Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Text(
                widget.text.toString(),
                style: TextStyle(
                    color: widget.textColor ??
                        Theme.of(context).scaffoldBackgroundColor,
                    fontSize: widget.fontSize ?? 15),
              ),
            ),
          );
        });
  }
}
