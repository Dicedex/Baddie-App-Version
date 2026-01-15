class Call {
  final String callerId;
  final String callerName;
  final bool isVideo;
  final String callId;

  Call({
    required this.callerId,
    required this.callerName,
    required this.callId,
    this.isVideo = false,
  });

  // Convert Firestore data to Call object
  factory Call.fromMap(Map<String, dynamic> data) {
    return Call(
      callerId: data['callerId'] ?? '',
      callerName: data['callerName'] ?? 'Unknown',
      callId: data['callId'] ?? '',
      isVideo: data['isVideo'] ?? false,
    );
  }

  // Convert Call object to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callId': callId,
      'isVideo': isVideo,
    };
  }
}
