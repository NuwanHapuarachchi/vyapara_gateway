import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';

class TaxBriefingScreen extends StatelessWidget {
  const TaxBriefingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final taxTypes = [
      _TaxType(
        'TIN (Taxpayer Identification Number)',
        'Unique identifier for all taxpayers',
        'Required for all businesses and individuals',
        'Free registration',
        '3-5 business days',
        Icons.numbers,
        AppColors.primary,
      ),
      _TaxType(
        'VAT (Value Added Tax)',
        'Tax on goods and services',
        'Required if annual turnover > LKR 12M',
        'Free registration',
        '7-10 business days',
        Icons.receipt_long,
        AppColors.warning,
      ),
      _TaxType(
        'PAYE (Pay As You Earn)',
        'Tax deducted from employee salaries',
        'Required if you have employees',
        'Free registration',
        '3-5 business days',
        Icons.people,
        AppColors.success,
      ),
      _TaxType(
        'ESC (Economic Service Charge)',
        'Tax on business turnover',
        'Required for certain business types',
        'Free registration',
        '5-7 business days',
        Icons.account_balance,
        AppColors.error,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tax Registration Guide',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Inland Revenue Department (IRD)',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The IRD is responsible for tax administration in Sri Lanka. All businesses must register for appropriate tax types based on their activities.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Available Tax Registrations',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),

            ...taxTypes.map(
              (taxType) => _TaxTypeCard(taxType: taxType, isDark: isDark),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Important Information',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• TIN is mandatory for all businesses\n'
                    '• VAT registration required if annual turnover exceeds LKR 12 million\n'
                    '• PAYE registration needed if you employ staff\n'
                    '• All registrations are free of charge\n'
                    '• Processing times may vary based on document completeness',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              child: NeumorphicButton(
                text: 'Continue to Application',
                onPressed: () => context.go('/tax/form'),
                isGreen: true,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              child: NeumorphicButton(
                text: 'Download Tax Guide',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Downloading IRD tax registration guide...',
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TaxTypeCard extends StatelessWidget {
  final _TaxType taxType;
  final bool isDark;

  const _TaxTypeCard({required this.taxType, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: taxType.color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: taxType.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(taxType.icon, color: taxType.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taxType.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      taxType.description,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: taxType.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              taxType.requirement,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: taxType.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _InfoChip('Fee: ${taxType.fee}', AppColors.success),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoChip(
                  'Processing: ${taxType.processingTime}',
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  final Color color;

  const _InfoChip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TaxType {
  final String name;
  final String description;
  final String requirement;
  final String fee;
  final String processingTime;
  final IconData icon;
  final Color color;

  _TaxType(
    this.name,
    this.description,
    this.requirement,
    this.fee,
    this.processingTime,
    this.icon,
    this.color,
  );
}

class TaxRegistrationFormScreen extends StatelessWidget {
  const TaxRegistrationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final requiredDocuments = [
      'Business Registration Certificate (BRC)',
      'NIC copies of all directors/owners',
      'Proof of business address',
      'Bank account details',
      'Business plan or financial projections',
      'Partnership agreement (if applicable)',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tax Registration Application',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Application Form',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your business information has been pre-filled from your profile. Please review and confirm the details.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Business Information',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),

            _FormSection(
              title: 'Company Details',
              fields: [
                _FormField('Business Name', 'ABC Trading Company (Pvt) Ltd'),
                _FormField('BR Number', 'BR123456789'),
                _FormField('Business Type', 'Private Limited Company'),
                _FormField('Date of Incorporation', '15/01/2024'),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            _FormSection(
              title: 'Contact Information',
              fields: [
                _FormField('Registered Address', '123 Main Street, Colombo 01'),
                _FormField('Business Address', '123 Main Street, Colombo 01'),
                _FormField('Phone Number', '+94 11 234 5678'),
                _FormField('Email Address', 'info@abctrading.lk'),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            _FormSection(
              title: 'Directors/Owners',
              fields: [
                _FormField('Director 1', 'John Doe - NIC: 123456789V'),
                _FormField('Director 2', 'Jane Smith - NIC: 987654321V'),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            Text(
              'Required Documents',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),

            ...requiredDocuments.map(
              (doc) => _DocumentItem(title: doc, isDark: isDark),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Important Notes',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• All documents must be clear and valid\n'
                    '• Processing time: 5-10 business days\n'
                    '• You will receive TIN via email/SMS\n'
                    '• VAT registration requires additional assessment\n'
                    '• Keep copies of all submitted documents',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              child: NeumorphicButton(
                text: 'Continue to Review',
                onPressed: () => context.go('/tax/review'),
                isGreen: true,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              child: NeumorphicButton(
                text: 'Download Application',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Downloading tax registration application...',
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<_FormField> fields;
  final bool isDark;

  const _FormSection({
    required this.title,
    required this.fields,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderLight : AppColors.borderLightTheme,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...fields.map(
            (field) => _FormRow(
              label: field.label,
              value: field.value,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField {
  final String label;
  final String value;

  _FormField(this.label, this.value);
}

class _FormRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _FormRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final String title;
  final bool isDark;

  const _DocumentItem({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaxSubmitScreen extends StatelessWidget {
  const TaxSubmitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final appointmentSteps = [
      'Visit IRD office during business hours (8:30 AM - 4:30 PM)',
      'Present all required documents to the counter',
      'Complete any additional forms if required',
      'Pay any applicable fees (if any)',
      'Receive acknowledgment receipt',
      'Wait for processing and TIN assignment',
    ];

    final irdOffices = [
      'IRD Head Office - Colombo 01',
      'IRD Branch Office - Colombo 03',
      'IRD Branch Office - Nugegoda',
      'IRD Branch Office - Kandy',
      'IRD Branch Office - Galle',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Submit to IRD',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ready for Submission',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your application is complete and ready to be submitted to the Inland Revenue Department.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // IRD Office Selection
            Text(
              'Select IRD Office',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppColors.borderLight
                      : AppColors.borderLightTheme,
                ),
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Choose your preferred IRD office',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: irdOffices
                    .map(
                      (office) =>
                          DropdownMenuItem(value: office, child: Text(office)),
                    )
                    .toList(),
                onChanged: (value) {},
              ),
            ),

            const SizedBox(height: 20),

            // Submission Steps
            Text(
              'Submission Process',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            ...appointmentSteps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // Documents to Bring
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.checklist, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'What to Bring',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Printed application form\n'
                    '• All required documents (originals + copies)\n'
                    '• Valid NIC for identification\n'
                    '• Business registration documents\n'
                    '• Proof of address',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    text: 'Back',
                    onPressed: () => context.pop(),
                    isGreen: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeumorphicButton(
                    text: 'Book Appointment',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Redirecting to IRD appointment booking...',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    isGreen: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              child: NeumorphicButton(
                text: 'Download Application Pack',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Downloading complete application pack...'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
