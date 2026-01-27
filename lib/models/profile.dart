class Profile {
  final String id;
  final String name;
  final int age;
  final String? imageUrl;
  final List<String> imageUrls;
  final String bio;
  final List<String> interests;
  final String personality;
  final Map<String, dynamic> preferences;
  final bool profileCompleted;

  Profile({
    required this.id,
    required this.name,
    required this.age,
    this.imageUrl,
    List<String>? imageUrls,
    required this.bio,
    required this.interests,
    this.personality = 'Casual',
    this.profileCompleted = true,
    Map<String, dynamic>? preferences,
  })  : imageUrls = imageUrls ?? (imageUrl != null ? [imageUrl] : []),
        preferences = preferences ??
            {
              'maxDistance': 50,
              'ageRangeStart': 18,
              'ageRangeEnd': 40,
              'verifiedOnly': false,
            };

  // Firestore serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'bio': bio,
      'interests': interests,
      'personality': personality,
      'preferences': preferences,
      'profileCompleted': profileCompleted,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Firestore deserialization
  factory Profile.fromMap(Map<String, dynamic> map) {
    final imageUrls = List<String>.from(map['imageUrls'] as List? ?? []);
    final imageUrl = map['imageUrl'] as String?;
    
    return Profile(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown',
      age: map['age'] as int? ?? 18,
      imageUrl: imageUrl,
      imageUrls: imageUrls.isEmpty && imageUrl != null ? [imageUrl] : imageUrls,
      bio: map['bio'] as String? ?? '',
      interests: List<String>.from(map['interests'] as List? ?? []),
      personality: map['personality'] as String? ?? 'Casual',
      profileCompleted: map['profileCompleted'] as bool? ?? false,
      preferences: Map<String, dynamic>.from(map['preferences'] as Map? ?? {
        'maxDistance': 50,
        'ageRangeStart': 18,
        'ageRangeEnd': 40,
        'verifiedOnly': false,
      }),
    );
  }

  // Add copyWith method **inside the class**
  Profile copyWith({
    String? id,
    String? name,
    int? age,
    String? imageUrl,
    List<String>? imageUrls,
    String? bio,
    List<String>? interests,
    String? personality,
    bool? profileCompleted,
    Map<String, dynamic>? preferences,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      personality: personality ?? this.personality,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      preferences: preferences ?? this.preferences,
    );
  }
}
