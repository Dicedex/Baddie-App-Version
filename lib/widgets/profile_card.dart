import 'package:flutter/material.dart';
import '../models/profile.dart';

class ProfileCard extends StatelessWidget {
  final Profile profile;
  final bool expanded;

  const ProfileCard({
    super.key,
    required this.profile,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(),
          _buildOverlay(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = profile.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.person, size: 64, color: Colors.white70),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.person, size: 64, color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        height: expanded ? 180 : 80,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.45),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${profile.name}, ${profile.age}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.bio,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (expanded) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: profile.interests
                            .map(
                              (i) => Chip(
                                label: Text(i),
                                backgroundColor: Colors.white24,
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Personality: ${profile.personality}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Max distance: ${profile.preferences['maxDistance']} km',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Age range: ${profile.preferences['ageRangeStart']} - ${profile.preferences['ageRangeEnd']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Verified only: ${profile.preferences['verifiedOnly']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
