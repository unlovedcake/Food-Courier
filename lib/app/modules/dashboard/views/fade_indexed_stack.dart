import 'package:flutter/material.dart';

enum AnimationType {
  fade,
  fadeScale,
  fadeSlide,
  fadeDirectionalSlide,

  // NEW ANIMATIONS:
  scale,
  slide,
  slideVertical,
  fadeRotate,
}

class FadeIndexedStack extends StatefulWidget {
  const FadeIndexedStack({
    required this.children,
    required this.index,
    super.key,
    this.duration = const Duration(milliseconds: 300),
    this.disableAnimationForIndexes = const [],
    this.animationType = AnimationType.fade,
  });

  final List<Widget> children;
  final int index;
  final Duration duration;
  final List<int> disableAnimationForIndexes;
  final AnimationType animationType;

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  int _prevIndex = 0;
  late Offset _slideBeginOffset;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation =
        Tween<double>(begin: 0.98, end: 1).animate(_fadeAnimation);

    _slideBeginOffset = Offset.zero;
    _slideAnimation = Tween<Offset>(
      begin: _slideBeginOffset,
      end: Offset.zero,
    ).animate(_fadeAnimation);

    _controller.forward();
  }

  void _updateSlideDirection() {
    if (widget.animationType == AnimationType.fadeDirectionalSlide) {
      if (widget.index > _prevIndex) {
        // Slide from right to left
        _slideBeginOffset = const Offset(1, 0);
      } else if (widget.index < _prevIndex) {
        // Slide from left to right
        _slideBeginOffset = const Offset(-1, 0);
      } else {
        _slideBeginOffset = Offset.zero;
      }

      _slideAnimation = Tween<Offset>(
        begin: _slideBeginOffset,
        end: Offset.zero,
      ).animate(_fadeAnimation);
    }
  }

  @override
  void didUpdateWidget(covariant FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool shouldAnimate =
        !widget.disableAnimationForIndexes.contains(widget.index);

    if (widget.index != _prevIndex) {
      _updateSlideDirection();

      _prevIndex = widget.index;

      if (_controller.isAnimating) {
        _controller.stop();
      }

      if (shouldAnimate) {
        _controller.reset();
        _controller.forward();
      } else {
        _controller.value = 1;
      }
    }

    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTransition(Widget child) {
    switch (widget.animationType) {
      case AnimationType.fadeScale:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(scale: _scaleAnimation, child: child),
        );
      case AnimationType.fadeSlide:
      case AnimationType.fadeDirectionalSlide:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(position: _slideAnimation, child: child),
        );
      case AnimationType.fade:
        return FadeTransition(opacity: _fadeAnimation, child: child);
      case AnimationType.scale:
        return ScaleTransition(scale: _scaleAnimation, child: child);
      case AnimationType.slide:
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(_fadeAnimation),
          child: child,
        );
      case AnimationType.slideVertical:
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(_fadeAnimation),
          child: child,
        );
      case AnimationType.fadeRotate:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: RotationTransition(
            turns: Tween<double>(begin: 0.95, end: 1).animate(_fadeAnimation),
            child: child,
          ),
        );
    }
  }

  // Widget _buildTransition(Widget child) {
  //   switch (widget.animationType) {
  //     case AnimationType.fadeScale:
  //       return FadeTransition(
  //         opacity: _fadeAnimation,
  //         child: ScaleTransition(scale: _scaleAnimation, child: child),
  //       );
  //     case AnimationType.fadeSlide:
  //       return FadeTransition(
  //         opacity: _fadeAnimation,
  //         child: SlideTransition(position: _slideAnimation, child: child),
  //       );
  //     case AnimationType.fadeDirectionalSlide:
  //       return FadeTransition(
  //         opacity: _fadeAnimation,
  //         child: SlideTransition(position: _slideAnimation, child: child),
  //       );
  //     case AnimationType.fade:
  //       return FadeTransition(opacity: _fadeAnimation, child: child);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return _buildTransition(
      IndexedStack(
        index: widget.index,
        children: widget.children,
      ),
    );
  }
}

// class FadeIndexedStack extends StatefulWidget {
//   const FadeIndexedStack({
//     required this.children,
//     required this.index,
//     super.key,
//     this.duration = const Duration(milliseconds: 300),
//     this.disableAnimationForIndexes = const [],
//     this.animationType = AnimationType.fade,
//   });

//   final List<Widget> children;
//   final int index;
//   final Duration duration;

