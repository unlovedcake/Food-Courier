import 'package:flutter/material.dart';

class FloatingEmoji extends StatefulWidget {
  const FloatingEmoji({required this.emoji, super.key});
  final String emoji;

  @override
  State<FloatingEmoji> createState() => _FloatingEmojiState();
}

class _FloatingEmojiState extends State<FloatingEmoji>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    _controller = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _offset = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -2))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: Text(widget.emoji, style: const TextStyle(fontSize: 36)),
    );
  }
}
