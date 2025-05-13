import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../const/stringConst.dart';
import '../auth/loginScreen.dart';

class TokenManager {
  static TokenManager? _instance;
  static TokenManager get instance => _instance ??= TokenManager._();
  TokenManager._();

  bool _isRefreshing = false;
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;

    final prefs = await SharedPreferences.getInstance();
    _cachedAccessToken = prefs.getString('access_token');
    return _cachedAccessToken;
  }

  Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;

    final prefs = await SharedPreferences.getInstance();
    _cachedRefreshToken = prefs.getString('refresh_token');
    return _cachedRefreshToken;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);

    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
  }

  Future<bool> refreshAccessToken() async {
    if (_isRefreshing) return true; // Return true to indicate refresh is in progress
    _isRefreshing = true;

    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('${StringConst.protocol}${StringConst.baseUrl}${StringConst.refreshToken}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'refresh': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(
          accessToken: data['access'],
          refreshToken: data['refresh'] ?? refreshToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<http.Response> authenticatedRequest(
      Future<http.Response> Function(String token) requestFunction,
      BuildContext context,
      ) async {
    try {
      // First check if we need to refresh the token
      String? token = await getAccessToken();
      if (token == null) {
        // Try refresh before giving up
        final refreshSuccess = await refreshAccessToken();
        if (!refreshSuccess) {
          _handleUnauthorized(context);
          throw Exception('No access token available');
        }
        token = await getAccessToken();
      }

      // Make the request with current token
      final response = await requestFunction(token!);

      if (response.statusCode == 401) {
        // Token expired, attempt refresh
        final refreshSuccess = await refreshAccessToken();
        if (refreshSuccess) {
          // Retry with new token
          token = await getAccessToken();
          final retryResponse = await requestFunction(token!);
          if (retryResponse.statusCode != 401) {
            return retryResponse;
          }
        }
        _handleUnauthorized(context);
        throw Exception('Authentication failed');
      }

      return response;
    } catch (e) {
      if (e is Exception && e.toString().contains('Authentication failed')) {
        _handleUnauthorized(context);
      }
      throw Exception('Request failed: $e');
    }
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear cached tokens
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _isRefreshing = false;

    // Clear stored tokens and user data
    await Future.wait([
      prefs.remove('access_token'),
      prefs.remove('refresh_token'),
      prefs.remove('photo'),
      prefs.remove('user_name'),
      prefs.remove('email'),
      // Add any other relevant keys you're storing
    ]);
  }

  void _handleUnauthorized(BuildContext context) async {
    // Clear cached tokens
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    await clearTokens();

    // Clear stored tokens
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('access_token');
      prefs.remove('refresh_token');
    });

    // Navigate to login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }


}