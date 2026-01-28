import 'dart:math';
import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../widgets/profile_card.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with SingleTickerProviderStateMixin {
  final List<Profile> _profiles = [];
  final List<Profile> _history = [];
  final List<String> _likedProfiles = [];
  final List<String> _passedProfiles = [];

  late AnimationController _controller;
  late Animation<Offset> _positionAnim;
  late Animation<double> _rotationAnim;

  Offset _dragOffset = Offset.zero;
  double _rotation = 0;
  bool _loading = true;

  static const swipeThreshold = 120.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _loadProfiles();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    try {
      // Mock data for now - in production, load from Firestore
      final mockProfiles = [
        Profile(
          id: '1',
          name: 'Ava',
          age: 25,
          imageUrl: 'https://picsum.photos/400/700?1',
          imageUrls: [
            'https://picsum.photos/400/700?1',
            'https://picsum.photos/400/700?10',
            'https://picsum.photos/400/700?11',
          ],
          bio: 'Loves coffee and travel',
          interests: ['Music', 'Travel'],
        ),
        Profile(
          id: '2',
          name: 'Mia',
          age: 27,
          imageUrl: 'https://picsum.photos/400/700?2',
          imageUrls: [
            'https://picsum.photos/400/700?2',
            'https://picsum.photos/400/700?20',
            'https://picsum.photos/400/700?21',
          ],
          bio: 'Foodie and photographer',
          interests: ['Food', 'Movies'],
        ),
        Profile(
          id: '3',
          name: 'Zoe',
          age: 24,
          imageUrl: 'https://picsum.photos/400/700?3',
          imageUrls: [
            'https://picsum.photos/400/700?3',
            'https://picsum.photos/400/700?30',
            'https://picsum.photos/400/700?31',
          ],
          bio: 'Runner and software dev',
          interests: ['Fitness', 'Outdoors'],
        ),
        Profile(
          id: '4',
          name: 'Emma',
          age: 26,
          imageUrl: 'https://picsum.photos/400/700?4',
          imageUrls: [
            'https://picsum.photos/400/700?4',
            'https://picsum.photos/400/700?40',
            'https://picsum.photos/400/700?41',
          ],
          bio: 'Artist and coffee enthusiast',
          interests: ['Art', 'Music'],
        ),
        Profile(
          id: '5',
          name: 'Sophie',
          age: 23,
          imageUrl: 'https://picsum.photos/400/700?5',
          imageUrls: [
            'https://picsum.photos/400/700?5',
            'https://picsum.photos/400/700?50',
            'https://picsum.photos/400/700?51',
          ],
          bio: 'Adventure seeker',
          interests: ['Travel', 'Outdoors'],
        ),
      ];

      if (mounted) {
        setState(() {
          _profiles.addAll(mockProfiles);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profiles: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _dragOffset += d.delta;
      _rotation = _dragOffset.dx / 300;
    });
  }

  void _onPanEnd(Profile profile, DragEndDetails d) {
    final velocity = d.velocity.pixelsPerSecond.dx;

    if (_dragOffset.dx.abs() > swipeThreshold || velocity.abs() > 900) {
      _animateOffScreen(profile, _dragOffset.dx > 0);
    } else {
      _animateBack();
    }
  }

  void _animateBack() {
    _positionAnim = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _rotationAnim = Tween<double>(
      begin: _rotation,
      end: 0,
    ).animate(_controller);

    _controller.forward(from: 0).then((_) {
      setState(() {
        _dragOffset = Offset.zero;
        _rotation = 0;
      });
    });
  }

  void _animateOffScreen(Profile profile, bool like) {
    final endX = like ? 600.0 : -600.0;
    final endY = _dragOffset.dy + Random().nextDouble() * 80;

    _positionAnim = Tween<Offset>(
      begin: _dragOffset,
      end: Offset(endX, endY),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _rotationAnim = Tween<double>(
      begin: _rotation,
      end: like ? 0.4 : -0.4,
    ).animate(_controller);

    _controller.forward(from: 0).then((_) {
      setState(() {
        _profiles.removeAt(0);
        _history.add(profile);
        _dragOffset = Offset.zero;
        _rotation = 0;
      });
    });
  }

  void _swipeByButton(bool like) {
    if (_profiles.isEmpty) return;
    _animateOffScreen(_profiles.first, like);
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      _profiles.insert(0, _history.removeLast());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: Center(
                      child: _profiles.isEmpty
                          ? _buildEmptyState()
                          : SizedBox(
                              width: 340,
                              height: 740,
                              child: Stack(
                                alignment: Alignment.center,
                                children: _profiles
                                    .take(3)
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final profile = entry.value;
                                  final isTop = index == 0;

                                  final scale = 1 - index * 0.05;
                                  final offsetY = index * 12.0;

                                  Widget card = Transform.translate(
                                    offset: isTop
                                        ? _dragOffset
                                        : Offset(0, offsetY),
                                    child: Transform.rotate(
                                      angle: isTop ? _rotation : 0,
                                      child: Transform.scale(
                                        scale: scale,
                                        child: ProfileCard(profile: profile),
                                      ),
                                    ),
                                  );

                                  if (!isTop) return card;

                                  return GestureDetector(
                                    onPanUpdate: _onPanUpdate,
                                    onPanEnd: (d) => _onPanEnd(profile, d),
                                    child: AnimatedBuilder(
                                      animation: _controller,
                                      builder: (_, __) {
                                        final offset = _positionAnim.value;
                                        final rot = _rotationAnim.value;

                                        return Transform.translate(
                                          offset: offset,
                                          child: Transform.rotate(
                                            angle: rot,
                                            child: card,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }).toList().reversed.toList(),
                              ),
                            ),
                    ),
                  ),
                  _actionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.favorite_outline,
          size: 80,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 24),
        Text(
          'No more profiles',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You\'ve swiped through everyone!',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _profiles.clear();
              _history.clear();
              _likedProfiles.clear();
              _passedProfiles.clear();
            });
            _loadProfiles();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF06595),
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text(
            'Reload Profiles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Undo button
          _actionButton(
            icon: Icons.undo,
            color: const Color(0xFF999999),
            onTap: _undo,
            label: 'Undo',
          ),
          // Pass button
          _actionButton(
            icon: Icons.close,
            color: const Color(0xFFE84B5C),
            onTap: () => _swipeByButton(false),
            label: 'Pass',
            large: true,
          ),
          // Super like button (Love)
          _actionButton(
            icon: Icons.favorite,
            color: const Color(0xFF3AB5FD),
            onTap: () {
              _swipeByButton(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Super Like! 🌟')),
              );
            },
            label: 'Love',
            large: true,
          ),
          // Like button
          _actionButton(
            icon: Icons.star,
            color: const Color(0xFFF06595),
            onTap: () {
              _swipeByButton(true);
              if (_profiles.isNotEmpty) {
                _likedProfiles.add(_profiles.first.id);
              }
            },
            label: 'Like',
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String label,
    bool large = false,
  }) {
    final size = large ? 64.0 : 56.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: large ? 28 : 24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
