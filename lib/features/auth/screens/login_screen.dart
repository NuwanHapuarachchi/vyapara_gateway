import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';
import '../providers/auth_provider.dart';

/// Login Screen with exact Figma design implementation
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);

      if (mounted) {
        final authState = ref.read(authProvider);
        authState.when(
          loading: () {},
          error: (error, _) {
            _showErrorSnackBar(error.toString());
          },
          data: (user) {
            if (user != null) {
              context.go('/dashboard');
            }
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceAll('Exception: ', '')),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen<AsyncValue<UserProfile?>>(authProvider, (previous, next) {
      next.when(
        loading: () {},
        error: (error, _) {
          _showErrorSnackBar(error.toString());
        },
        data: (user) {
          if (user != null && mounted) {
            context.go('/dashboard');
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 42),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 5),

                // Logo
                _buildLogo(),

                const SizedBox(height: 72), // Gap between logo and welcome text
                // Welcome Text
                _buildWelcomeText(),

                const SizedBox(height: 65), // Gap to email field
                // Email Field
                _buildEmailField(),

                const SizedBox(height: 25), // Gap between fields
                // Password Field
                _buildPasswordField(),

                const SizedBox(height: 14), // Small gap to forgot password
                // Forgot Password Link
                _buildForgotPasswordLink(),

                const SizedBox(height: 37), // Gap to login button
                // Login Button
                _buildLoginButton(),

                const SizedBox(height: 20), // Gap to alternate login
                // Alternate Login Text
                _buildAlternateLoginText(),

                const SizedBox(height: 20), // Gap to signup section
                // Sign Up Section
                _buildSignUpSection(),

                const SizedBox(height: 33), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 208,
      height: 208,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/logooo.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Text(
      'welcome !!',
      style: const TextStyle(
        fontFamily: 'BrittanySignature',
        fontSize: 48,
        fontWeight: FontWeight.normal,
        color: AppColors.accent, // Yellow from Figma
        height: 1.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField() {
    return NeumorphicInputField(
      label: 'Email / Phone',
      hintText: 'Enter your email or phone number',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email or phone number';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: 318,
          height: 65,
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              // Inner shadow - dark
              BoxShadow(
                color: const Color(0xFF252525).withOpacity(0.34),
                offset: const Offset(4, 4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
              // Inner shadow - light
              BoxShadow(
                color: Colors.white.withOpacity(0.25),
                offset: const Offset(-4, -4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(
                    left: 27,
                    right: 60, // Space for eye icon
                    top: 22,
                    bottom: 22,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              // Eye Icon positioned from Figma
              Positioned(
                right: 19,
                top: 20,
                child: NeumorphicEyeIcon(
                  isObscured: _obscurePassword,
                  onTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 25),
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Forgot password feature coming soon!'),
              ),
            );
          },
          child: Text(
            'Fogot Password ?',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return NeumorphicButton(
      text: 'Login',
      isGreen: true,
      isLoading: _isLoading,
      onPressed: _isLoading ? null : _handleLogin,
    );
  }

  Widget _buildAlternateLoginText() {
    return Text(
      'Alternate Login',
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSignUpSection() {
    return Column(
      children: [
        // "Don't have an account ?" text
        Text(
          "Don't have an account ?",
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8), // Small gap between texts
        // "Sign Up now" link with underline
        Column(
          children: [
            GestureDetector(
              onTap: () {
                context.go('/signup');
              },
              child: Text(
                'Sign Up now',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondary, // Pink from Figma
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            // Underline
            Container(width: 85, height: 1, color: AppColors.secondary),
          ],
        ),
      ],
    );
  }
}
