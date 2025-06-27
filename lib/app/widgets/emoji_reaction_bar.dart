import 'package:flutter/material.dart';

class EmojiReactionBar extends StatelessWidget {
  const EmojiReactionBar({required this.onReactionSelected, super.key});
  final Function(String) onReactionSelected;

  @override
  Widget build(BuildContext context) {
    final emojis = ['❤️', '👍', '😂', '😮', '😢', '👏'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: emojis.map((emoji) {
          return GestureDetector(
            onTap: () {
              onReactionSelected(emoji);
              Navigator.pop(context);
            },
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          );
        }).toList(),
      ),
    );
  }
}
