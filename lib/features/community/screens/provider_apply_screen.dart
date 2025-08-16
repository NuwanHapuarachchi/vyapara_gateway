import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/supabase_service.dart';

class ProviderApplyScreen extends ConsumerStatefulWidget {
  const ProviderApplyScreen({super.key});

  @override
  ConsumerState<ProviderApplyScreen> createState() =>
      _ProviderApplyScreenState();
}

class _ProviderApplyScreenState extends ConsumerState<ProviderApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  UserRole _type = UserRole.mentor;
  final TextEditingController _specialization = TextEditingController();
  final TextEditingController _experience = TextEditingController();
  final TextEditingController _qualification = TextEditingController();
  final TextEditingController _license = TextEditingController();
  final TextEditingController _rate = TextEditingController();
  final TextEditingController _bio = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _specialization.dispose();
    _experience.dispose();
    _qualification.dispose();
    _license.dispose();
    _rate.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final ok = await SupabaseService.applyAsProvider(
      providerType: _type,
      specialization: _specialization.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      experienceYears: int.tryParse(_experience.text),
      qualification: _qualification.text.trim().isEmpty
          ? null
          : _qualification.text.trim(),
      licenseNumber: _license.text.trim().isEmpty ? null : _license.text.trim(),
      hourlyRate: double.tryParse(_rate.text),
      bio: _bio.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Application submitted. You will be verified by an admin.'
              : 'Failed to submit application',
        ),
      ),
    );
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apply as Provider',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<UserRole>(
                value: _type,
                items: const [
                  DropdownMenuItem(
                    value: UserRole.mentor,
                    child: Text('Mentor'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.lawyer,
                    child: Text('Lawyer'),
                  ),
                ],
                onChanged: (v) => setState(() => _type = v ?? UserRole.mentor),
                decoration: const InputDecoration(labelText: 'Provider Type'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _specialization,
                decoration: const InputDecoration(
                  labelText: 'Specializations (comma separated)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _experience,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Experience (years)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qualification,
                decoration: const InputDecoration(labelText: 'Qualification'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _license,
                decoration: const InputDecoration(
                  labelText: 'License Number (if applicable)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rate,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Hourly Rate (LKR)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bio,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _submitting ? 'Submitting...' : 'Submit Application',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
