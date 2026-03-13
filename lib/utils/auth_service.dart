import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AuthService {
  // API Configuration
  static const String _baseUrl = 'https://pet-health-tracker-mnpb.onrender.com/api/v1';
  
  // Keys for storing login state and tokens in SharedPreferences
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userKey = 'user';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userEmailKey = 'userEmail';
  static const String _userNameKey = 'userName';
  static const String _userProfileImageKey = 'userProfileImage';
  
  /// Check if user is already logged in
 
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    return accessToken != null && isLoggedIn;
  }
  
  /// Save login state, tokens, and user data
  Future<void> saveLoginState({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
    String? profileImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userKey, jsonEncode(user));
    await prefs.setBool(_isLoggedInKey, true);
    if (profileImage != null) {
      await prefs.setString(_userProfileImageKey, profileImage);
    }
  }
  
  /// Clear login state and tokens when user logs out
  Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userProfileImageKey);
  }
  
  /// Get stored access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get stored user data
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return jsonDecode(userJson);
  }
  
  /// Login API call
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final user = data['user'];
        await saveLoginState(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: user,
        );
        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
          'code': data['code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Signup API call (sends OTP)
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'OTP sent',
          'email': data['email'],
          'otpExpiresAt': data['otpExpiresAt'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Signup failed',
          'code': data['code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Verify email with OTP
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);
      
      return {
        'success': data['success'] == true,
        'message': data['message'] ?? 'Verification failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
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
