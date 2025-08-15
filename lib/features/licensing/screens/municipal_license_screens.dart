import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';

class LocationConfirmScreen extends StatelessWidget {
  const LocationConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String council = 'Colombo Municipal Council';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Confirm Your Business Location', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detected local authority:', style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight)),
            const SizedBox(height: 8),
            Text(council, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            const Spacer(),
            NeumorphicButton(text: 'Confirm & Continue', onPressed: () => Navigator.of(context).pushNamed('/license/requirements', arguments: council)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class RequirementsChecklistScreen extends StatelessWidget {
  const RequirementsChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final council = ModalRoute.of(context)!.settings.arguments as String? ?? 'Local Council';
    final requirements = [
      'Business Registration Certificate',
      'PHI Report (for food-related businesses)',
      'Tax clearance certificate',
      'Premises inspection report',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('License Requirements for $council', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...requirements.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    const Icon(Icons.check_box_outlined, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(r, style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface))),
                  ]),
                )),
            const Spacer(),
            NeumorphicButton(text: 'Continue', onPressed: () => Navigator.of(context).pushNamed('/license/form', arguments: council)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class TradeLicenseFormScreen extends StatelessWidget {
  const TradeLicenseFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final council = ModalRoute.of(context)!.settings.arguments as String? ?? 'Local Council';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Trade License Application', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _FormFieldTile(label: 'Business Category', value: 'Prefilled'),
            _FormFieldTile(label: 'Premises Address', value: 'Prefilled'),
            _FormFieldTile(label: 'Number of Employees', value: 'Prefilled'),
            const Spacer(),
            NeumorphicButton(text: 'Continue', onPressed: () => Navigator.of(context).pushNamed('/license/payment', arguments: council)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class LicensePaymentScreen extends StatelessWidget {
  const LicensePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final council = ModalRoute.of(context)!.settings.arguments as String? ?? 'Local Council';
    final fee = 2500.00;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Pay Your License Fee', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Council: $council', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary)),
            const SizedBox(height: 10),
            Text('Calculated Trade License Fee: LKR ${fee.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
            const Spacer(),
            NeumorphicButton(text: 'Pay & Submit', onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FormFieldTile extends StatelessWidget {
  final String label;
  final String value;
  const _FormFieldTile({required this.label, required this.value});

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



