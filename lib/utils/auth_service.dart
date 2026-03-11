import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service to handle login state using SharedPreferences
/// 
/// This service provides methods to:
/// - Check if user is logged in
/// - Save login state on successful login/signup
/// - Clear login state on logout
/// - Store and retrieve user profile information (name, email, profile image)
class AuthService {
  // Keys for storing login state in SharedPreferences
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userEmailKey = 'userEmail';
  static const String _userNameKey = 'userName';
  static const String _userProfileImageKey = 'userProfileImage';
  
  /// Check if user is already logged in
  /// Returns true if login state is stored and is true
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
  
  /// Save login state when user successfully logs in or signs up
  /// 
  /// [email] - Optional email to store for display purposes
  /// [name] - Optional name to store for display purposes
  /// [profileImage] - Optional profile image path to store
  Future<void> saveLoginState({
    String? email, 
    String? name,
    String? profileImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    if (email != null) {
      await prefs.setString(_userEmailKey, email);
    }
    if (name != null) {
      await prefs.setString(_userNameKey, name);
    }
    if (profileImage != null) {
      await prefs.setString(_userProfileImageKey, profileImage);
    }
  }
  
  /// Clear login state when user logs out
  Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userProfileImageKey);
  }
  
  /// Get stored user email (if available)
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }
  
  /// Get stored user name (if available)
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }
  
  /// Get stored user profile image path (if available)
  Future<String?> getUserProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userProfileImageKey);
  }
  
  /// Update user profile image path
  Future<void> updateProfileImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileImageKey, imagePath);
  }
  
  /// Update user name
  Future<void> updateUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }
}
