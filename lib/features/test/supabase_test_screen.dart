import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../core/config/supabase_config.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

/// Test screen to verify Supabase connection and functionality
class SupabaseTestScreen extends ConsumerStatefulWidget {
  const SupabaseTestScreen({super.key});

  @override
  ConsumerState<SupabaseTestScreen> createState() => _SupabaseTestScreenState();
}

class _SupabaseTestScreenState extends ConsumerState<SupabaseTestScreen> {
  String _connectionStatus = 'Not tested';
  bool _isLoading = false;
  List<Map<String, dynamic>> _businessTypes = [];
  String _nicTestResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Supabase Connection Test'),
        backgroundColor: AppColors.backgroundDark,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Status
              NeumorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Database Connection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Status: $_connectionStatus',
                      style: TextStyle(
                        color: _connectionStatus == 'Connected'
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    NeumorphicButton(
                      text: 'Test Connection',
                      isLoading: _isLoading,
                      onPressed: _testConnection,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Current User Info
              NeumorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Authentication Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Authenticated: ${SupabaseConfig.isAuthenticated}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    if (SupabaseConfig.currentUser != null) ...[
                      Text(
                        'User ID: ${SupabaseConfig.userId}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        'Email: ${SupabaseConfig.userEmail}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Business Types
              NeumorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Business Types',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        NeumorphicButton(
                          text: 'Load Types',
                          isGreen: false,
                          onPressed: _loadBusinessTypes,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_businessTypes.isNotEmpty) ...[
                      const Text(
                        'Available Types:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ..._businessTypes
                          .map(
                            (type) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '• ${type['display_name']} (${type['type']})',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ] else
                      const Text(
                        'No business types loaded',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // NIC Validation Test
              NeumorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NIC Validation Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: NeumorphicButton(
                            text: 'Test Valid NIC',
                            isGreen: false,
                            onPressed: () => _testNicValidation('200015501234'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: NeumorphicButton(
                            text: 'Test Invalid NIC',
                            isGreen: false,
                            onPressed: () => _testNicValidation('123456789X'),
                          ),
                        ),
                      ],
                    ),
                    if (_nicTestResult.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Result: $_nicTestResult',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing...';
    });

    try {
      final isConnected = await SupabaseService.testConnection();
      setState(() {
        _connectionStatus = isConnected ? 'Connected' : 'Failed';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBusinessTypes() async {
    try {
      final types = await SupabaseService.getBusinessTypes();
      setState(() {
        _businessTypes = types;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load business types: $e')),
      );
    }
  }

  Future<void> _testNicValidation(String nic) async {
    try {
      final result = await SupabaseService.validateNic(nic);
      setState(() {
        if (result != null) {
          _nicTestResult =
              'Valid - ${result['full_name']} (${result['district']})';
        } else {
          _nicTestResult = 'Invalid or not found';
        }
      });
    } catch (e) {
      setState(() {
        _nicTestResult = 'Error: $e';
      });
    }
  }
}
