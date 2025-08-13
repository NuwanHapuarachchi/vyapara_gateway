import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';
import '../../../core/services/supabase_service.dart';
import '../models/business_registration_model.dart';
import '../providers/business_registration_provider.dart';

class ReviewSubmitScreen extends ConsumerStatefulWidget {
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;

  const ReviewSubmitScreen({
    super.key,
    required this.onPrevious,
    required this.onSubmit,
  });

  @override
  ConsumerState<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
}

class _ReviewSubmitScreenState extends ConsumerState<ReviewSubmitScreen> {
  bool _isSubmitting = false;
  bool _agreesToTerms = false;
  String _paymentMethod = 'pay_later';

  Future<void> _submitApplication() async {
    if (!_agreesToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final registration = ref.read(businessRegistrationProvider);
      if (registration != null) {
        final registrationData = {
          'business_name': registration.businessName,
          'business_type': registration.businessType.type,
          'business_type_id': registration.businessType.id,
          'proposed_trade_name': registration.proposedTradeName,
          'nature_of_business': registration.natureOfBusiness,
          'business_address': registration.businessAddress.toJson(),
          'business_details': {
            'owners': registration.owners.map((o) => o.toJson()).toList(),
            'partners':
                registration.partners?.map((p) => p.toJson()).toList() ?? [],
            'uploaded_documents': registration.uploadedDocuments ?? {},
            'payment_method': _paymentMethod,
            'registration_fee': registration.businessType.baseFee,
          },
          'status': 'submitted',
        };

        final success = await SupabaseService.createBusinessRegistration(
          registrationData,
        );

        if (success && mounted) {
          ref.read(businessRegistrationProvider.notifier).clearRegistration();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application submitted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );

          widget.onSubmit();
        } else {
          throw Exception('Failed to submit application');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final registration = ref.watch(businessRegistrationProvider);

    if (registration == null) {
      return const Center(child: Text('No registration data found'));
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(registration),
                  const SizedBox(height: 20),
                  _buildBusinessDetailsCard(registration),
                  const SizedBox(height: 20),
                  _buildPaymentCard(registration),
                  const SizedBox(height: 20),
                  _buildTermsCard(),
                ],
              ),
            ),
          ),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BusinessRegistration registration) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.primaryGradient),
        borderRadius: BorderRadius.circular(16),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Application Review',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Please review your information before submitting',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Business Type',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        registration.businessType.displayName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Registration Fee',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      'LKR ${registration.businessType.baseFee.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDetailsCard(BusinessRegistration registration) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Business Information',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Business Name', registration.businessName),
          if (registration.proposedTradeName != null)
            _buildInfoRow('Trade Name', registration.proposedTradeName!),
          _buildInfoRow('Nature of Business', registration.natureOfBusiness),
          _buildInfoRow(
            'Address',
            '${registration.businessAddress.addressLine1}, '
                '${registration.businessAddress.city}, '
                '${registration.businessAddress.district}',
          ),
          _buildInfoRow('Province', registration.businessAddress.province),
          _buildInfoRow('Postal Code', registration.businessAddress.postalCode),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BusinessRegistration registration) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Payment Method',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registration Fee',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'LKR ${registration.businessType.baseFee.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          RadioListTile<String>(
            value: 'pay_later',
            groupValue: _paymentMethod,
            onChanged: (value) => setState(() => _paymentMethod = value!),
            title: Text(
              'Pay Later (Post Office / Bank)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Submit application now, pay at post office or bank later',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            activeColor: AppColors.primary,
          ),

          RadioListTile<String>(
            value: 'online',
            groupValue: _paymentMethod,
            onChanged: null, // Disabled for now
            title: Text(
              'Online Payment (Coming Soon)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            subtitle: Text(
              'Pay instantly with credit/debit card or mobile wallet',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Terms & Conditions',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _agreesToTerms,
            onChanged: (value) => setState(() => _agreesToTerms = value!),
            title: Text(
              'I agree to the terms and conditions',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'By submitting this application, I confirm that all information provided is accurate and complete.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            activeColor: AppColors.primary,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Row(
      children: [
        Expanded(
          child: NeumorphicButton(
            text: 'Previous',
            onPressed: _isSubmitting ? null : widget.onPrevious,
            isGreen: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: NeumorphicButton(
            text: _isSubmitting ? 'Submitting...' : 'Submit Application',
            onPressed: _isSubmitting ? null : _submitApplication,
            isGreen: true,
          ),
        ),
      ],
    );
  }
}
