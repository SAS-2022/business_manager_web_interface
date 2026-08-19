import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FloatingButtonAdd extends StatefulWidget {
  const FloatingButtonAdd({super.key, this.navigateTo, this.uid});
  final String? navigateTo;
  final String? uid;

  @override
  State<FloatingButtonAdd> createState() => _FloatingButtonAddState();
}

class _FloatingButtonAddState extends State<FloatingButtonAdd> {
  ResponsiveUtils? responsive;
  bool _isVisible = false;

  @override
  void didChangeDependencies() {
    responsive = ResponsiveUtils(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    // Delay the appearance slightly for a smooth entrance
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isVisible ? 1.0 : 0.0,
      child: _floatingButtonWidget(),
    );
  }

  Widget _floatingButtonWidget() {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: responsive!.scaleHeight(50)),
      child: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).pushNamed(widget.navigateTo!,
              pathParameters: {'uid': widget.uid!});
        },
        backgroundColor: Theme.of(context).colorScheme.secondaryFixed,
        child: Icon(
          Icons.add,
          size: responsive!.scaleWidth(35),
        ),
      ),
    );
  }
}
