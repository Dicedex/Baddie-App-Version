import 'package:flutter/material.dart';
import '../widgets/shimmer_loader.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  List<_MatchCard> _likedYou = [];
  List<_MatchCard> _matches = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _likedYou = [
        _MatchCard(
          id: '1',
          name: 'Ava',
          age: 25,
          imageUrl: 'https://picsum.photos/400/700?1',
          bio: 'Coffee lover ☕',
          distance: 2.3,
          likedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        _MatchCard(
          id: '2',
          name: 'Mia',
          age: 27,
          imageUrl: 'https://picsum.photos/400/700?2',
          bio: 'Photographer 📸',
          distance: 5.1,
          likedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        _MatchCard(
          id: '3',
          name: 'Zoe',
          age: 24,
          imageUrl: 'https://picsum.photos/400/700?3',
          bio: 'Fitness enthusiast 💪',
          distance: 1.8,
          likedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      _matches = [
        _MatchCard(
          id: '4',
          name: 'Emma',
          age: 26,
          imageUrl: 'https://picsum.photos/400/700?4',
          bio: 'Artist & dreamer 🎨',
          distance: 3.2,
          likedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        _MatchCard(
          id: '5',
          name: 'Sophie',
          age: 23,
          imageUrl: 'https://picsum.photos/400/700?5',
          bio: 'Adventure seeker 🌍',
          distance: 4.5,
          likedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        _MatchCard(
          id: '6',
          name: 'Luna',
          age: 25,
          imageUrl: 'https://picsum.photos/400/700?6',
          bio: 'Music lover 🎵',
          distance: 2.9,
          likedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];

      _loading = false;
    });
  }

  String _formatDistance(double distance) {
    if (distance < 1) {
      return '<1 km';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Matches',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFF06595),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFFF06595),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Likes'),
                  const SizedBox(width: 6),
                  if (_likedYou.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF06595),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _likedYou.length > 9
                            ? '9+'
                            : _likedYou.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Matches'),
                  const SizedBox(width: 6),
                  if (_matches.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF06595),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _matches.length > 9
                            ? '9+'
                            : _matches.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? _buildShimmerLoading()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLikedYouTab(),
                _buildMatchesTab(),
              ],
            ),
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoader(
                  height: 120,
                  width: double.infinity,
                  borderRadius: 12,
                  margin: const EdgeInsets.only(bottom: 12),
                ),
                ShimmerLoader(
                  height: 14,
                  width: 100,
                  borderRadius: 6,
                  margin: const EdgeInsets.only(bottom: 8),
                ),
                ShimmerLoader(
                  height: 12,
                  width: double.infinity,
                  borderRadius: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                ),
                ShimmerLoader(
                  height: 12,
                  width: 80,
                  borderRadius: 4,
                  margin: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLikedYouTab() {
    if (_likedYou.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'No one has liked you yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep swiping to get likes!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _likedYou.length,
      itemBuilder: (context, index) {
        return _buildMatchCard(_likedYou[index], isLiked: true);
      },
    );
  }

  Widget _buildMatchesTab() {
    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'No matches yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start swiping to find matches!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        return _buildMatchCard(_matches[index]);
      },
    );
  }

  Widget _buildMatchCard(_MatchCard match, {bool isLiked = false}) {
    return GestureDetector(
      onTap: () {
        // Navigate to profile or chat
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                match.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.person,
                    color: Colors.white70,
                    size: 40,
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Bottom info
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${match.name}, ${match.age}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      match.bio,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDistance(match.distance),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTime(match.likedAt),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Like badge for "Liked You" tab
            if (isLiked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF06595),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF06595).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MatchCard {
  final String id;
  final String name;
  final int age;
  final String imageUrl;
  final String bio;
  final double distance;
  final DateTime likedAt;

  _MatchCard({
    required this.id,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.bio,
    required this.distance,
    required this.likedAt,
  });
}
