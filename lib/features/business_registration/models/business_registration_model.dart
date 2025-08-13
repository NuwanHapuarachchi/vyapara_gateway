// Simple business registration models without freezed for now

class BusinessRegistration {
  final String? id;
  final String businessName;
  final BusinessType businessType;
  final String? proposedTradeName;
  final String natureOfBusiness;
  final BusinessAddress businessAddress;
  final List<BusinessOwner> owners;
  final List<BusinessPartner>? partners;
  final List<String> requiredDocuments;
  final Map<String, String>? uploadedDocuments;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BusinessRegistration({
    this.id,
    required this.businessName,
    required this.businessType,
    this.proposedTradeName,
    required this.natureOfBusiness,
    required this.businessAddress,
    required this.owners,
    this.partners,
    required this.requiredDocuments,
    this.uploadedDocuments,
    this.status = 'draft',
    this.createdAt,
    this.updatedAt,
  });

  BusinessRegistration copyWith({
    String? id,
    String? businessName,
    BusinessType? businessType,
    String? proposedTradeName,
    String? natureOfBusiness,
    BusinessAddress? businessAddress,
    List<BusinessOwner>? owners,
    List<BusinessPartner>? partners,
    List<String>? requiredDocuments,
    Map<String, String>? uploadedDocuments,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessRegistration(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      proposedTradeName: proposedTradeName ?? this.proposedTradeName,
      natureOfBusiness: natureOfBusiness ?? this.natureOfBusiness,
      businessAddress: businessAddress ?? this.businessAddress,
      owners: owners ?? this.owners,
      partners: partners ?? this.partners,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusinessType {
  final String id;
  final String type;
  final String displayName;
  final String description;
  final List<String> requiredDocuments;
  final int estimatedProcessingDays;
  final double baseFee;

  const BusinessType({
    required this.id,
    required this.type,
    required this.displayName,
    required this.description,
    required this.requiredDocuments,
    required this.estimatedProcessingDays,
    required this.baseFee,
  });
}

class BusinessAddress {
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String district;
  final String province;
  final String postalCode;
  final String? landlinePhone;
  final String? mobilePhone;
  final String? email;

  const BusinessAddress({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.district,
    required this.province,
    required this.postalCode,
    this.landlinePhone,
    this.mobilePhone,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'district': district,
      'province': province,
      'postal_code': postalCode,
      'landline_phone': landlinePhone,
      'mobile_phone': mobilePhone,
      'email': email,
    };
  }
}

class BusinessOwner {
  final String fullName;
  final String nicNumber;
  final String address;
  final String phoneNumber;
  final String email;
  final DateTime dateOfBirth;
  final String nationality;
  final bool isPrimaryOwner;

  const BusinessOwner({
    required this.fullName,
    required this.nicNumber,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.dateOfBirth,
    required this.nationality,
    this.isPrimaryOwner = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'nic_number': nicNumber,
      'address': address,
      'phone_number': phoneNumber,
      'email': email,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'nationality': nationality,
      'is_primary_owner': isPrimaryOwner,
    };
  }
}

class BusinessPartner {
  final String fullName;
  final String nicNumber;
  final String address;
  final String phoneNumber;
  final String email;
  final DateTime dateOfBirth;
  final String nationality;
  final double partnershipPercentage;
  final String role;

  const BusinessPartner({
    required this.fullName,
    required this.nicNumber,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.dateOfBirth,
    required this.nationality,
    required this.partnershipPercentage,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'nic_number': nicNumber,
      'address': address,
      'phone_number': phoneNumber,
      'email': email,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'nationality': nationality,
      'partnership_percentage': partnershipPercentage,
      'role': role,
    };
  }
}

// Enums for business registration
enum BusinessRegistrationStep {
  businessType,
  businessDetails,
  ownersPartners,
  documentUpload,
  reviewSubmit,
}

enum RegistrationStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected,
  requiresChanges,
}

// Helper extensions
extension BusinessRegistrationStepExtension on BusinessRegistrationStep {
  String get title {
    switch (this) {
      case BusinessRegistrationStep.businessType:
        return 'Business Type';
      case BusinessRegistrationStep.businessDetails:
        return 'Business Details';
      case BusinessRegistrationStep.ownersPartners:
        return 'Owners & Partners';
      case BusinessRegistrationStep.documentUpload:
        return 'Document Upload';
      case BusinessRegistrationStep.reviewSubmit:
        return 'Review & Submit';
    }
  }

  String get description {
    switch (this) {
      case BusinessRegistrationStep.businessType:
        return 'Select your business structure';
      case BusinessRegistrationStep.businessDetails:
        return 'Provide business information';
      case BusinessRegistrationStep.ownersPartners:
        return 'Add owner and partner details';
      case BusinessRegistrationStep.documentUpload:
        return 'Upload required documents';
      case BusinessRegistrationStep.reviewSubmit:
        return 'Review and submit application';
    }
  }

  int get stepNumber => index + 1;
}
