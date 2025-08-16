import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/routing/app_router.dart';

class ProvidersListScreen extends ConsumerStatefulWidget {
  final String providerKind; // 'mentor' | 'lawyer'
  const ProvidersListScreen({super.key, required this.providerKind});

  @override
  ConsumerState<ProvidersListScreen> createState() =>
      _ProvidersListScreenState();
}

class _ProvidersListScreenState extends ConsumerState<ProvidersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _availableOnly = false;
  List<Map<String, dynamic>> _providers = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final type = widget.providerKind == 'lawyer'
        ? UserRole.lawyer
        : UserRole.mentor;
    var rows = await SupabaseService.getProviders(providerType: type);
    // Fallback to user_profiles by role if providers table has no records
    if (rows.isEmpty) {
      final users = await SupabaseService.getUsersByRole(type);
      rows = users
          .map(
            (u) => {
              'id': u['id'],
              'user_id': u['id'],
              'provider_type': type.value,
              'specialization': <String>[],
              'experience_years': null,
              'qualification': null,
              'license_number': null,
              'hourly_rate': null,
              'bio': '',
              'rating': 0,
              'total_reviews': 0,
              'is_verified': true,
              'is_available': true,
              'user': {
                'full_name': u['full_name'],
                'profile_image_url': u['profile_image_url'],
              },
            },
          )
          .toList();
    }
    if (!mounted) return;
    setState(() {
      _providers = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.providerKind == 'lawyer' ? 'Lawyers' : 'Mentors';
    final list = _filtered();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return _buildProviderCard(list[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or specialization...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Available'),
            selected: _availableOnly,
            onSelected: (v) => setState(() => _availableOnly = v),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filtered() {
    final term = _searchController.text.toLowerCase();
    return _providers.where((p) {
      final user = (p['user'] as Map<String, dynamic>?) ?? const {};
      final name = (user['full_name'] as String? ?? '').toLowerCase();
      final specs = ((p['specialization'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString().toLowerCase())
          .join(' ');
      final isAvailable = p['is_available'] == true;
      if (_availableOnly && !isAvailable) return false;
      if (term.isEmpty) return true;
      return name.contains(term) || specs.contains(term);
    }).toList();
  }

  Widget _buildProviderCard(Map<String, dynamic> p) {
    final user = (p['user'] as Map<String, dynamic>?) ?? const {};
    final userId = (p['user_id'] as String?) ?? '';
    final name = (user['full_name'] as String?) ?? 'Unknown';
    final bio = (p['bio'] as String?) ?? '';
    final rating = (p['rating'] as num?)?.toDouble() ?? 0.0;
    final available = p['is_available'] == true;
    final rate = (p['hourly_rate'] as num?)?.toDouble();
    final kindLabel = widget.providerKind == 'lawyer' ? 'Lawyer' : 'Mentor';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '?')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name · $kindLabel',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(rating.toStringAsFixed(1)),
                          const SizedBox(width: 12),
                          Icon(
                            available ? Icons.circle : Icons.circle_outlined,
                            color: available ? Colors.green : Colors.grey,
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(available ? 'Available' : 'Unavailable'),
                        ],
                      ),
                    ],
                  ),
                ),
                if (rate != null)
                  Chip(label: Text('LKR ${rate.toStringAsFixed(2)}/hr')),
              ],
            ),
            const SizedBox(height: 12),
            Text(bio, style: GoogleFonts.inter(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => AppNavigation.toMentorChat(context, userId),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: available
                      ? () async {
                          final session =
                              await SupabaseService.getOrCreateDirectChatSession(
                                userId,
                                sessionTitle: '$kindLabel consultation',
                              );
                          if (!mounted) return;
                          if (session != null) {
                            AppNavigation.toMentorChat(context, userId);
                          }
                        }
                      : null,
                  icon: const Icon(Icons.schedule),
                  label: const Text('Start Session'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
