import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_registration_model.dart';
import '../../../core/services/supabase_service.dart';

// Simple notifier for business registration
class BusinessRegistrationNotifier extends Notifier<BusinessRegistration?> {
  @override
  BusinessRegistration? build() {
    return null;
  }

  void updateBusinessType(BusinessType businessType) {
    if (state == null) {
      state = BusinessRegistration(
        businessName: '',
        businessType: businessType,
        natureOfBusiness: '',
        businessAddress: const BusinessAddress(
          addressLine1: '',
          city: '',
          district: '',
          province: '',
          postalCode: '',
        ),
        owners: const [],
        requiredDocuments: businessType.requiredDocuments,
      );
    } else {
      state = state!.copyWith(
        businessType: businessType,
        requiredDocuments: businessType.requiredDocuments,
      );
    }
  }

  void updateBusinessDetails({
    required String businessName,
    String? proposedTradeName,
    required String natureOfBusiness,
    required BusinessAddress businessAddress,
  }) {
    if (state != null) {
      state = state!.copyWith(
        businessName: businessName,
        proposedTradeName: proposedTradeName,
        natureOfBusiness: natureOfBusiness,
        businessAddress: businessAddress,
      );
    }
  }

  void updateOwnersPartners({
    required List<BusinessOwner> owners,
    List<BusinessPartner>? partners,
  }) {
    if (state != null) {
      state = state!.copyWith(owners: owners, partners: partners);
    }
  }

  void updateUploadedDocuments(Map<String, String> uploadedDocuments) {
    if (state != null) {
      state = state!.copyWith(uploadedDocuments: uploadedDocuments);
    }
  }

  void clearRegistration() {
    state = null;
  }
}

final businessRegistrationProvider =
    NotifierProvider<BusinessRegistrationNotifier, BusinessRegistration?>(
      () => BusinessRegistrationNotifier(),
    );

final businessTypesProvider = FutureProvider<List<BusinessType>>((ref) async {
  final data = await SupabaseService.getBusinessTypes();
  return data
      .map(
        (json) => BusinessType(
          id: json['id'],
          type: json['type'],
          displayName: json['display_name'],
          description: json['description'],
          requiredDocuments: List<String>.from(
            json['required_documents'] ?? [],
          ),
          estimatedProcessingDays: json['estimated_processing_days'] ?? 0,
          baseFee: (json['base_fee'] ?? 0.0).toDouble(),
        ),
      )
      .toList();
});

final sriLankanProvincesProvider = Provider<List<String>>((ref) {
  return [
    'Western Province',
    'Central Province',
    'Southern Province',
    'Northern Province',
    'Eastern Province',
    'North Western Province',
    'North Central Province',
    'Uva Province',
    'Sabaragamuwa Province',
  ];
});

final sriLankanDistrictsProvider = Provider<Map<String, List<String>>>((ref) {
  return {
    'Western Province': ['Colombo', 'Gampaha', 'Kalutara'],
    'Central Province': ['Kandy', 'Matale', 'Nuwara Eliya'],
    'Southern Province': ['Galle', 'Matara', 'Hambantota'],
    'Northern Province': [
      'Jaffna',
      'Kilinochchi',
      'Mannar',
      'Mullaitivu',
      'Vavuniya',
    ],
    'Eastern Province': ['Ampara', 'Batticaloa', 'Trincomalee'],
    'North Western Province': ['Kurunegala', 'Puttalam'],
    'North Central Province': ['Anuradhapura', 'Polonnaruwa'],
    'Uva Province': ['Badulla', 'Monaragala'],
    'Sabaragamuwa Province': ['Ratnapura', 'Kegalle'],
  };
});
