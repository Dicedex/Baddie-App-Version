import 'package:flutter/material.dart';
import '../models/profile.dart';

class ProfileCard extends StatefulWidget {
  final Profile profile;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.profile,
    this.onTap,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late PageController _photoController;
  int _currentPhotoIndex = 0;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;
  final DateTime _lastTap = DateTime.now();

  @override
  void initState() {
    super.initState();
    _photoController = PageController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _setupAnimations();
  }

  void _setupAnimations() {
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _opacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutQuad),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _photoController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() {
      _expanded = true;
    });
    _animController.forward();
    widget.onTap?.call();
  }

  void _collapse() {
    _animController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _expanded = false;
        });
      }
    });
  }

  void _onDoubleTap() {
    if (!_expanded) {
      _expand();
    }
  }

  void _onPhotoTap() {
    if (!_expanded) {
      _expand();
    }
  }

  void _onBottomTap() {
    if (!_expanded) {
      _expand();
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_expanded && details.delta.dy > 0) {
      // Swiping down to close
      _collapse();
    } else if (!_expanded && details.delta.dy < -10) {
      // Swiping up to expand
      _expand();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_expanded) {
      return _buildExpandedView();
    }
    return _buildCollapsedView();
  }

  Widget _buildCollapsedView() {
    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image carousel (show first image in collapsed)
              GestureDetector(
                onDoubleTap: _onDoubleTap,
                onTap: _onPhotoTap,
                child: _buildImageCarousel(),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
              // Photo indicators
              if (widget.profile.imageUrls.length > 1)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _buildPhotoIndicators(),
                ),
              // Info button
              Positioned(
                bottom: 16,
                right: 16,
                child: GestureDetector(
                  onTap: _onPhotoTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.info,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Bottom info - tap to expand
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _onBottomTap,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.95),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name and Age
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.profile.name}, ${widget.profile.age}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.profile.personality} • ${widget.profile.interests.isNotEmpty ? widget.profile.interests.first : 'No interests'}',
                                    style: const TextStyle(
                                      color: Color(0xFFB3B3B3),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Bio preview
                        if (widget.profile.bio.isNotEmpty)
                          Text(
                            widget.profile.bio,
                            style: const TextStyle(
                              color: Color(0xFFE0E0E0),
                              fontSize: 14,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedView() {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 5) {
          // Pull down to close
          _collapse();
        }
      },
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Material(
            color: Colors.black.withOpacity(_opacityAnim.value * 0.95),
            child: SafeArea(
              child: Stack(
                children: [
                  // Backdrop
                  GestureDetector(
                    onTap: _collapse,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                  // Content
                  Positioned.fill(
                    child: Column(
                      children: [
                        // Header with close button
                        _buildHeader(),
                        // Photo carousel
                        Expanded(
                          flex: 2,
                          child: Transform.scale(
                            scale: _scaleAnim.value,
                            child: Transform.translate(
                              offset: _slideAnim.value,
                              child: Opacity(
                                opacity: _opacityAnim.value,
                                child: _buildPhotoCarousel(),
                              ),
                            ),
                          ),
                        ),
                        // Bottom info section with scrolling
                        Expanded(
                          flex: 1,
                          child: Transform.translate(
                            offset: _slideAnim.value * 2,
                            child: Opacity(
                              opacity: _opacityAnim.value,
                              child: _buildScrollableInfo(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Photo counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              '${_currentPhotoIndex + 1}/${widget.profile.imageUrls.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Close button
          GestureDetector(
            onTap: _collapse,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCarousel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GestureDetector(
        onTap: _collapse,
        child: PageView.builder(
          controller: _photoController,
          onPageChanged: (index) {
            setState(() {
              _currentPhotoIndex = index;
            });
          },
          itemCount: widget.profile.imageUrls.length,
          itemBuilder: (context, index) {
            return _buildPhotoSlide(widget.profile.imageUrls[index]);
          },
        ),
      ),
    );
  }

  Widget _buildScrollableInfo() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.95),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name and Age
              Text(
                '${widget.profile.name}, ${widget.profile.age}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              // Personality
              Text(
                widget.profile.personality,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              // Full bio
              if (widget.profile.bio.isNotEmpty) ...[
                const Text(
                  'About',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.profile.bio,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // Interests
              if (widget.profile.interests.isNotEmpty) ...[
                const Text(
                  'Interests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.profile.interests.map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.12),
                            Colors.white.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        interest,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
              // Anthem (Spotify)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.music_note,
                      color: Colors.green[300],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Anthem',
                            style: TextStyle(
                              color: Colors.green[300],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Blinding Lights - The Weeknd',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Hint
              Center(
                child: Text(
                  'Pull down to close',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    if (widget.profile.imageUrls.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.person, size: 80, color: Colors.white70),
        ),
      );
    }

    return Image.network(
      widget.profile.imageUrls[0],
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.person, size: 80, color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildPhotoSlide(String imageUrl) {
    return Container(
      color: Colors.grey[900],
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.image_not_supported,
                size: 60, color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoIndicators() {
    return Row(
      children: List.generate(
        widget.profile.imageUrls.length,
        (index) => Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index == 0
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
