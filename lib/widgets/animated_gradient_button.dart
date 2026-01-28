import 'package:flutter/material.dart';

class AnimatedGradientButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final bool enabled;
  final Gradient? gradient;
  final double borderRadius;

  const AnimatedGradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.enabled = true,
    this.gradient,
    this.borderRadius = 12,
  });

  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.enabled && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _onTapUp(_) {
    if (widget.enabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultGradient = LinearGradient(
      colors: [Colors.purple.shade400, Colors.pink.shade400],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: () {
          _animationController.reverse();
        },
        onTap: widget.enabled && !widget.isLoading ? widget.onPressed : null,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: widget.enabled
                ? (widget.gradient ?? defaultGradient)
                : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade500],
              ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
