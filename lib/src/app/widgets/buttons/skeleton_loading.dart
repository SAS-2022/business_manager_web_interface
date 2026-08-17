// import 'package:flutter/material.dart';
// import '../../theme/responsive_utils.dart';

// class GradientSkeleton extends StatefulWidget {
//   final bool hasAppBar;
//   final bool hasBottomNavigation;
//   final int itemCount;

//   const GradientSkeleton({
//     super.key,
//     this.hasAppBar = true,
//     this.hasBottomNavigation = false,
//     this.itemCount = 5,
//   });

//   @override
//   State<GradientSkeleton> createState() => _GradientSkeletonState();
// }

// class _GradientSkeletonState extends State<GradientSkeleton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _shimmerAnimation;
//   ResponsiveUtils? responsive;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     )..repeat();

//     _shimmerAnimation = Tween<double>(
//       begin: -1.0,
//       end: 2.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     ));
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     responsive = ResponsiveUtils(context);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Widget _buildShimmerEffect(Widget child) {
//     return AnimatedBuilder(
//       animation: _shimmerAnimation,
//       builder: (context, child) {
//         return ShaderMask(
//           blendMode: BlendMode.srcATop,
//           shaderCallback: (bounds) {
//             return LinearGradient(
//               colors: Theme.of(context).brightness == Brightness.light
//                   ? [
//                       Colors.grey.shade50,
//                       Colors.grey.shade100,
//                       Colors.grey.shade300,
//                     ]
//                   : [
//                       Colors.grey.shade500,
//                       Colors.grey.shade600,
//                       Colors.grey.shade700,
//                     ],
//               stops: const [0.1, 0.3, 0.4],
//               begin: Alignment(_shimmerAnimation.value, 0.0),
//               end: Alignment(_shimmerAnimation.value + 1.0, 0.0),
//             ).createShader(bounds);
//           },
//           child: child,
//         );
//       },
//       child: child,
//     );
//   }

//   Widget _buildSkeletonItem() {
//     return Container(
//       margin: responsive!.responsivePaddingS,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Avatar placeholder
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? Colors.grey.shade700
//                   : Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(25),
//             ),
//           ),
//           SizedBox(width: responsive!.scaleWidth(15)),
//           // Text content placeholders
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: double.infinity,
//                   height: 16,
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).brightness == Brightness.dark
//                         ? Colors.grey.shade700
//                         : Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//                 SizedBox(height: responsive!.scaleWidth(8)),
//                 Container(
//                   width: double.infinity,
//                   height: 14,
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).brightness == Brightness.dark
//                         ? Colors.grey.shade700
//                         : Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//                 SizedBox(height: responsive!.scaleWidth(8)),
//                 Container(
//                   width: double.infinity,
//                   height: 12,
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).brightness == Brightness.dark
//                         ? Colors.grey.shade700
//                         : Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppBarSkeleton() {
//     return Container(
//       height: kToolbarHeight,
//       padding: responsive!.responsivePaddingHor,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.1),
//             blurRadius: 2,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Back button placeholder
//           Container(
//             width: responsive!.screenWidth * 0.05,
//             height: 24,
//             decoration: BoxDecoration(
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? Colors.grey.shade700
//                   : Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ),
//           SizedBox(width: responsive!.scaleWidth(15)),
//           // Title placeholder
//           Container(
//             width: responsive!.screenWidth * 0.08,
//             height: 20,
//             decoration: BoxDecoration(
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? Colors.grey.shade700
//                   : Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ),
//           const Spacer(),
//           // Action button placeholder
//           Container(
//             width: responsive!.screenWidth * 0.05,
//             height: 24,
//             decoration: BoxDecoration(
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? Colors.grey.shade700
//                   : Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomNavigationSkeleton() {
//     return Container(
//       height: kBottomNavigationBarHeight,
//       decoration: BoxDecoration(
//         color: Theme.of(context).brightness == Brightness.dark
//             ? Colors.grey.shade600
//             : Colors.grey.shade200,
//         border: const Border(top: BorderSide(color: Colors.grey, width: 0.5)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: List.generate(
//             4,
//             (index) => Container(
//                   width: 30,
//                   height: 30,
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).brightness == Brightness.dark
//                         ? Colors.grey.shade700
//                         : Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 )),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Theme.of(context).brightness == Brightness.dark
//           ? Colors.grey.shade600
//           : Colors.grey.shade100,
//       child: SizedBox(
//         height: responsive!.screenHeight * 0.92,
//         width: responsive!.screenWidth * 0.95,
//         child: Column(
//           children: [
//             // App Bar
//             if (widget.hasAppBar) _buildShimmerEffect(_buildAppBarSkeleton()),

