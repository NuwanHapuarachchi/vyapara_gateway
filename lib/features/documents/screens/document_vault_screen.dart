import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/config/supabase_config.dart';

class DocumentVaultScreen extends ConsumerStatefulWidget {
  const DocumentVaultScreen({super.key});

  @override
  ConsumerState<DocumentVaultScreen> createState() =>
      _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends ConsumerState<DocumentVaultScreen> {
  late Future<void> _load;
  List<dynamic> _files = const [];
  bool _uploading = false;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Registration',
    'Tax',
    'Legal',
    'Banking',
    'Certificates',
    'Other',
  ];

  final Map<String, IconData> _categoryIcons = {
    'Registration': Icons.business,
    'Tax': Icons.receipt_long,
    'Legal': Icons.gavel,
    'Banking': Icons.account_balance,
    'Certificates': Icons.verified,
    'Other': Icons.folder,
  };

  @override
  void initState() {
    super.initState();
    _load = _refresh();
  }

  Future<void> _refresh() async {
    try {
      final files = await SupabaseService.listUserDocuments();
      if (mounted) {
        setState(() => _files = files);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading files: $e')));
      }
    }
  }

  Future<void> _pickAndUpload() async {
    if (_uploading) return;

    setState(() => _uploading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result?.files.single != null) {
        final file = result!.files.single;
        final Uint8List? data = file.bytes;
        if (data == null) throw 'No file data';

        final url = await SupabaseService.uploadDocumentBytes(
          data: data,
          fileName: file.name,
          contentType: 'application/octet-stream',
        );

        if (url != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text('Document uploaded successfully'),
                ],
              ),
              backgroundColor: Colors.green.withOpacity(0.1),
            ),
          );
          await _refresh();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text('Upload failed: $e'),
              ],
            ),
            backgroundColor: Colors.red.withOpacity(0.1),
          ),
        );
      }
    } finally {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Document Vault',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.folder, color: AppColors.primary),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            onPressed: _uploading ? null : _pickAndUpload,
            icon: _uploading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(Icons.add, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Categories Filter
          _buildCategoriesFilter(),

          // Documents List
          Expanded(
            child: FutureBuilder<void>(
              future: _load,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredFiles = _selectedCategory == 'All'
                    ? _files
                    : _files
                          .where(
                            (f) =>
                                _getFileCategory(f.name ?? '') ==
                                _selectedCategory,
                          )
                          .toList();

                if (filteredFiles.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredFiles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final file = filteredFiles[index];
                      return _buildFileCard(file);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.cardDark 
                  : AppColors.cardLight,
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.folder_open,
              size: 60,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedCategory == 'All'
                ? 'No documents uploaded'
                : 'No $_selectedCategory documents',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to upload your first document',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _uploading ? null : _pickAndUpload,
            icon: _uploading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.upload_file),
            label: Text(_uploading ? 'Uploading...' : 'Upload Document'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(dynamic file) {
    final String name = file.name ?? 'Untitled Document';
    final String category = _getFileCategory(name);
    final IconData categoryIcon = _categoryIcons[category] ?? Icons.description;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          // File Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              categoryIcon,
              color: _getCategoryColor(category),
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getCategoryColor(category),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getFileExtension(name).toUpperCase(),
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

          // Action Menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
            color: AppColors.backgroundLight,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(
                      Icons.download,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Download',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'delete') {
                _showDeleteConfirmation(file);
              } else if (value == 'download') {
                // Handle download functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Download functionality coming soon'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(dynamic file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.cardDark 
            : AppColors.cardLight,
        title: Text(
          'Delete Document',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${file.name ?? 'this document'}"? This action cannot be undone.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await SupabaseService.deleteDocument(
                '${SupabaseConfig.userId}/${file.name ?? ''}',
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Document deleted successfully'),
                      ],
                    ),
                  ),
                );
                await _refresh();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getFileCategory(String fileName) {
    final name = fileName.toLowerCase();
    if (name.contains('registration') || name.contains('license')) {
      return 'Registration';
    }
    if (name.contains('tax') || name.contains('vat')) return 'Tax';
    if (name.contains('legal') || name.contains('contract')) return 'Legal';
    if (name.contains('bank') || name.contains('statement')) return 'Banking';
    if (name.contains('certificate') || name.contains('cert')) {
      return 'Certificates';
    }
    return 'Other';
  }

  String _getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last : 'file';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Registration':
        return Colors.blue;
      case 'Tax':
        return Colors.orange;
      case 'Legal':
        return Colors.red;
      case 'Banking':
        return Colors.green;
      case 'Certificates':
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }
}
