class Call {
  final String callId;
  final String callerId;
  final String receiverId;
  final bool video;
  final String status; // ringing, accepted, ended

  Call({
    required this.callId,
    required this.callerId,
    required this.receiverId,
    required this.video,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'callerId': callerId,
        'receiverId': receiverId,
        'video': video,
        'status': status,
        'createdAt': DateTime.now(),
      };
}
