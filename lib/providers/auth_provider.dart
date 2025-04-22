import 'package:flutter/foundation.dart';
import 'package:gravity_rewards_app/models/user_model.dart';

// Mock Auth Provider for UI development only
class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  // Mock user data
  static final UserModel _mockUser = UserModel(
    id: 'mock-user-123',
    email: 'user@example.com',
    name: 'Test User',
    phoneNumber: '555-123-4567',
    profileImageUrl: null,
    points: 350,
    rewardHistory: ['reward1', 'reward2'],
    activityHistory: ['activity1', 'activity2'],
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    lastLoginAt: DateTime.now(),
  );
  
  // Constructor - auto login for UI development
  AuthProvider() {
    // For UI development, we'll automatically sign in
    // Uncomment the following line to start with a signed in user
    _user = _mockUser;
  }
  
  // Helper to set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Helper to set error
  void setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  // Mock sign in
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Always succeed for UI development
      _user = _mockUser;
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // Mock register
  Future<bool> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Always succeed for UI development
      _user = _mockUser.copyWith(
        email: email,
        name: name,
      );
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // Mock Google sign in
  Future<bool> signInWithGoogle() async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Always succeed for UI development
      _user = _mockUser.copyWith(
        name: 'Google User',
        profileImageUrl: 'https://via.placeholder.com/150',
      );
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      setLoading(true);
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      _user = null;
      
      setLoading(false);
    } catch (e) {
      setLoading(false);
      setError(e.toString());
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      if (_user == null) {
        return false;
      }
      
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Update user data
      _user = _user!.copyWith(
        name: name ?? _user!.name,
        phoneNumber: phoneNumber ?? _user!.phoneNumber,
        profileImageUrl: profileImageUrl ?? _user!.profileImageUrl,
      );
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // Refresh user data
  Future<void> refreshUserData() async {
    try {
      if (_user == null) {
        return;
      }
      
      setLoading(true);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // For UI development, just update points randomly
      _user = _user!.copyWith(
        points: _user!.points + 10,
      );
      
      setLoading(false);
    } catch (e) {
      setLoading(false);
      setError(e.toString());
    }
  }
} 