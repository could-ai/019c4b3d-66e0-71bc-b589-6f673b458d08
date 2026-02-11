class Message {
  final String id;
  final String text;
  final bool isUser;
  final String? imageUrl; // Local path or URL
  final DateTime timestamp;

  Message({
    required this.id,
    required this.text,
    required this.isUser,
    this.imageUrl,
    required this.timestamp,
  });
}
