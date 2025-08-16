/// User role enum
enum UserRole {
  businessOwner('business_owner'),
  lawyer('lawyer'),
  mentor('mentor'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.businessOwner,
    );
  }
}

/// User profile model matching database schema
class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? nic;
  final UserRole role;
  final bool isEmailVerified;
  final bool isNicVerified;
  final bool isPhoneVerified;
  final String? profileImageUrl;
  final String? nicDocumentUrl; // optional legacy
  final String? nicUploadedAt; // optional legacy
  final String? nicVerificationStatus; // optional legacy
  final Map<String, dynamic>? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.nic,
    this.role = UserRole.businessOwner,
    this.isEmailVerified = false,
    this.isNicVerified = false,
    this.isPhoneVerified = false,
    this.profileImageUrl,
    this.nicDocumentUrl,
    this.nicUploadedAt,
    this.nicVerificationStatus,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create UserProfile from JSON (Supabase response)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      nic: json['nic'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'business_owner'),
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isNicVerified: json['is_nic_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      profileImageUrl: json['profile_image_url'] as String?,
      nicDocumentUrl: json['nic_document_url'] as String?,
      nicUploadedAt: json['nic_uploaded_at'] as String?,
      nicVerificationStatus: json['nic_verification_status'] as String?,
      address: json['address'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert UserProfile to JSON (for database updates)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'nic': nic,
      'role': role.value,
      'is_email_verified': isEmailVerified,
      'is_nic_verified': isNicVerified,
      'is_phone_verified': isPhoneVerified,
      'profile_image_url': profileImageUrl,
      'nic_document_url': nicDocumentUrl,
      'nic_uploaded_at': nicUploadedAt,
      'nic_verification_status': nicVerificationStatus,
      'address': address,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? nic,
    UserRole? role,
    bool? isEmailVerified,
    bool? isNicVerified,
    bool? isPhoneVerified,
    String? profileImageUrl,
    String? nicDocumentUrl,
    String? nicUploadedAt,
    String? nicVerificationStatus,
    Map<String, dynamic>? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      nic: nic ?? this.nic,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isNicVerified: isNicVerified ?? this.isNicVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      nicDocumentUrl: nicDocumentUrl ?? this.nicDocumentUrl,
      nicUploadedAt: nicUploadedAt ?? this.nicUploadedAt,
      nicVerificationStatus:
          nicVerificationStatus ?? this.nicVerificationStatus,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, fullName: $fullName, '
        'phone: $phone, nic: $nic, role: ${role.value}, isNicVerified: $isNicVerified)';
  }
}

/// Authentication state
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }
