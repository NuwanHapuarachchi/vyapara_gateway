import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';

class BankSelectionScreen extends StatelessWidget {
  const BankSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final banks = <_BankInfo>[
      _BankInfo(
        'Bank of Ceylon (BOC)',
        'State-owned bank with extensive branch network',
        'assets/banks/boc.png',
        'Min. deposit: LKR 5,000\nProcessing time: 3-5 days\nBranch network: 650+',
        ['SME loans', 'Trade finance', 'Online banking', 'Mobile app'],
        'LKR 2,500/year',
      ),
      _BankInfo(
        'People\'s Bank',
        'Government bank with strong local presence',
        'assets/banks/peoples.png',
        'Min. deposit: LKR 5,000\nProcessing time: 3-7 days\nBranch network: 740+',
        [
          'Business loans',
          'Export financing',
          'Digital banking',
          'SME support',
        ],
        'LKR 2,000/year',
      ),
      _BankInfo(
        'Commercial Bank of Ceylon',
        'Leading private sector bank',
        'assets/banks/combank.png',
        'Min. deposit: LKR 10,000\nProcessing time: 2-4 days\nBranch network: 270+',
        [
          'Corporate banking',
          'Trade services',
          'Digital solutions',
          '24/7 support',
        ],
        'LKR 3,500/year',
      ),
      _BankInfo(
        'Hatton National Bank (HNB)',
        'Innovative banking solutions',
        'assets/banks/hnb.png',
        'Min. deposit: LKR 10,000\nProcessing time: 2-3 days\nBranch network: 250+',
        [
          'SME banking',
          'Digital platforms',
          'Trade finance',
          'Investment services',
        ],
        'LKR 3,000/year',
      ),
      _BankInfo(
        'Sampath Bank',
        'Technology-driven banking',
        'assets/banks/sampath.png',
        'Min. deposit: LKR 5,000\nProcessing time: 2-4 days\nBranch network: 230+',
        ['Digital banking', 'SME loans', 'Trade services', 'Mobile solutions'],
        'LKR 2,500/year',
      ),
      _BankInfo(
        'Seylan Bank',
        'Customer-focused banking',
        'assets/banks/seylan.png',
        'Min. deposit: LKR 5,000\nProcessing time: 3-5 days\nBranch network: 170+',
        ['Business accounts', 'Trade finance', 'Online banking', 'SME support'],
        'LKR 2,000/year',
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
          onPressed: () => context.go('/applications'),
        ),
        title: Text(
          'Choose Your Banking Partner',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: Padding(
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
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select a bank that best suits your business needs. All banks are licensed by the Central Bank of Sri Lanka.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Available Banks',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: banks.length,
                itemBuilder: (context, index) {
                  final bank = banks[index];
                  return _BankCard(
                    bank: bank,
                    onTap: () {
                      context.go('/banking/prepare');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  final _BankInfo bank;
  final VoidCallback onTap;
  const _BankCard({required this.bank, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderLight : AppColors.borderLightTheme,
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bank.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bank.description,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bank.details,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: bank.features
                    .map(
                      (feature) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          feature,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_money, size: 14, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    'Annual fee: ${bank.annualFee}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankInfo {
  final String name;
  final String description;
  final String logoPath;
  final String details;
  final List<String> features;
  final String annualFee;

  _BankInfo(
    this.name,
    this.description,
    this.logoPath,
    this.details,
    this.features,
    this.annualFee,
  );
}

class BankPreparationScreen extends StatelessWidget {
  const BankPreparationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bank = ModalRoute.of(context)!.settings.arguments as _BankInfo?;
    final bankName = bank?.name ?? 'Selected Bank';

    final requiredDocs = [
      'Business Registration Certificate (BRC)',
      'NIC copies of all directors/owners',
      'Proof of business address (utility bill/lease agreement)',
      'Board resolution for account opening (if applicable)',
      'Tax registration certificate (if available)',
      'Business plan or financial projections',
    ];

    final additionalDocs = [
      'Partnership agreement (if applicable)',
      'Certificate of incorporation (for companies)',
      'Memorandum and Articles of Association',
      'Bank statements from existing accounts',
      'Trade license (if applicable)',
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
          onPressed: () => context.go('/applications'),
        ),
        title: Text(
          'Document Preparation',
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
                        Icons.account_balance,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          bankName,
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
                    'Required Documents for Account Opening',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Required Documents Section
            Text(
              'Essential Documents (All Required)',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            ...requiredDocs.map(
              (doc) =>
                  _DocumentItem(title: doc, isRequired: true, isDark: isDark),
            ),

            const SizedBox(height: 24),

            // Additional Documents Section
            Text(
              'Additional Documents (If Applicable)',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            ...additionalDocs.map(
              (doc) =>
                  _DocumentItem(title: doc, isRequired: false, isDark: isDark),
            ),

            const SizedBox(height: 24),

            // Important Notes
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
                    '• All documents must be original or certified copies\n'
                    '• NIC copies must be clear and valid\n'
                    '• Business address proof should be recent (within 3 months)\n'
                    '• Processing time: 3-7 business days\n'
                    '• Initial deposit required: LKR 5,000 - 10,000',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: NeumorphicButton(
                text: 'Download Application Form',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Downloading application form for $bankName...',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: NeumorphicButton(
                text: 'Continue to Appointment Booking',
                onPressed: () => context.go('/banking/final'),
                isGreen: true,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final String title;
  final bool isRequired;
  final bool isDark;

  const _DocumentItem({
    required this.title,
    required this.isRequired,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRequired
            ? AppColors.error.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isRequired
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isRequired ? Icons.check_circle : Icons.info_outline,
            color: isRequired ? AppColors.error : AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: isRequired ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          if (isRequired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Required',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BankFinalStepsScreen extends StatelessWidget {
  const BankFinalStepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bank = ModalRoute.of(context)!.settings.arguments as _BankInfo?;
    final bankName = bank?.name ?? 'Selected Bank';

    final appointmentSteps = [
      'Visit the selected branch during business hours',
      'Present all required documents to the relationship manager',
      'Complete the account opening application form',
      'Make initial deposit as per bank requirements',
      'Receive account details and welcome pack',
      'Activate online banking (if available)',
    ];

    final branches = [
      'Colombo 01 - Main Branch',
      'Colombo 03 - Liberty Plaza',
      'Colombo 05 - Nugegoda',
      'Colombo 07 - Cinnamon Gardens',
      'Colombo 10 - Maradana',
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
          onPressed: () => context.go('/applications'),
        ),
        title: Text(
          'Appointment & Final Steps',
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
                          'Ready for Appointment',
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
                    'Bank: $bankName',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Branch Selection
            Text(
              'Select Branch',
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
                  labelText: 'Choose your preferred branch',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: branches
                    .map(
                      (branch) =>
                          DropdownMenuItem(value: branch, child: Text(branch)),
                    )
                    .toList(),
                onChanged: (value) {},
              ),
            ),

            const SizedBox(height: 20),

            // Appointment Steps
            Text(
              'Appointment Process',
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

            // What to Bring
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
                    '• All required documents (originals + copies)\n'
                    '• Initial deposit amount\n'
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

            SizedBox(
              width: double.infinity,
              child: NeumorphicButton(
                text: 'Book Appointment',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Redirecting to $bankName appointment booking...',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                isGreen: true,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: NeumorphicButton(
                text: 'Download Checklist',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Downloading appointment checklist...'),
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
