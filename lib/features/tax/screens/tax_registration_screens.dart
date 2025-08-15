import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';

class TaxBriefingScreen extends StatelessWidget {
  const TaxBriefingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Understanding Your Tax Identity', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TIN (Taxpayer Identification Number)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('A unique identifier issued by IRD to track your tax obligations. You must obtain a TIN before engaging in taxable activities.', style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight)),
            const SizedBox(height: 16),
            Text('VAT (Value Added Tax)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Businesses crossing the annual supply threshold are required to register for VAT. We will guide you through eligibility and application.', style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight)),
            const Spacer(),
            NeumorphicButton(text: 'Continue', onPressed: () => Navigator.of(context).pushNamed('/tax/form')),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class TaxRegistrationFormScreen extends StatelessWidget {
  const TaxRegistrationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Tax Registration Form', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Placeholder fields representing prefilled form
            _FormRow(label: 'Business Name', value: 'Prefilled from profile'),
            _FormRow(label: 'BR Number', value: 'Prefilled from documents'),
            _FormRow(label: 'Registered Address', value: 'Prefilled'),
            _FormRow(label: 'Directors', value: 'Prefilled'),
            const Spacer(),
            NeumorphicButton(text: 'Continue', onPressed: () => Navigator.of(context).pushNamed('/tax/review')),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class TaxSubmitScreen extends StatelessWidget {
  const TaxSubmitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Submit to Inland Revenue', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Review your details and attached documents before submission.', style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight)),
            const SizedBox(height: 12),
            Row(children: const [Icon(Icons.description_outlined, color: AppColors.primary), SizedBox(width: 8), Text('Business Registration Certificate')]),
            const SizedBox(height: 6),
            Row(children: const [Icon(Icons.description_outlined, color: AppColors.primary), SizedBox(width: 8), Text('NIC Copy')]),
            const Spacer(),
            Row(children: [
              Expanded(child: NeumorphicButton(text: 'Back', onPressed: () => Navigator.of(context).pop(), isGreen: false)),
              const SizedBox(width: 12),
              Expanded(child: NeumorphicButton(text: 'Submit Application', onPressed: () => Navigator.of(context).pop())),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  final String label;
  final String value;
  const _FormRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderLight : AppColors.borderLightTheme),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight))),
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}



