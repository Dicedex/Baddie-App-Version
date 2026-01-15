class ChatMessage {
  final String senderId;
  final String? text;
  final String? voiceUrl;
  final bool read;
  final DateTime time;

  ChatMessage({
    required this.senderId,
    this.text,
    this.voiceUrl,
    this.read = false,
    required this.time,
  });

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'text': text,
        'voiceUrl': voiceUrl,
        'read': read,
        'time': time,
      };
}
