String generateChatId(String uid1, String uid2) {
  final List<String> sorted = [uid1, uid2]..sort();
  return '${sorted[0]}_${sorted[1]}';
}

String otherUserId = '';