//   /// Disable animation for specific indexes (e.g., index 0)
//   final List<int> disableAnimationForIndexes;

//   /// Animation type: fade, fade+scale, or fade+slide
//   final AnimationType animationType;

//   @override
//   State<FadeIndexedStack> createState() => _FadeIndexedStackState();
// }

// enum AnimationType {
//   fade,
//   fadeScale,
//   fadeSlide,
// }

// class _FadeIndexedStackState extends State<FadeIndexedStack>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<Offset> _slideAnimation;

//   int _prevIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _initAnimation();
//   }

//   void _initAnimation() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: widget.duration,
//     );

//     _fadeAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     );

//     _scaleAnimation =
//         Tween<double>(begin: 0.98, end: 1).animate(_fadeAnimation);

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0.05, 0),
//       end: Offset.zero,
//     ).animate(_fadeAnimation);

//     _controller.forward();
//   }

//   @override
//   void didUpdateWidget(covariant FadeIndexedStack oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (widget.index != _prevIndex) {
//       // Check if animation should be disabled
//       final bool disableAnimation =
//           widget.disableAnimationForIndexes.contains(widget.index);

//       _prevIndex = widget.index;

//       if (!disableAnimation) {
//         _controller.reset();
//         _controller.forward();
//       } else {
//         _controller.value = 1; // Instantly set to full opacity
//       }
//     }

//     if (widget.duration != oldWidget.duration) {
//       _controller.duration = widget.duration;
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Widget _buildTransition(Widget child) {
//     switch (widget.animationType) {
//       case AnimationType.fadeScale:
//         return FadeTransition(
//           opacity: _fadeAnimation,
//           child: ScaleTransition(scale: _scaleAnimation, child: child),
//         );
//       case AnimationType.fadeSlide:
//         return FadeTransition(
//           opacity: _fadeAnimation,
//           child: SlideTransition(position: _slideAnimation, child: child),
//         );
//       case AnimationType.fade:
//       default:
//         return FadeTransition(opacity: _fadeAnimation, child: child);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _buildTransition(
//       IndexedStack(
//         index: widget.index,
//         children: widget.children,
//       ),
//     );
//   }
// }

// class FadeIndexedStack extends StatefulWidget {
//   const FadeIndexedStack({
//     required this.children,
//     required this.index,
//     super.key,
//     this.duration = const Duration(milliseconds: 300),
//   });

//   final List<Widget> children;
//   final int index;
//   final Duration duration;

//   @override
//   State<FadeIndexedStack> createState() => _FadeIndexedStackState();
// }

// class _FadeIndexedStackState extends State<FadeIndexedStack>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _animation;
//   int _prevIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _prevIndex = widget.index;

//     _controller = AnimationController(
//       vsync: this,
//       duration: widget.duration,
//     );

//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     );

//     _controller.forward();
//   }

//   @override
//   void didUpdateWidget(covariant FadeIndexedStack oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (widget.index != _prevIndex) {
//       _prevIndex = widget.index;

//       if (_controller.isAnimating) _controller.stop();
//       _controller.forward(from: 0);
//     }

//     // If the duration was changed dynamically, update it
//     if (widget.duration != oldWidget.duration) {
//       _controller.duration = widget.duration;
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _animation,
//       child: IndexedStack(
//         index: widget.index,
//         children: widget.children,
//       ),
//     );
//   }
// }

// class FadeIndexedStack extends StatefulWidget {
//   const FadeIndexedStack({
//     required this.children,
//     required this.index,
//     super.key,
//     this.duration = const Duration(milliseconds: 300),
//   });
//   final List<Widget> children;
//   final int index;
//   final Duration duration;

//   @override
//   State<FadeIndexedStack> createState() => _FadeIndexedStackState();
// }

// class _FadeIndexedStackState extends State<FadeIndexedStack>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   late int _oldIndex;

//   @override
//   void initState() {
//     super.initState();
//     _oldIndex = widget.index;

//     _controller = AnimationController(
//       vsync: this,
//       duration: widget.duration,
//     );

//     _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

//     _controller.forward();
//   }

//   @override
//   void didUpdateWidget(covariant FadeIndexedStack oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.index != _oldIndex) {
//       _controller
//         ..reset()
//         ..forward();
//       _oldIndex = widget.index;
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _animation,
//       child: IndexedStack(
//         index: widget.index,
//         children: widget.children,
//       ),
//     );
//   }
// }
