import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// iOS 16 Style Fluid Glass Floating Navigation Bar
class FluidGlassNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FluidGlassNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<FluidGlassNavigationBar> createState() =>
      _FluidGlassNavigationBarState();
}

class _FluidGlassNavigationBarState extends State<FluidGlassNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rippleController;
  late AnimationController _floatingController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _floatingAnimation;

  List<_NavItem> get _items => const [
    _NavItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      label: 'Apps',
    ),
    _NavItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      label: 'Alerts',
    ),
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Community',
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOutCirc),
    );

    _floatingAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _rippleController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index != widget.currentIndex) {
      HapticFeedback.lightImpact();
      _rippleController.forward(from: 0);
    }
    // Always forward tap to parent so it can route (even when already selected)
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value),
          child: Container(
            margin: const EdgeInsets.only(left: 24, right: 24, bottom: 34),
            height: 74,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(37),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(37),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ]
                          : [
                              Colors.white.withOpacity(0.75),
                              Colors.white.withOpacity(0.55),
                            ],
                    ),
                    border: Border.all(
                      width: 1.5,
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white.withOpacity(0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 20),
                      ),
                      BoxShadow(
                        color: isDark
                            ? AppColors.accent.withOpacity(0.1)
                            : AppColors.accent.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Animated background indicator
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        left:
                            14 +
                            (widget.currentIndex *
                                ((MediaQuery.of(context).size.width - 80) / 5)),
                        top: 12,
                        child: AnimatedBuilder(
                          animation: _rippleAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.accent.withOpacity(
                                      0.3 * (1 - _rippleAnimation.value),
                                    ),
                                    AppColors.accent.withOpacity(
                                      0.1 * (1 - _rippleAnimation.value),
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Navigation items
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(_items.length, (index) {
                          final isSelected = widget.currentIndex == index;
                          final item = _items[index];

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _handleTap(index),
                              behavior: HitTestBehavior.opaque,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutBack,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(
                                        begin: 0.0,
                                        end: isSelected ? 1.0 : 0.0,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      curve: Curves.easeOutBack,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: 1 + (value * 0.2),
                                          child: Transform.rotate(
                                            angle: value * 0.1,
                                            child: Icon(
                                              isSelected
                                                  ? item.activeIcon
                                                  : item.icon,
                                              color: isSelected
                                                  ? AppColors.accent
                                                  : (isDark
                                                        ? Colors.white
                                                              .withOpacity(0.6)
                                                        : AppColors
                                                              .textSecondary),
                                              size: 26,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(height: 4),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.accent,
                                        ),
                                        child: Text(item.label),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Bubble Animation Navigation Bar
class BubbleNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BubbleNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BubbleNavigationBar> createState() => _BubbleNavigationBarState();
}

class _BubbleNavigationBarState extends State<BubbleNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _waveController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _waveAnimation;

  List<_NavItem> get _items => const [
    _NavItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      label: 'Apps',
    ),
    _NavItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      label: 'Alerts',
    ),
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Community',
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _waveAnimation = CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index != widget.currentIndex) {
      HapticFeedback.lightImpact();
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
    }
    // Always notify parent to handle routing to dashboard
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated Bubble Background
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            left: (screenWidth / 5) * widget.currentIndex,
            top: 10,
            child: Container(
              width: screenWidth / 5,
              height: 65,
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(65, 65),
                    painter: _BubblePainter(
                      color: AppColors.accent,
                      animation: _waveAnimation.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // Liquid Effect Layer
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            left: 10 + (widget.currentIndex * ((screenWidth - 20) / 5)),
            top: 25,
            child: Container(
              width: (screenWidth - 20) / 5 - 20,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.2),
                    AppColors.accent.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Navigation Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final isSelected = widget.currentIndex == index;
              final item = _items[index];

              return Expanded(
                child: GestureDetector(
                  onTap: () => _handleTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isSelected ? 1.0 : _scaleAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                transform: Matrix4.identity()
                                  ..translate(0.0, isSelected ? -5.0 : 0.0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Glow effect for selected item
                                    if (isSelected)
                                      AnimatedBuilder(
                                        animation: _waveAnimation,
                                        builder: (context, child) {
                                          return Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.accent
                                                      .withOpacity(
                                                        0.3 +
                                                            (0.2 *
                                                                math.sin(
                                                                  _waveAnimation
                                                                          .value *
                                                                      2 *
                                                                      math.pi,
                                                                )),
                                                      ),
                                                  blurRadius: 15,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),

                                    // Icon with animation
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(
                                        begin: 0.0,
                                        end: isSelected ? 1.0 : 0.0,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeOutBack,
                                      builder: (context, value, child) {
                                        return Transform.rotate(
                                          angle: value * 2 * math.pi,
                                          child: Icon(
                                            isSelected
                                                ? item.activeIcon
                                                : item.icon,
                                            color: isSelected
                                                ? Colors.white
                                                : (isDark
                                                      ? AppColors.textSecondary
                                                      : AppColors
                                                            .textSecondaryLight),
                                            size: 26 + (value * 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Label with fade animation
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isSelected ? 1.0 : 0.0,
                                child: AnimatedSlide(
                                  duration: const Duration(milliseconds: 200),
                                  offset: Offset(0, isSelected ? 0 : 0.5),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      item.label,
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Bubble Painter for liquid effect
class _BubblePainter extends CustomPainter {
  final Color color;
  final double animation;

  _BubblePainter({required this.color, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // Main bubble
    canvas.drawCircle(center, 28, paint);

    // Animated bubbles
    for (int i = 0; i < 3; i++) {
      final angle = (animation * 2 * math.pi) + (i * 2 * math.pi / 3);
      final offset = Offset(
        center.dx + math.cos(angle) * 15,
        center.dy + math.sin(angle) * 15,
      );

      paint.color = color.withOpacity(0.15 - (i * 0.03));
      canvas.drawCircle(offset, 12 - (i * 2), paint);
    }

    // Center highlight
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: 20));

    canvas.drawCircle(center, 20, highlightPaint);
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// Navigation Item Model
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Navigation Bar Type Enum
enum NavigationBarType { neumorphic, fluidGlass, bubble }
