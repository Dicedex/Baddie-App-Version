class Profile {
  final String id;
  final String name;
  final int age;
  final String? imageUrl;
  final String bio;
  final List<String> interests;
  final String personality;
  final Map<String, dynamic> preferences;

  Profile({
    required this.id,
    required this.name,
    required this.age,
    this.imageUrl,
    required this.bio,
    required this.interests,
    this.personality = 'Casual',
    Map<String, dynamic>? preferences,
  }) : preferences = preferences ??
            {
              'maxDistance': 50,
              'ageRangeStart': 18,
              'ageRangeEnd': 40,
              'verifiedOnly': false,
            };

  // Add copyWith method **inside the class**
  Profile copyWith({
    String? id,
    String? name,
    int? age,
    String? imageUrl,
    String? bio,
    List<String>? interests,
    String? personality,
    Map<String, dynamic>? preferences,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      personality: personality ?? this.personality,
      preferences: preferences ?? this.preferences,
    );
  }
}
