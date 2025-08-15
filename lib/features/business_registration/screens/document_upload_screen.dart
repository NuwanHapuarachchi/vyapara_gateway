import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';

import '../models/business_registration_model.dart';
import '../providers/business_registration_provider.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const DocumentUploadScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  ConsumerState<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  final Map<String, String> _uploadedDocuments = {};
  final Map<String, bool> _uploadingStatus = {};

  // Document descriptions for Sri Lankan business registration
  final Map<String, String> _documentDescriptions = {
    // Sole Proprietorship & Partnership
    'application_form_divisional_secretariat':
        'Application form from the Divisional Secretariat Office',
    'grama_niladhari_certified_report':
        'Certified report from the Grama Niladharee regarding the business name',
    'nic_copy': 'Copy of National Identity Card (NIC)',
    'business_premises_proof':
        'Proof of business premises (deed of land if owned, or lease agreement)',
    'trade_permit_municipal':
        'Trade permit from the Municipal or Divisional Council',

    // Partnership specific
    'partners_nic_copies': 'Copies of National Identity Cards for all partners',
    'partnership_agreement': 'Copy of the business partnership agreement',

    // Private/Public Limited Company
    'form_1_company_registration':
        'Form 1: Application for the Registration of a Company',
    'form_18_director_consent':
        'Form 18: Consent and Certificate of the Director(s)',
    'form_19_secretary_consent':
        'Form 19: Consent and Certificate of the Secretary',
    'articles_of_association':
        'Articles of Association (model articles or custom)',
    'directors_shareholders_id_copies':
        'Copies of valid ID or passport for directors and shareholders',
  };

  @override
  void initState() {
    super.initState();
    _loadExistingDocuments();
  }

  void _loadExistingDocuments() {
    final registration = ref.read(businessRegistrationProvider);
    if (registration?.uploadedDocuments != null) {
      _uploadedDocuments.addAll(registration!.uploadedDocuments!);
    }
  }

  Future<void> _uploadDocument(String documentType) async {
    try {
      setState(() {
        _uploadingStatus[documentType] = true;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;

        // Upload to Supabase storage
        final fileName =
            '${documentType}_${DateTime.now().millisecondsSinceEpoch}_${file.name}';

        final documentUrl = await SupabaseService.uploadDocumentBytes(
          data: file.bytes!,
          fileName: fileName,
          contentType: _getContentType(file.extension),
        );

        if (documentUrl != null) {
          if (mounted) {
            setState(() {
              _uploadedDocuments[documentType] = documentUrl;
            });
          }
        } else {
          throw Exception('Failed to upload document to storage');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${file.name} uploaded successfully to Supabase',
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Upload failed: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploadingStatus[documentType] = false;
        });
      }
    }
  }

  Future<void> _removeDocument(String documentType) async {
    try {
      final documentUrl = _uploadedDocuments[documentType];
      if (documentUrl != null) {
        // Extract file path from URL for deletion
        final uri = Uri.parse(documentUrl);
        final pathSegments = uri.pathSegments;

        // Find the path after 'object/public/business-documents/'
        final bucketIndex = pathSegments.indexOf('business-documents');
        if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
          final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

          // Delete from Supabase storage
          final success = await SupabaseService.deleteDocument(filePath);

          if (success) {
            if (mounted) {
              setState(() {
                _uploadedDocuments.remove(documentType);
              });
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Document deleted successfully from cloud storage',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else {
            throw Exception('Failed to delete document from storage');
          }
        } else {
          throw Exception('Invalid document URL format');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Delete failed: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }

      // Still remove from local state even if cloud deletion failed
      if (mounted) {
        setState(() {
          _uploadedDocuments.remove(documentType);
        });
      }
    }
  }

  void _saveAndContinue() {
    final registration = ref.read(businessRegistrationProvider);
    final requiredDocs = registration?.businessType.requiredDocuments ?? [];

    // Check if all required documents are uploaded
    final missingDocs = requiredDocs
        .where((doc) => !_uploadedDocuments.containsKey(doc))
        .toList();

    if (missingDocs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please upload all required documents. Missing: ${missingDocs.length} document(s)',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Update registration with uploaded documents
    if (registration != null) {
      ref
          .read(businessRegistrationProvider.notifier)
          .updateUploadedDocuments(_uploadedDocuments);
    }

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final registration = ref.watch(businessRegistrationProvider);
    final requiredDocuments =
        registration?.businessType.requiredDocuments ?? [];
    final businessType = registration?.businessType;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business type info
                  if (businessType != null)
                    _buildBusinessTypeInfo(businessType),

                  const SizedBox(height: 24),

                  // Required documents
                  Text(
                    'Required Documents',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please upload all required documents in PDF, JPG, or PNG format (max 5MB each)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Document list
                  ...requiredDocuments.map((documentType) {
                    return _buildDocumentCard(documentType);
                  }),

                  // Progress indicator
                  _buildProgressIndicator(requiredDocuments),
                ],
              ),
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildBusinessTypeInfo(BusinessType businessType) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.business,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessType.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${businessType.requiredDocuments.length} documents required',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getContentType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  Widget _buildDocumentCard(String documentType) {
    final isUploaded = _uploadedDocuments.containsKey(documentType);
    final isUploading = _uploadingStatus[documentType] == true;
    final description = _documentDescriptions[documentType] ?? documentType;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded
              ? AppColors.success.withOpacity(0.5)
              : AppColors.borderLight,
          width: isUploaded ? 2 : 1,
        ),
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
                  color: isUploaded
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.textSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle : Icons.description,
                  color: isUploaded
                      ? AppColors.success
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDocumentName(documentType),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUploading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                )
              else if (isUploaded)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _removeDocument(documentType),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      tooltip: 'Remove document',
                    ),
                    const Icon(Icons.check_circle, color: AppColors.success),
                  ],
                )
              else
                IconButton(
                  onPressed: () => _uploadDocument(documentType),
                  icon: const Icon(Icons.upload_file, color: AppColors.primary),
                  tooltip: 'Upload document',
                ),
            ],
          ),

          if (!isUploaded && !isUploading) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _uploadDocument(documentType),
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Upload Document'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],

          if (isUploaded) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Uploaded successfully',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(List<String> requiredDocuments) {
    final uploadedCount = requiredDocuments
        .where((doc) => _uploadedDocuments.containsKey(doc))
        .length;

    final progress = requiredDocuments.isEmpty
        ? 1.0
        : uploadedCount / requiredDocuments.length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upload Progress',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$uploadedCount/${requiredDocuments.length} documents',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation(
              progress == 1.0 ? AppColors.success : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDocumentName(String documentType) {
    return documentType
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildNavigationButtons() {
    final registration = ref.watch(businessRegistrationProvider);
    final requiredDocs = registration?.businessType.requiredDocuments ?? [];
    final allUploaded = requiredDocs.every(
      (doc) => _uploadedDocuments.containsKey(doc),
    );

    return Row(
      children: [
        Expanded(
          child: NeumorphicButton(
            text: 'Previous',
            onPressed: widget.onPrevious,
            isGreen: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: NeumorphicButton(
            text: 'Continue',
            onPressed: allUploaded ? _saveAndContinue : null,
            isGreen: allUploaded,
          ),
        ),
      ],
    );
  }
}
