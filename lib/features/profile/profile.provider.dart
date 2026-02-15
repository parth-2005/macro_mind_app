import 'package:flutter/material.dart';
import 'package:macro_mind_app/features/profile/profile.model.dart';
import 'package:macro_mind_app/core/services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  ProfileModel? _profile;
  bool _isLoading = false;
  String? _error;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _profile = await _apiService.getProfile();
    } catch (e) {
      _error = e.toString();
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(ProfileModel profile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedProfile = await _apiService.updateProfile(profile);
      _profile = updatedProfile;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createProfile(ProfileModel profile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final createdProfile = await _apiService.createProfile(profile);
      _profile = createdProfile;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
