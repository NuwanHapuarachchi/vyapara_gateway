import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Neumorphic Input Field Widget matching Figma design
class NeumorphicInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const NeumorphicInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textSecondary
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 14),

        // Input Field with Neumorphic Effect
        Container(
          width: 318,
          height: 65,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              // Inner shadow - dark (bottom-right)
              BoxShadow(
                color: const Color(0xFF252525).withOpacity(0.34),
                offset: const Offset(4, 4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
              // Inner shadow - light (top-left)
              BoxShadow(
                color: Colors.white.withOpacity(0.25),
                offset: const Offset(-4, -4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondary
                    : AppColors.textTertiaryLight,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 27,
                vertical: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Neumorphic Button Widget matching Figma design
class NeumorphicButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isGreen;
  final bool isLoading;

  const NeumorphicButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isGreen = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 318,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: isGreen
            ? [
                // Drop shadow - dark
                BoxShadow(
                  color: const Color(0xFF252525).withOpacity(0.34),
                  offset: const Offset(10, 10),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
                // Drop shadow - light
                BoxShadow(
                  color: Colors.white.withOpacity(0.25),
                  offset: const Offset(-10, -10),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : [
                // Default button shadows
                BoxShadow(
                  color: const Color(0xFF252525).withOpacity(0.34),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.25),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Material(
        color: isGreen
            ? AppColors.accent
            : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: isGreen
                            ? (isDark
                                  ? AppColors.backgroundDark
                                  : AppColors.backgroundLight)
                            : (isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryLight),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isGreen
                            ? (isDark
                                  ? AppColors.backgroundDark
                                  : AppColors.backgroundLight)
                            : (isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryLight),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Eye Icon Widget for password field
class NeumorphicEyeIcon extends StatelessWidget {
  final bool isObscured;
  final VoidCallback onTap;

  const NeumorphicEyeIcon({
    super.key,
    required this.isObscured,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.only(right: 16),
        child: Icon(
          isObscured ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }
}

/// Neumorphic Card Widget for dashboard elements
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool isPressed;
  final BorderRadius? borderRadius;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.onTap,
    this.isPressed = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: isPressed
            ? [
                // Inset shadow for pressed state
                BoxShadow(
                  color: const Color(0xFF252525).withOpacity(0.34),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.25),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : [
                // Drop shadow for normal state
                BoxShadow(
                  color: const Color(0xFF252525).withOpacity(0.34),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.25),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Neumorphic Container with inset effect
class NeumorphicInset extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const NeumorphicInset({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        boxShadow: [
          // Inner shadow - dark (bottom-right)
          BoxShadow(
            color: const Color(0xFF252525).withOpacity(0.34),
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          // Inner shadow - light (top-left)
          BoxShadow(
            color: Colors.white.withOpacity(0.25),
            offset: const Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

/// Glassmorphic Card with blur effect and Sri Lankan themed colors
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Color? tint;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius br = borderRadius ?? BorderRadius.circular(16);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTint = tint ?? (isDark ? Colors.white : AppColors.primary);

    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: br,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      effectiveTint.withOpacity(0.1),
                      effectiveTint.withOpacity(0.05),
                    ]
                  : [
                      effectiveTint.withOpacity(0.12),
                      effectiveTint.withOpacity(0.06),
                    ],
            ),
            border: Border.all(
              color: effectiveTint.withOpacity(isDark ? 0.2 : 0.18),
              width: isDark ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: effectiveTint.withOpacity(isDark ? 0.1 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: br,
              child: Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated Custom Bottom Navigation Bar with neumorphic effect
class NeumorphicBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NeumorphicBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<NeumorphicBottomNavBar> createState() => _NeumorphicBottomNavBarState();
}

class _NeumorphicBottomNavBarState extends State<NeumorphicBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _homeAnimationController;
  late AnimationController _tapAnimationController;
  late Animation<double> _homeScaleAnimation;
  late Animation<double> _tapScaleAnimation;

  @override
  void initState() {
    super.initState();
    _homeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _tapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _homeScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _homeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _tapScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _tapAnimationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _homeAnimationController.dispose();
    _tapAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 95,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.9),
                    ]
                  : [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.95),
                    ],
            ),
            border: Border(
              top: BorderSide(
                color: AppColors.accent.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Stack(
            children: [
              // Center elevated home button
              Positioned(
                top: 8,
                left: MediaQuery.of(context).size.width / 2 - 32.5,
                child: AnimatedBuilder(
                  animation: _homeScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _homeScaleAnimation.value,
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.accent.withOpacity(0.3),
                              AppColors.secondary.withOpacity(0.2),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _homeAnimationController.forward().then((_) {
                                _homeAnimationController.reverse();
                              });
                              widget.onTap(2);
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.home,
                                color: Colors.blue,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Other navigation items
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.folder, 0), // Applications
                    _buildNavItem(Icons.notifications, 1), // Notifications
                    const SizedBox(width: 65), // Space for home button
                    _buildNavItem(Icons.people, 3), // Community
                    _buildNavItem(Icons.settings, 4), // Settings
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = widget.currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isSelected
        ? _getIndexColor(index)
        : (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight);

    return AnimatedBuilder(
      animation: _tapScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? 1.0 : _tapScaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (!isSelected) {
                  _tapAnimationController.forward().then((_) {
                    _tapAnimationController.reverse();
                  });
                }
                widget.onTap(index);
              },
              customBorder: const CircleBorder(),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            _getIndexColor(index).withOpacity(0.2),
                            _getIndexColor(index).withOpacity(0.1),
                          ],
                        )
                      : null,
                  border: isSelected
                      ? Border.all(
                          color: _getIndexColor(index).withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getIndexColor(int index) {
    // Use same color for all navigation items
    return AppColors.primary;
  }
}
