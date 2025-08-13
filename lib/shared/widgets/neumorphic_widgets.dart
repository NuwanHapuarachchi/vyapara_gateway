import 'package:flutter/material.dart';
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
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),

        // Input Field with Neumorphic Effect
        Container(
          width: 318,
          height: 65,
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              // Inner shadow - dark (bottom-right)
              BoxShadow(
                color: const Color(0xFF252525).withValues(alpha: 0.34),
                offset: const Offset(4, 4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
              // Inner shadow - light (top-left)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.25),
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
              color: AppColors.textSecondary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textSecondary,
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
    return Container(
      width: 318,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: isGreen
            ? [
                // Drop shadow - dark
                BoxShadow(
                  color: const Color(0xFF252525).withValues(alpha: 0.34),
                  offset: const Offset(10, 10),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
                // Drop shadow - light
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.25),
                  offset: const Offset(-10, -10),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : [
                // Default button shadows
                BoxShadow(
                  color: const Color(0xFF252525).withValues(alpha: 0.34),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.25),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Material(
        color: isGreen ? AppColors.accentGreen : AppColors.backgroundDark,
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
                            ? AppColors.backgroundDark
                            : AppColors.textSecondary,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isGreen
                            ? AppColors.backgroundDark
                            : AppColors.textSecondary,
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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: isPressed
            ? [
                // Inset shadow for pressed state
                BoxShadow(
                  color: const Color(0xFF252525).withValues(alpha: 0.34),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.25),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : [
                // Drop shadow for normal state
                BoxShadow(
                  color: const Color(0xFF252525).withValues(alpha: 0.34),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.25),
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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        boxShadow: [
          // Inner shadow - dark (bottom-right)
          BoxShadow(
            color: const Color(0xFF252525).withValues(alpha: 0.34),
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          // Inner shadow - light (top-left)
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.25),
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

/// Custom Bottom Navigation Bar with neumorphic effect
class NeumorphicBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NeumorphicBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: Stack(
        children: [
          // Background with blur effect
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 66,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.15),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),

          // Center elevated home button
          Positioned(
            top: 0,
            left: MediaQuery.of(context).size.width / 2 - 32.5,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF0C0C0C),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTap(2), // Home is index 2
                  customBorder: const CircleBorder(),
                  child: const Icon(
                    Icons.home,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),

          // Other navigation items
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 66,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.settings, 0),
                _buildNavItem(Icons.notifications, 1),
                const SizedBox(width: 65), // Space for home button
                _buildNavItem(Icons.people, 3),
                _buildNavItem(Icons.folder, 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
      ),
    );
  }
}
