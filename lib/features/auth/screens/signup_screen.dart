import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';
import '../providers/auth_provider.dart';

/// Signup Screen with same design theme as login
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nicController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nicController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .signup(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            nic: _nicController.text.trim(),
            password: _passwordController.text,
          );

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

                // Logo (smaller than login)
                _buildLogo(),

                const SizedBox(height: 40),

                // Create Account Text
                _buildCreateAccountText(),

                const SizedBox(height: 40),

                // Name Field
                _buildNameField(),

                const SizedBox(height: 20),

                // Email Field
                _buildEmailField(),

                const SizedBox(height: 20),

                // Phone Field
                _buildPhoneField(),

                const SizedBox(height: 20),

                // NIC Field
                _buildNicField(),

                const SizedBox(height: 20),

                // Password Field
                _buildPasswordField(),

                const SizedBox(height: 20),

                // Confirm Password Field
                _buildConfirmPasswordField(),

                const SizedBox(height: 30),

                // Sign Up Button
                _buildSignUpButton(),

                const SizedBox(height: 25),

                // Login Section
                _buildLoginSection(),

                const SizedBox(height: 33),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 150,
      height: 150,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/logooo.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildCreateAccountText() {
    return Text(
      'Create Account',
      style: const TextStyle(
        fontFamily: 'BrittanySignature',
        fontSize: 44,
        fontWeight: FontWeight.normal,
        color: AppColors.accent,
        height: 1.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNameField() {
    return NeumorphicInputField(
      label: 'Full Name',
      hintText: 'Enter your full name',
      controller: _nameController,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your full name';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return NeumorphicInputField(
      label: 'Email',
      hintText: 'Enter your email address',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email address';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return NeumorphicInputField(
      label: 'Phone Number',
      hintText: 'Enter your phone number',
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your phone number';
        }
        if (value.trim().length < 10) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
    );
  }

  Widget _buildNicField() {
    return NeumorphicInputField(
      label: 'NIC Number',
      hintText: 'Enter your NIC number',
      controller: _nicController,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your NIC number';
        }
        if (value.trim().length < 10) {
          return 'Please enter a valid NIC number';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return _buildPasswordFieldWidget(
      label: 'Password',
      hintText: 'Create a password',
      controller: _passwordController,
      isObscured: _obscurePassword,
      onToggle: () {
        setState(() {
          _obscurePassword = !_obscurePassword;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildPasswordFieldWidget(
      label: 'Confirm Password',
      hintText: 'Confirm your password',
      controller: _confirmPasswordController,
      isObscured: _obscureConfirmPassword,
      onToggle: () {
        setState(() {
          _obscureConfirmPassword = !_obscureConfirmPassword;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordFieldWidget({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggle,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          child: Stack(
            children: [
              TextFormField(
                controller: controller,
                obscureText: isObscured,
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
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(
                    left: 27,
                    right: 60,
                    top: 22,
                    bottom: 22,
                  ),
                ),
                validator: validator,
              ),
              Positioned(
                right: 19,
                top: 20,
                child: NeumorphicEyeIcon(
                  isObscured: isObscured,
                  onTap: onToggle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return NeumorphicButton(
      text: 'Create Account',
      isGreen: true,
      isLoading: _isLoading,
      onPressed: _isLoading ? null : _handleSignup,
    );
  }

  Widget _buildLoginSection() {
    return SizedBox(
      width: 318,
      height: 54,
      child: Stack(
        children: [
          // Base text "Already have an account ?"
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 13,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Already have an account ?",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // "Login now" link with underline
          Positioned(
            left: 0,
            top: 13,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    context.go('/login');
                  },
                  child: Text(
                    'Login now',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondary,
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
                Container(width: 85, height: 1, color: AppColors.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
