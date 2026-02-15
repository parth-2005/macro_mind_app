import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:macro_mind_app/core/services/auth_service.dart';
import 'package:macro_mind_app/features/auth/login_screen.dart';
import 'package:macro_mind_app/features/cards/cards.screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();
  final _authService = AuthService();

  // Step 1: Identity
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final List<String> _availablePreferences = [
    'AI',
    'Economics',
    'Trading',
    'Technology',
    'Science',
    'Philosophy',
    'Politics',
    'History',
  ];
  final Set<String> _selectedPreferences = {};

  // Step 2: Base
  final _locationController = TextEditingController();
  bool _isLocating = false;

  // Step 3: Security
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
        _errorMessage = null;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _errorMessage = null;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _locateBase() async {
    setState(() {
      _isLocating = true;
      _errorMessage = null;
    });

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied';
            _isLocating = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permission permanently denied';
          _isLocating = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get city name
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final cityName =
            place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            'Unknown';
        setState(() {
          _locationController.text = cityName;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
      });
    } finally {
      setState(() {
        _isLocating = false;
      });
    }
  }

  Future<void> _initiateProtocol() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Validate all fields
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedPreferences.isEmpty ||
        _locationController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'All fields are required';
      });
      return;
    }

    final success = await _authService.register(
      name: _nameController.text,
      phone: _phoneController.text,
      preferences: _selectedPreferences.toList(),
      location: _locationController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CardsScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Registration failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(colorScheme),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildIdentityStep(theme, colorScheme),
                  _buildBaseStep(theme, colorScheme),
                  _buildSecurityStep(theme, colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              height: 3,
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildIdentityStep(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'IDENTITY',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text('Establish Identity', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 40),

          // Full Name
          Text(
            'FULL NAME',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Enter your full name'),
          ),
          const SizedBox(height: 24),

          // Phone Number
          Text(
            'PHONE NUMBER',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '+1 234 567 8900'),
          ),
          const SizedBox(height: 32),

          // Directives (Preferences)
          Text(
            'DIRECTIVES',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availablePreferences.map((pref) {
              final isSelected = _selectedPreferences.contains(pref);
              return FilterChip(
                label: Text(pref),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPreferences.add(pref);
                    } else {
                      _selectedPreferences.remove(pref);
                    }
                  });
                },
              );
            }).toList(),
          ),

          if (_errorMessage != null && _currentStep == 0) ...[
            const SizedBox(height: 24),
            Text(_errorMessage!, style: TextStyle(color: colorScheme.error)),
          ],

          const SizedBox(height: 40),

          // Back to Login Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('BACK TO LOGIN'),
            ),
          ),
          const SizedBox(height: 16),

          // Next Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextStep,
              child: const Text('NEXT'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseStep(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'BASE',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text('Set Location', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 40),

          // Location with Locate Button
          Text(
            'LOCATION',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Enter your location',
              suffixIcon: _isLocating
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.my_location, color: colorScheme.primary),
                      onPressed: _locateBase,
                      tooltip: 'Locate Base',
                    ),
            ),
          ),

          if (_errorMessage != null && _currentStep == 1) ...[
            const SizedBox(height: 16),
            Text(_errorMessage!, style: TextStyle(color: colorScheme.error)),
          ],

          const SizedBox(height: 40),

          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _previousStep,
                    child: const Text('BACK'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    child: const Text('NEXT'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStep(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'SECURITY',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text('Establish Credentials', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 40),

          // Email
          Text(
            'EMAIL',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'your.email@example.com',
            ),
          ),
          const SizedBox(height: 24),

          // Password
          Text(
            'PASSWORD',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Enter secure password',
            ),
          ),

          if (_errorMessage != null && _currentStep == 2) ...[
            const SizedBox(height: 24),
            Text(_errorMessage!, style: TextStyle(color: colorScheme.error)),
          ],

          const SizedBox(height: 40),

          // Back Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: _previousStep,
              child: const Text('BACK'),
            ),
          ),
          const SizedBox(height: 16),

          // INITIATE PROTOCOL Button
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _initiateProtocol,
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Text('INITIATE PROTOCOL'),
            ),
          ),
        ],
      ),
    );
  }
}
