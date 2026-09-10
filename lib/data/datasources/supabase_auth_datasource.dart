import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';
import '../models/app_user.dart';

// Datasource for Supabase authentication operations
// Handles sign in, sign up, sign out, password reset, and session management
class SupabaseAuthDatasource {
  final SupabaseClient _client;
  final FlutterSecureStorage _secureStorage;

  // Storage keys
  static const String _sessionKey = 'supabase_session';

  SupabaseAuthDatasource({
    required SupabaseClient client,
    FlutterSecureStorage? secureStorage,
  })  : _client = client,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // AUTH OPERATIONS

  // Sign up a new user with email and password
  // Returns the created user's ID
  Future<String> signUp({
    required String email,
    required String password,
    String? displayName,
    String? preferredLanguage,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
          'preferred_language': preferredLanguage ?? 'en',
        },
      );

      if (response.user == null) {
        throw Exception('Sign up failed: No user returned');
      }

      // Store session
      if (response.session != null) {
        await _storeSession(response.session!);
      }

      return response.user!.id;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in with email and password
  // Returns the user's profile
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      // Store session
      if (response.session != null) {
        await _storeSession(response.session!);
      }

      // Fetch user profile from profiles table
      final profile = await _fetchUserProfile(response.user!.id);
      return profile;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      await _clearSession();
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Send password reset email
  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Update user password (when user has a recovery token)
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }

  // SESSION MANAGEMENT

  // Get current user session
  Session? get currentSession => _client.auth.currentSession;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentSession != null && currentUser != null;

  // Get current user ID
  String? get currentUserId => currentUser?.id;

  // Restore session from secure storage.
  Future<AppUser?> restoreSession() async {
    try {
      if (!isAuthenticated) return null;

      // Build AppUser from the in-memory auth user — no network call.
      final authUser = currentUser!;
      return AppUser(
        id: authUser.id,
        email: authUser.email ?? '',
        displayName: authUser.userMetadata?['display_name'] as String?,
        preferredLanguage:
            authUser.userMetadata?['preferred_language'] as String? ?? 'en',
        themeMode: authUser.userMetadata?['theme_mode'] as String? ?? 'system',
        cloudSyncEnabled:
            authUser.userMetadata?['cloud_sync_enabled'] as bool? ?? true,
        createdAt: authUser.createdAt.isNotEmpty
            ? DateTime.tryParse(authUser.createdAt) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      // If anything fails, clear the stale session and fall through to sign-in.
      await _clearSession();
      return null;
    }
  }

  // Refresh the current session
  Future<void> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      if (response.session != null) {
        await _storeSession(response.session!);
      }
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Session refresh failed: $e');
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // USER PROFILE

  // Fetch user profile from profiles table
  Future<AppUser> _fetchUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return AppUser.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Get current user profile
  Future<AppUser?> getCurrentUserProfile() async {
    if (!isAuthenticated) return null;
    try {
      return await _fetchUserProfile(currentUserId!);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<AppUser> updateUserProfile({
    String? displayName,
    String? preferredLanguage,
    String? themeMode,
    bool? cloudSyncEnabled,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (preferredLanguage != null) {
        updates['preferred_language'] = preferredLanguage;
      }
      if (themeMode != null) updates['theme_mode'] = themeMode;
      if (cloudSyncEnabled != null) {
        updates['cloud_sync_enabled'] = cloudSyncEnabled;
      }

      if (updates.isEmpty) {
        return await _fetchUserProfile(currentUserId!);
      }

      final response = await _client
          .from('profiles')
          .update(updates)
          .eq('id', currentUserId!)
          .select()
          .single();

      return AppUser.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // HELPERS

  // Store session in secure storage
  Future<void> _storeSession(Session session) async {
    try {
      await _secureStorage.write(
        key: _sessionKey,
        value: jsonEncode(session.toJson()),
      );
    } catch (e) {
      // Log error but don't fail — session is still in memory
      AppLogger.e('Failed to persist session', err: e);
    }
  }

  // Clear session from secure storage
  Future<void> _clearSession() async {
    try {
      await _secureStorage.delete(key: _sessionKey);
    } catch (e) {
      AppLogger.e('Failed to clear session storage', err: e);
    }
  }

  // Convert Supabase AuthException to user-friendly message
  Exception _handleAuthException(AuthException e) {
    final message = switch (e.message.toLowerCase()) {
      String msg when msg.contains('invalid login') => 'Invalid email or password',
      String msg when msg.contains('email not confirmed') => 'Please verify your email',
      String msg when msg.contains('user already registered') => 'This email is already registered',
      String msg when msg.contains('invalid email') => 'Invalid email format',
      String msg when msg.contains('weak password') => 'Password is too weak',
      String msg when msg.contains('email rate limit') => 'Too many attempts. Please try again later',
      _ => e.message,
    };
    return Exception(message);
  }
}
