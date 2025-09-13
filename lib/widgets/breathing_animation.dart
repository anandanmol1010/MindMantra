import 'package:flutter/material.dart';

class BreathingAnimation extends StatefulWidget {
  const BreathingAnimation({super.key});

  @override
  State<BreathingAnimation> createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  
  bool _isBreathingIn = true;
  String _instructionText = 'Breathe In';

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _startBreathingCycle();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.blue[300],
      end: Colors.blue[600],
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isBreathingIn = false;
          _instructionText = 'Hold';
        });
        
        // Hold for 1 second
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _instructionText = 'Breathe Out';
            });
            _animationController.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _isBreathingIn = true;
          _instructionText = 'Hold';
        });
        
        // Hold for 1 second
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _instructionText = 'Breathe In';
            });
            _animationController.forward();
          }
        });
      }
    });
  }

  void _startBreathingCycle() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _colorAnimation.value?.withOpacity(0.3) ?? Colors.blue.withOpacity(0.3),
                    _colorAnimation.value?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colorAnimation.value,
                    boxShadow: [
                      BoxShadow(
                        color: (_colorAnimation.value ?? Colors.blue).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.air,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          _instructionText,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getInstructionSubtext(),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                if (_animationController.isAnimating) {
                  _animationController.stop();
                } else {
                  _startBreathingCycle();
                }
              },
              icon: Icon(
                _animationController.isAnimating ? Icons.pause : Icons.play_arrow,
                size: 32,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {
                _animationController.reset();
                setState(() {
                  _isBreathingIn = true;
                  _instructionText = 'Breathe In';
                });
              },
              icon: const Icon(
                Icons.refresh,
                size: 32,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getInstructionSubtext() {
    switch (_instructionText) {
      case 'Breathe In':
        return 'Slowly inhale through your nose\nfor 4 seconds';
      case 'Breathe Out':
        return 'Slowly exhale through your mouth\nfor 4 seconds';
      case 'Hold':
        return 'Hold your breath gently\nfor 1 second';
      default:
        return '';
    }
  }
}
