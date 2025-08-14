import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';

/// Reserve Mentor Screen for booking mentorship sessions
class ReserveMentorScreen extends ConsumerStatefulWidget {
  const ReserveMentorScreen({super.key});

  @override
  ConsumerState<ReserveMentorScreen> createState() =>
      _ReserveMentorScreenState();
}

class _ReserveMentorScreenState extends ConsumerState<ReserveMentorScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showAvailableOnly = true;
  String _selectedExpertise = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mentors = _getFilteredMentors();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Reserve Mentor',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Filters
          _buildSearchAndFilters(),

          // Mentors List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mentors.length,
              itemBuilder: (context, index) {
                return _buildMentorCard(mentors[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search mentors by name or expertise...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() {}),
          ),

          const SizedBox(height: 16),

          // Filter Toggle Buttons
          Row(
            children: [
              Expanded(
                child: ToggleButtons(
                  isSelected: [_showAvailableOnly, !_showAvailableOnly],
                  onPressed: (index) {
                    setState(() {
                      _showAvailableOnly = index == 0;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: AppColors.textPrimary,
                  fillColor: AppColors.primary,
                  color: AppColors.textSecondary,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Available'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('All Mentors'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Expertise Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                        'All',
                        'Business Strategy',
                        'Legal',
                        'Finance',
                        'Marketing',
                        'Technology',
                      ]
                      .map(
                        (expertise) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(expertise),
                            selected: _selectedExpertise == expertise,
                            onSelected: (selected) {
                              setState(() {
                                _selectedExpertise = expertise;
                              });
                            },
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            checkmarkColor: AppColors.primary,
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorCard(MentorProfile mentor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Mentor Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    mentor.name[0],
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Mentor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mentor.name,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: mentor.isAvailable
                                  ? AppColors.success.withOpacity(0.2)
                                  : AppColors.error.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              mentor.isAvailable ? 'Available' : 'Reserved',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: mentor.isAvailable
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        mentor.expertise,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mentor.rating.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.work_outline,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mentor.experience,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (mentor.bio.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                mentor.bio,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            if (mentor.specialties.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: mentor.specialties
                    .map(
                      (specialty) => Chip(
                        label: Text(
                          specialty,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showMentorProfileBottomSheet(mentor);
                    },
                    icon: const Icon(Icons.person_outline, size: 18),
                    label: const Text('View Profile'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: mentor.isAvailable
                        ? () => _reserveMentor(mentor)
                        : null,
                    icon: Icon(
                      mentor.isAvailable ? Icons.schedule : Icons.lock,
                      size: 18,
                    ),
                    label: Text(mentor.isAvailable ? 'Reserve' : 'Reserved'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMentorProfileBottomSheet(MentorProfile mentor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? AppColors.cardDark 
          : AppColors.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mentor Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      mentor.name[0],
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mentor.name,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          mentor.expertise,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Details
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mentor.bio,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Specialties',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: mentor.specialties
                            .map(
                              (specialty) => Chip(
                                label: Text(specialty),
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: mentor.isAvailable
                      ? () {
                          Navigator.pop(context);
                          _reserveMentor(mentor);
                        }
                      : null,
                  child: Text(
                    mentor.isAvailable ? 'Reserve Session' : 'Not Available',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reserveMentor(MentorProfile mentor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? AppColors.cardDark 
          : AppColors.cardLight,
        title: Text(
          'Reserve Mentor Session',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Would you like to reserve a 1-hour session with ${mentor.name}?',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to mentor chat
              AppNavigation.toMentorChat(context, mentor.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Session reserved with ${mentor.name}!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Reserve'),
          ),
        ],
      ),
    );
  }

  List<MentorProfile> _getFilteredMentors() {
    List<MentorProfile> mentors = _getAllMentors();

    // Filter by availability
    if (_showAvailableOnly) {
      mentors = mentors.where((m) => m.isAvailable).toList();
    }

    // Filter by expertise
    if (_selectedExpertise != 'All') {
      mentors = mentors
          .where(
            (m) =>
                m.expertise.contains(_selectedExpertise) ||
                m.specialties.any((s) => s.contains(_selectedExpertise)),
          )
          .toList();
    }

    // Filter by search
    final searchTerm = _searchController.text.toLowerCase();
    if (searchTerm.isNotEmpty) {
      mentors = mentors
          .where(
            (m) =>
                m.name.toLowerCase().contains(searchTerm) ||
                m.expertise.toLowerCase().contains(searchTerm),
          )
          .toList();
    }

    return mentors;
  }

  List<MentorProfile> _getAllMentors() {
    return [
      MentorProfile(
        id: '1',
        name: 'Dr. Rajesh Kumar',
        expertise: 'Business Strategy & Legal',
        rating: 4.9,
        experience: '15+ years',
        isAvailable: true,
        bio:
            'Experienced business strategist and legal advisor with over 15 years of experience helping startups and SMEs navigate business registration and growth strategies.',
        specialties: [
          'Business Registration',
          'Legal Compliance',
          'Strategic Planning',
        ],
      ),
      MentorProfile(
        id: '2',
        name: 'Sarah Fernando',
        expertise: 'Finance & Accounting',
        rating: 4.8,
        experience: '12+ years',
        isAvailable: true,
        bio:
            'Chartered Accountant specializing in business finance, tax planning, and financial management for small and medium enterprises.',
        specialties: [
          'Tax Planning',
          'Financial Management',
          'VAT Registration',
        ],
      ),
      MentorProfile(
        id: '3',
        name: 'Michael Silva',
        expertise: 'Marketing & Sales',
        rating: 4.7,
        experience: '10+ years',
        isAvailable: false,
        bio:
            'Digital marketing expert with extensive experience in brand development, sales strategy, and customer acquisition for new businesses.',
        specialties: [
          'Digital Marketing',
          'Brand Development',
          'Sales Strategy',
        ],
      ),
    ];
  }
}

/// Mentor profile model
class MentorProfile {
  final String id;
  final String name;
  final String expertise;
  final double rating;
  final String experience;
  final bool isAvailable;
  final String bio;
  final List<String> specialties;

  MentorProfile({
    required this.id,
    required this.name,
    required this.expertise,
    required this.rating,
    required this.experience,
    required this.isAvailable,
    required this.bio,
    required this.specialties,
  });
}
