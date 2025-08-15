import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';

class BankSelectionScreen extends StatelessWidget {
  const BankSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final banks = <_BankInfo>[
      _BankInfo('Commercial Bank', 'Min. deposit LKR 5,000', 'assets/banks/combank.png'),
      _BankInfo('HNB', 'Online banking, SME support', 'assets/banks/hnb.png'),
      _BankInfo('Sampath Bank', 'Min. deposit LKR 5,000', 'assets/banks/sampath.png'),
      _BankInfo('BOC', 'State-backed network', 'assets/banks/boc.png'),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Choose a Banking Partner',
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
            Text(
              'Select a bank to proceed with account opening',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: banks.length,
                itemBuilder: (context, index) {
                  final bank = banks[index];
                  return _BankCard(bank: bank, onTap: () {
                    Navigator.of(context).pushNamed('/banking/prepare', arguments: bank.name);
                  });
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
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderLight : AppColors.borderLightTheme,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                bank.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bank.features,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                ),
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
  final String features;
  final String logoPath;
  _BankInfo(this.name, this.features, this.logoPath);
}

class BankPreparationScreen extends StatelessWidget {
  const BankPreparationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bankName = ModalRoute.of(context)!.settings.arguments as String? ?? 'Selected Bank';
    final docs = [
      'Business Registration Certificate',
      'NIC copies of directors/owners',
      'Proof of business address',
      'Board resolution (if applicable)',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Your Application Toolkit', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bank: $bankName', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary)),
            const SizedBox(height: 12),
            Text('The following documents will be included in your application pack:', style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight)),
            const SizedBox(height: 8),
            ...docs.map((d) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(d, style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface))),
                  ]),
                )),
            const Spacer(),
            NeumorphicButton(
              text: 'Download Application Pack',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading pack...')));
              },
            ),
            const SizedBox(height: 12),
            NeumorphicButton(
              text: 'Continue',
              onPressed: () => Navigator.of(context).pushNamed('/banking/final', arguments: bankName),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class BankFinalStepsScreen extends StatelessWidget {
  const BankFinalStepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bankName = ModalRoute.of(context)!.settings.arguments as String? ?? 'Selected Bank';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('You\'re Ready to Visit the Bank!', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bank: $bankName', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary)),
            const SizedBox(height: 12),
            Text('Bring the following when visiting the branch:', style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight)),
            const SizedBox(height: 8),
            ...[
              'Printed application form',
              'Original NIC',
              'Initial deposit (as per bank policy)',
            ].map((d) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    const Icon(Icons.arrow_right, color: AppColors.primary, size: 20),
                    const SizedBox(width: 4),
                    Expanded(child: Text(d, style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface))),
                  ]),
                )),
            const Spacer(),
            NeumorphicButton(
              text: 'Book Appointment (Coming Soon)',
              onPressed: null,
              isGreen: true,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}



