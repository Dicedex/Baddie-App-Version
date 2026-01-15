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
 final List<Profile> _profiles = [
  Profile(
    id: '1',
    name: 'Ava',
    age: 25,
    imageUrl: 'https://picsum.photos/400/700?1',
    bio: 'Loves coffee and travel',
    interests: ['Music', 'Travel'],
  ),
  Profile(
    id: '2',
    name: 'Mia',
    age: 27,
    imageUrl: 'https://picsum.photos/400/700?2',
    bio: 'Foodie and photographer',
    interests: ['Food', 'Movies'],
  ),
  Profile(
    id: '3',
    name: 'Zoe',
    age: 24,
    imageUrl: 'https://picsum.photos/400/700?3',
    bio: 'Runner and software dev',
    interests: ['Fitness', 'Outdoors'],
  ),
];


  final List<Profile> _history = [];

  late AnimationController _controller;
  late Animation<Offset> _positionAnim;
  late Animation<double> _rotationAnim;

  Offset _dragOffset = Offset.zero;
  double _rotation = 0;

  static const swipeThreshold = 120.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _profiles.isEmpty
                    ? const Text('No more profiles')
                    : SizedBox(
                        width: 360,
                        height: 600,
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
                                  final offset =
                                      _positionAnim.value;
                                  final rot =
                                      _rotationAnim.value;

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

  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleButton(Icons.close, Colors.red, () => _swipeByButton(false)),
        const SizedBox(width: 20),
        _circleButton(Icons.star, Colors.blue, () {}),
        const SizedBox(width: 20),
        _circleButton(Icons.favorite, Colors.green, () => _swipeByButton(true)),
        const SizedBox(width: 16),
        _circleButton(Icons.undo, Colors.grey, _undo, size: 44),
      ],
    );
  }

  Widget _circleButton(
    IconData icon,
    Color color,
    VoidCallback onTap, {
    double size = 56,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.55),
      ),
    );
  }
}
