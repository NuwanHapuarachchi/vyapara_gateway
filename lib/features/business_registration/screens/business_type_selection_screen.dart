import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';
import '../models/business_registration_model.dart';
import '../providers/business_registration_provider.dart';

class BusinessTypeSelectionScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final Function(BusinessType) onTypeSelected;

  const BusinessTypeSelectionScreen({
    super.key,
    required this.onNext,
    required this.onTypeSelected,
  });

  @override
  ConsumerState<BusinessTypeSelectionScreen> createState() =>
      _BusinessTypeSelectionScreenState();
}

class _BusinessTypeSelectionScreenState
    extends ConsumerState<BusinessTypeSelectionScreen> {
  BusinessType? _selectedBusinessType;

  @override
  Widget build(BuildContext context) {
    final businessTypesAsync = ref.watch(businessTypesProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: businessTypesAsync.when(
              data: (businessTypes) => _buildBusinessTypesList(businessTypes),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, stackTrace) => _buildErrorState(),
            ),
          ),

          // Continue Button
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildBusinessTypesList(List<BusinessType> businessTypes) {
    return ListView.builder(
      itemCount: businessTypes.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final businessType = businessTypes[index];
        final isSelected = _selectedBusinessType?.id == businessType.id;

        return _buildBusinessTypeCard(businessType, isSelected);
      },
    );
  }

  Widget _buildBusinessTypeCard(BusinessType businessType, bool isSelected) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedBusinessType = businessType;
          });
          widget.onTypeSelected(businessType);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // Improve selected visibility with gradient + glow
            color: isSelected
                ? null
                : (isDark ? AppColors.cardDark : AppColors.cardLight),
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.primary.withOpacity(isDark ? 0.22 : 0.14),
                      Colors.transparent,
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.borderLight
                        : AppColors.borderLightTheme),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              if (isSelected)
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getBusinessTypeColor(
                        businessType.type,
                      ).withOpacity(isSelected ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getBusinessTypeColor(
                          businessType.type,
                        ).withOpacity(isSelected ? 0.45 : 0.25),
                      ),
                    ),
                    child: Icon(
                      _getBusinessTypeIcon(businessType.type),
                      color: _getBusinessTypeColor(businessType.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          businessType.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.textPrimary
                                      : AppColors.textPrimaryLight),
                          ),
                        ),
                        Text(
                          businessType.description,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Processing time and fee
              Row(
                children: [
                  _buildInfoChip(
                    Icons.schedule,
                    '${businessType.estimatedProcessingDays} days',
                    isDark ? Colors.orange : const Color(0xFFEA580C),
                    bgOpacity: isSelected ? 0.18 : 0.10,
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.payment,
                    'LKR ${businessType.baseFee.toStringAsFixed(2)}',
                    isDark ? Colors.green : const Color(0xFF059669),
                    bgOpacity: isSelected ? 0.18 : 0.10,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Required documents count
              Text(
                '${businessType.requiredDocuments.length} documents required',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String text,
    Color color, {
    double bgOpacity = 0.10,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(bgOpacity),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Failed to load business types',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          NeumorphicButton(
            text: 'Retry',
            onPressed: () => ref.refresh(businessTypesProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20),
      child: NeumorphicButton(
        text: 'Continue',
        onPressed: _selectedBusinessType != null ? widget.onNext : null,
        isGreen: _selectedBusinessType != null,
      ),
    );
  }

  Color _getBusinessTypeColor(String type) {
    switch (type) {
      case 'sole_proprietorship':
        return const Color(0xFF3B82F6);
      case 'partnership':
        return const Color(0xFF10B981);
      case 'private_limited_company':
        return const Color(0xFF8B5CF6);
      case 'public_limited_company':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.primary;
    }
  }

  IconData _getBusinessTypeIcon(String type) {
    switch (type) {
      case 'sole_proprietorship':
        return Icons.person_outline;
      case 'partnership':
        return Icons.people_outline;
      case 'private_limited_company':
        return Icons.business_outlined;
      case 'public_limited_company':
        return Icons.domain_outlined;
      default:
        return Icons.business;
    }
  }
}
