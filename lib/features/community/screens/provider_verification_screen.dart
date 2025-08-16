import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/supabase_service.dart';

class ProviderVerificationScreen extends ConsumerStatefulWidget {
  const ProviderVerificationScreen({super.key});

  @override
  ConsumerState<ProviderVerificationScreen> createState() =>
      _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState
    extends ConsumerState<ProviderVerificationScreen> {
  List<Map<String, dynamic>> _pending = const [];
  bool _loading = true;
  UserRole _filter = UserRole.mentor;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await SupabaseService.getProviders(
      providerType: _filter,
      onlyVerified: false,
    );
    if (!mounted) return;
    setState(() {
      _pending = rows.where((p) => p['is_verified'] != true).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verify Providers',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          DropdownButton<UserRole>(
            value: _filter,
            onChanged: (v) => setState(() {
              _filter = v ?? UserRole.mentor;
              _load();
            }),
            items: const [
              DropdownMenuItem(value: UserRole.mentor, child: Text('Mentors')),
              DropdownMenuItem(value: UserRole.lawyer, child: Text('Lawyers')),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pending.length,
              itemBuilder: (context, index) {
                final p = _pending[index];
                final user = (p['user'] as Map<String, dynamic>?) ?? const {};
                return Card(
                  child: ListTile(
                    title: Text(user['full_name'] ?? 'Unknown'),
                    subtitle: Text(
                      (p['specialization'] as List<dynamic>? ?? [])
                          .map((e) => e.toString())
                          .join(', '),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () async {
                            final ok = await SupabaseService.verifyProvider(
                              providerId: p['id'] as String,
                              isVerified: true,
                            );
                            if (!mounted) return;
                            if (ok) _load();
                          },
                          child: const Text('Approve'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            final ok = await SupabaseService.verifyProvider(
                              providerId: p['id'] as String,
                              isVerified: false,
                              updateUserRole: false,
                            );
                            if (!mounted) return;
                            if (ok) _load();
                          },
                          child: const Text('Reject'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