//             // Content Area
//             Expanded(
//               child: _buildShimmerEffect(
//                 ListView.builder(
//                   padding: EdgeInsets.symmetric(
//                       vertical: responsive!.scaleWidth(15)),
//                   itemCount: widget.itemCount,
//                   itemBuilder: (context, index) {
//                     return _buildSkeletonItem();
//                   },
//                 ),
//               ),
//             ),

//             // Bottom Navigation
//             if (widget.hasBottomNavigation)
//               _buildShimmerEffect(_buildBottomNavigationSkeleton()),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../theme/responsive_utils.dart';

class GradientSkeleton extends StatefulWidget {
  final bool hasAppBar;
  final bool hasBottomNavigation;
  final int itemCount;

  const GradientSkeleton({
    super.key,
    this.hasAppBar = true,
    this.hasBottomNavigation = false,
    this.itemCount = 5,
  });

  @override
  State<GradientSkeleton> createState() => _GradientSkeletonState();
}

class _GradientSkeletonState extends State<GradientSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;
  ResponsiveUtils? responsive;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    responsive = ResponsiveUtils(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildShimmerEffect(Widget child) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: Theme.of(context).brightness == Brightness.light
                  ? [
                      Colors.grey.shade50,
                      Colors.grey.shade100,
                      Colors.grey.shade300,
                    ]
                  : [
                      Colors.grey.shade500,
                      Colors.grey.shade600,
                      Colors.grey.shade700,
                    ],
              stops: const [0.1, 0.3, 0.4],
              begin: Alignment(_shimmerAnimation.value, 0.0),
              end: Alignment(_shimmerAnimation.value + 1.0, 0.0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: responsive!.responsivePaddingS,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          SizedBox(width: responsive!.scaleWidth(15)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: responsive!.scaleWidth(8)),
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: responsive!.scaleWidth(8)),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarSkeleton() {
    final skeletonColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    // LayoutBuilder reads the actual available width AFTER the parent
    // has applied its own padding — so 24+24+gaps never exceeds it.
    return Container(
      height: kToolbarHeight,
      color: Colors.grey.shade200,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const btnSize = 24.0;
          const gap = 12.0;
          // Title gets whatever is left after the two buttons and gaps
          final titleWidth = constraints.maxWidth - (btnSize * 2) - (gap * 2);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button
              Container(
                width: btnSize,
                height: btnSize,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: gap),
              // Title — constrained to computed width, never overflows
              Container(
                width: titleWidth.clamp(0.0, double.infinity),
                height: 20,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: gap),
              // Action button
              Container(
                width: btnSize,
                height: btnSize,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationSkeleton() {
    return Container(
      height: kBottomNavigationBarHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade600
            : Colors.grey.shade200,
        border: const Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          4,
          (index) => Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade600
          : Colors.grey.shade100,
      child: SizedBox(
        height: responsive!.screenHeight * 0.91,
        width: responsive!.screenWidth * 0.95,
        child: Column(
          children: [
            if (widget.hasAppBar) _buildShimmerEffect(_buildAppBarSkeleton()),
            Expanded(
              child: _buildShimmerEffect(
                ListView.builder(
                  padding: EdgeInsets.symmetric(
                      vertical: responsive!.scaleWidth(15)),
                  itemCount: widget.itemCount,
                  itemBuilder: (context, index) => _buildSkeletonItem(),
                ),
              ),
            ),
            if (widget.hasBottomNavigation)
              _buildShimmerEffect(_buildBottomNavigationSkeleton()),
          ],
        ),
      ),
    );
  }
}
