import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';
import '../../../core/services/supabase_service.dart';
import '../models/business_registration_model.dart';
import '../providers/business_registration_provider.dart';

class OwnersPartnersFormScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const OwnersPartnersFormScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  ConsumerState<OwnersPartnersFormScreen> createState() =>
      _OwnersPartnersFormScreenState();
}

class _OwnersPartnersFormScreenState
    extends ConsumerState<OwnersPartnersFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<BusinessOwner> _owners = [];
  final List<BusinessPartner> _partners = [];

  // Current owner/partner form controllers
  final _fullNameController = TextEditingController();
  final _nicController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController();
  final _percentageController = TextEditingController();

  bool _isAddingOwner = true;
  bool _isValidatingNic = false;
  Map<String, dynamic>? _nicValidationData;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final registration = ref.read(businessRegistrationProvider);
    if (registration != null) {
      _owners.addAll(registration.owners);
      _partners.addAll(registration.partners ?? []);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  Future<void> _validateNic() async {
    if (_nicController.text.isEmpty) return;

    setState(() {
      _isValidatingNic = true;
      _nicValidationData = null;
    });

    try {
      final validationData = await SupabaseService.validateNic(
        _nicController.text,
      );

      setState(() {
        _nicValidationData = validationData;
        if (validationData != null) {
          _fullNameController.text = validationData['full_name'] ?? '';
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error validating NIC: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isValidatingNic = false;
      });
    }
  }

  void _addOwner() {
    if (_formKey.currentState!.validate() && _nicValidationData != null) {
      final owner = BusinessOwner(
        fullName: _fullNameController.text,
        nicNumber: _nicController.text,
        address: _addressController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
        dateOfBirth:
            DateTime.tryParse(_nicValidationData!['date_of_birth'] ?? '') ??
            DateTime.now(),
        nationality: 'Sri Lankan',
        isPrimaryOwner: _owners.isEmpty,
      );

      setState(() {
        _owners.add(owner);
        _clearForm();
      });
    }
  }

  void _addPartner() {
    if (_formKey.currentState!.validate() && _nicValidationData != null) {
      final partner = BusinessPartner(
        fullName: _fullNameController.text,
        nicNumber: _nicController.text,
        address: _addressController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
        dateOfBirth:
            DateTime.tryParse(_nicValidationData!['date_of_birth'] ?? '') ??
            DateTime.now(),
        nationality: 'Sri Lankan',
        partnershipPercentage:
            double.tryParse(_percentageController.text) ?? 0.0,
        role: _roleController.text.isEmpty ? 'Partner' : _roleController.text,
      );

      setState(() {
        _partners.add(partner);
        _clearForm();
      });
    }
  }

  void _clearForm() {
    _fullNameController.clear();
    _nicController.clear();
    _addressController.clear();
    _phoneController.clear();
    _emailController.clear();
    _roleController.clear();
    _percentageController.clear();
    _nicValidationData = null;
  }

  void _saveAndContinue() {
    if (_owners.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one owner'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Update the registration state
    final registration = ref.read(businessRegistrationProvider);
    if (registration != null) {
      ref
          .read(businessRegistrationProvider.notifier)
          .updateOwnersPartners(
            owners: _owners,
            partners: _partners.isNotEmpty ? _partners : null,
          );
    }

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final registration = ref.watch(businessRegistrationProvider);
    final isPartnership = registration?.businessType.type == 'partnership';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toggle between Owner and Partner
                  if (isPartnership) _buildToggleSection(),

                  const SizedBox(height: 20),

                  // Current owners/partners list
                  if (_owners.isNotEmpty) _buildOwnersList(),
                  if (_partners.isNotEmpty) _buildPartnersList(),

                  const SizedBox(height: 20),

                  // Add new form
                  _buildAddForm(),
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

  Widget _buildToggleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAddingOwner = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isAddingOwner
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Add Owner',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isAddingOwner
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAddingOwner = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isAddingOwner
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Add Partner',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: !_isAddingOwner
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Owners (${_owners.length})',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._owners.asMap().entries.map((entry) {
          final index = entry.key;
          final owner = entry.value;
          return _buildPersonCard(
            name: owner.fullName,
            nic: owner.nicNumber,
            phone: owner.phoneNumber,
            isPrimary: owner.isPrimaryOwner,
            onRemove: () => setState(() => _owners.removeAt(index)),
          );
        }),
      ],
    );
  }

  Widget _buildPartnersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Partners (${_partners.length})',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._partners.asMap().entries.map((entry) {
          final index = entry.key;
          final partner = entry.value;
          return _buildPersonCard(
            name: partner.fullName,
            nic: partner.nicNumber,
            phone: partner.phoneNumber,
            role: partner.role,
            percentage: partner.partnershipPercentage,
            onRemove: () => setState(() => _partners.removeAt(index)),
          );
        }),
      ],
    );
  }

  Widget _buildPersonCard({
    required String name,
    required String nic,
    required String phone,
    bool isPrimary = false,
    String? role,
    double? percentage,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary
            ? Border.all(color: AppColors.primary, width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              isPrimary ? Icons.star : Icons.person,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Primary',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'NIC: $nic',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Phone: $phone',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (role != null) ...[
                  Text(
                    'Role: $role',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (percentage != null) ...[
                  Text(
                    'Partnership: ${percentage.toStringAsFixed(1)}%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildAddForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isAddingOwner ? 'Add New Owner' : 'Add New Partner',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // NIC Field with validation
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _nicController,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'NIC Number *',
                    labelStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    hintText: 'e.g. 123456789V',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.cardDark 
                        : const Color(0xFFF4F4F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'NIC is required';
                    }
                    if (_nicValidationData == null) {
                      return 'Please validate NIC';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeumorphicButton(
                  text: _isValidatingNic ? 'Validating...' : 'Validate',
                  onPressed: _isValidatingNic ? null : _validateNic,
                  isGreen: _nicValidationData != null,
                ),
              ),
            ],
          ),

          if (_nicValidationData != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'NIC Validated: ${_nicValidationData!['full_name']}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Full Name (auto-filled from NIC validation)
          TextFormField(
            controller: _fullNameController,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'Full Name *',
              labelStyle: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.cardDark 
                  : const Color(0xFFF4F4F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Full name is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Address
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Address *',
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.cardDark 
                  : const Color(0xFFF4F4F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Address is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Phone and Email
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: '077-1234567',
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.cardDark 
                        : const Color(0xFFF4F4F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Phone is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.cardDark 
                        : const Color(0xFFF4F4F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Email is required';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value!)) {
                      return 'Enter valid email';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          // Partner-specific fields
          if (!_isAddingOwner) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _roleController,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      hintText: 'e.g. Managing Partner',
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.cardDark 
                        : const Color(0xFFF4F4F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _percentageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Partnership %',
                      hintText: 'e.g. 25.0',
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.cardDark 
                        : const Color(0xFFF4F4F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                    validator: (value) {
                      if (!_isAddingOwner && (value?.isEmpty ?? true)) {
                        return 'Percentage required';
                      }
                      if (value?.isNotEmpty == true) {
                        final percentage = double.tryParse(value!);
                        if (percentage == null ||
                            percentage < 0 ||
                            percentage > 100) {
                          return 'Enter valid percentage';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Add button
          SizedBox(
            width: double.infinity,
            child: NeumorphicButton(
              text: _isAddingOwner ? 'Add Owner' : 'Add Partner',
              onPressed: _isAddingOwner ? _addOwner : _addPartner,
              isGreen: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
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
            onPressed: _saveAndContinue,
            isGreen: true,
          ),
        ),
      ],
    );
  }
}
