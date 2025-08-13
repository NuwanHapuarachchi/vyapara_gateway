import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

import '../models/business_registration_model.dart';
import '../providers/business_registration_provider.dart';
import 'business_type_selection_screen.dart';
import 'business_details_form_screen.dart';
import 'owners_partners_form_screen.dart';
import 'document_upload_screen.dart';
import 'review_submit_screen.dart';

class BusinessRegistrationWizard extends ConsumerStatefulWidget {
  const BusinessRegistrationWizard({super.key});

  @override
  ConsumerState<BusinessRegistrationWizard> createState() =>
      _BusinessRegistrationWizardState();
}

class _BusinessRegistrationWizardState
    extends ConsumerState<BusinessRegistrationWizard> {
  final PageController _pageController = PageController();
  BusinessRegistrationStep _currentStep = BusinessRegistrationStep.businessType;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep.index < BusinessRegistrationStep.values.length - 1) {
      setState(() {
        _currentStep = BusinessRegistrationStep.values[_currentStep.index + 1];
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep.index > 0) {
      setState(() {
        _currentStep = BusinessRegistrationStep.values[_currentStep.index - 1];
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep(BusinessRegistrationStep step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Business Registration',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Current Step Header
          _buildStepHeader(),

          // Step Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentStep = BusinessRegistrationStep.values[index];
                });
              },
              children: [
                BusinessTypeSelectionScreen(
                  onNext: _nextStep,
                  onTypeSelected: (businessType) {
                    ref
                        .read(businessRegistrationProvider.notifier)
                        .updateBusinessType(businessType);
                  },
                ),
                BusinessDetailsFormScreen(
                  onNext: _nextStep,
                  onPrevious: _previousStep,
                ),
                OwnersPartnersFormScreen(
                  onNext: _nextStep,
                  onPrevious: _previousStep,
                ),
                DocumentUploadScreen(
                  onNext: _nextStep,
                  onPrevious: _previousStep,
                ),
                ReviewSubmitScreen(
                  onPrevious: _previousStep,
                  onSubmit: () async {
                    // Handle submission
                    final registration = ref.read(businessRegistrationProvider);
                    if (registration != null) {
                      // TODO: Submit registration to Supabase
                      if (context.mounted) {
                        context.go('/applications');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: BusinessRegistrationStep.values.map((step) {
              final isActive = step.index <= _currentStep.index;
              final isCurrent = step == _currentStep;

              return GestureDetector(
                onTap: () => _goToStep(step),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.backgroundLight,
                    border: isCurrent
                        ? Border.all(color: AppColors.accent, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: isActive
                        ? Icon(
                            step.index < _currentStep.index
                                ? Icons.check
                                : Icons.circle,
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            '${step.stepNumber}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Progress bar
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor:
                  (_currentStep.index + 1) /
                  BusinessRegistrationStep.values.length,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${_currentStep.stepNumber} of ${BusinessRegistrationStep.values.length}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentStep.title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentStep.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
