import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FlyingImage extends StatefulWidget {
  const FlyingImage({
    required this.startOffset,
    required this.endOffset,
    required this.image,
    required this.onComplete,
    super.key,
  });
  final Offset startOffset;
  final Offset endOffset;
  final ImageProvider image;
  final VoidCallback onComplete;

  @override
  State<FlyingImage> createState() => _FlyingImageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Offset>('startOffset', startOffset));
    properties.add(DiagnosticsProperty<Offset>('endOffset', endOffset));
    properties.add(DiagnosticsProperty<ImageProvider<Object>>('image', image));
    properties
        .add(ObjectFlagProperty<VoidCallback>.has('onComplete', onComplete));
  }
}

class _FlyingImageState extends State<FlyingImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: widget.startOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onComplete();
      });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) => Positioned(
          top: _animation.value.dy,
          left: _animation.value.dx,
          child: Image(image: widget.image, width: 80, height: 80),
        ),
      ),
    );
  }
}
