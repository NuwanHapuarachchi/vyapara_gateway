import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';
import '../models/business_registration_model.dart';
import '../providers/business_registration_provider.dart';
import '../widgets/themed_text_field.dart';

class BusinessDetailsFormScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const BusinessDetailsFormScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  ConsumerState<BusinessDetailsFormScreen> createState() =>
      _BusinessDetailsFormScreenState();
}

class _BusinessDetailsFormScreenState
    extends ConsumerState<BusinessDetailsFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _businessNameController = TextEditingController();
  final _proposedTradeNameController = TextEditingController();
  final _natureOfBusinessController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _landlineController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedProvince;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final registration = ref.read(businessRegistrationProvider);
    if (registration != null) {
      _businessNameController.text = registration.businessName;
      _proposedTradeNameController.text = registration.proposedTradeName ?? '';
      _natureOfBusinessController.text = registration.natureOfBusiness;
      _addressLine1Controller.text = registration.businessAddress.addressLine1;
      _addressLine2Controller.text =
          registration.businessAddress.addressLine2 ?? '';
      _cityController.text = registration.businessAddress.city;
      _postalCodeController.text = registration.businessAddress.postalCode;
      _landlineController.text =
          registration.businessAddress.landlinePhone ?? '';
      _mobileController.text = registration.businessAddress.mobilePhone ?? '';
      _emailController.text = registration.businessAddress.email ?? '';
      _selectedProvince = registration.businessAddress.province;
      _selectedDistrict = registration.businessAddress.district;
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _proposedTradeNameController.dispose();
    _natureOfBusinessController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _landlineController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (_formKey.currentState!.validate()) {
      final businessAddress = BusinessAddress(
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text.isEmpty
            ? null
            : _addressLine2Controller.text,
        city: _cityController.text,
        district: _selectedDistrict!,
        province: _selectedProvince!,
        postalCode: _postalCodeController.text,
        landlinePhone: _landlineController.text.isEmpty
            ? null
            : _landlineController.text,
        mobilePhone: _mobileController.text.isEmpty
            ? null
            : _mobileController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
      );

      ref
          .read(businessRegistrationProvider.notifier)
          .updateBusinessDetails(
            businessName: _businessNameController.text,
            proposedTradeName: _proposedTradeNameController.text.isEmpty
                ? null
                : _proposedTradeNameController.text,
            natureOfBusiness: _natureOfBusinessController.text,
            businessAddress: businessAddress,
          );

      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provinces = ref.watch(sriLankanProvincesProvider);
    final districts = ref.watch(sriLankanDistrictsProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business Information Section
                    _buildSectionHeader('Business Information'),
                    const SizedBox(height: 16),

                    ThemedTextField(
                      controller: _businessNameController,
                      labelText: 'Business Name *',
                      hintText: 'Enter your business name',
                      isRequired: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Business name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    ThemedTextField(
                      controller: _proposedTradeNameController,
                      labelText: 'Proposed Trade Name (Optional)',
                      hintText: 'Enter proposed trade name',
                    ),

                    const SizedBox(height: 16),

                    ThemedTextField(
                      controller: _natureOfBusinessController,
                      labelText: 'Nature of Business *',
                      hintText: 'Describe your business activities',
                      maxLines: 3,
                      isRequired: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Nature of business is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Business Address Section
                    _buildSectionHeader('Business Address'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _addressLine1Controller,
                      label: 'Address Line 1 *',
                      hint: 'Street address, building number',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Address line 1 is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _addressLine2Controller,
                      label: 'Address Line 2 (Optional)',
                      hint: 'Apartment, suite, unit, floor',
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'City *',
                            hint: 'Enter city',
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'City is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _postalCodeController,
                            label: 'Postal Code *',
                            hint: 'e.g. 10400',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    ThemedDropdownField(
                      labelText: 'Province *',
                      value: _selectedProvince,
                      items: provinces,
                      onChanged: (value) {
                        setState(() {
                          _selectedProvince = value;
                          _selectedDistrict = null; // Reset district
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Province is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    ThemedDropdownField(
                      labelText: 'District *',
                      value: _selectedDistrict,
                      items: _selectedProvince != null
                          ? districts[_selectedProvince!] ?? []
                          : [],
                      onChanged: (value) {
                        setState(() {
                          _selectedDistrict = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'District is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Contact Information Section
                    _buildSectionHeader('Contact Information'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _landlineController,
                      label: 'Landline Phone (Optional)',
                      hint: '011-2345678',
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _mobileController,
                      label: 'Mobile Phone (Optional)',
                      hint: '077-1234567',
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _emailController,
                      label: 'Email (Optional)',
                      hint: 'business@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isNotEmpty == true &&
                            !RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value!)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
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
