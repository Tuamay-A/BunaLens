// ignore_for_file: avoid_print

import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';
import '../datasources/supabase_auth_datasource.dart';
import '../models/app_user.dart';
import '../services/sync_service.dart';
import '../local/database.dart';

/// Repository for authentication business logic
/// Abstracts the auth datasource and adds business rules
class AuthRepository {
  final SupabaseAuthDatasource _authDatasource;
  SyncService? _syncService;
  AppDatabase? _database;

  AuthRepository({required SupabaseAuthDatasource authDatasource})
      : _authDatasource = authDatasource;

  // Set sync service (called from InitialBinding after SyncService is created)
  void setSyncService(SyncService syncService) {
    _syncService = syncService;
  }

  // Set database (called from InitialBinding)
  void setDatabase(AppDatabase database) {
    _database = database;
  }

  // AUTH OPERATIONS

  // Sign up a new user
  // Validates inputs and creates account
  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? displayName,
    String? preferredLanguage,
  }) async {
    try {
      // Basic validation
      if (email.isEmpty) {
        return AuthResult.failure('Email is required');
      }
      if (password.isEmpty) {
        return AuthResult.failure('Password is required');
      }

      await _authDatasource.signUp(
        email: email,
        password: password,
        displayName: displayName,
        preferredLanguage: preferredLanguage,
      );

      // Fetch the created profile
      final profile = await _authDatasource.getCurrentUserProfile();
      if (profile == null) {
        return AuthResult.failure('Profile not found after signup');
      }

      // Start sync service after successful signup
      _syncService?.start();

      return AuthResult.success(
        user: profile,
        message: 'Account created successfully',
      );
    } catch (e) {
      return AuthResult.failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty) {
        return AuthResult.failure('Email is required');
      }
      if (password.isEmpty) {
        return AuthResult.failure('Password is required');
      }

      final user = await _authDatasource.signIn(
        email: email,
        password: password,
      );

      // Start sync service after successful sign in
      _syncService?.start();

      return AuthResult.success(
        user: user,
        message: 'Welcome back!',
      );
    } catch (e) {
      return AuthResult.failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Sign out current user
  // Optionally clear local data
  Future<AuthResult> signOut({bool clearLocalData = false}) async {
    try {
      // Stop sync service before sign out
      _syncService?.stop();

      await _authDatasource.signOut();

      // Clear local database if requested
      if (clearLocalData && _database != null) {
        final userId = currentUserId;
        if (userId != null) {
          await _clearLocalData(userId);
        }
      }

      return AuthResult.success(message: 'Signed out successfully');
    } catch (e) {
      return AuthResult.failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Send password reset email
  Future<AuthResult> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        return AuthResult.failure('Email is required');
      }

      await _authDatasource.resetPasswordForEmail(email);

      return AuthResult.success(
        message: 'Password reset email sent. Check your inbox.',
      );
    } catch (e) {
      return AuthResult.failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Update user password
  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      if (newPassword.isEmpty) {
        return AuthResult.failure('New password is required');
      }

      await _authDatasource.updatePassword(newPassword);

      return AuthResult.success(message: 'Password updated successfully');
    } catch (e) {
      return AuthResult.failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // SESSION MANAGEMENT

  // Check if user is authenticated
  bool get isAuthenticated => _authDatasource.isAuthenticated;

  // Get current user ID
  String? get currentUserId => _authDatasource.currentUserId;

  // Get current session
  Session? get currentSession => _authDatasource.currentSession;

  static const Duration _restoreTimeout = Duration(seconds: 5);

  Future<AppUser?> restoreSession() async {
    try {
      final user = await _authDatasource
          .restoreSession()
          .timeout(_restoreTimeout);

      if (user != null) {
        _syncService?.start();
      }
      return user;
    } on TimeoutException {
      AppLogger.e('[AuthRepository] Session restore timed out — proceeding to sign-in');
      return null;
    } catch (e) {
      AppLogger.e('[AuthRepository] Session restore failed', err: e);
      return null;
    }
  }

  // Refresh current session
  Future<void> refreshSession() async {
    await _authDatasource.refreshSession();
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges =>
      _authDatasource.authStateChanges;

  // USER PROFILE

  // Get current user profile
  Future<AppUser?> getCurrentUser() async {
    try {
      return await _authDatasource.getCurrentUserProfile();
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<AuthResult> updateProfile({
    String? displayName,
    String? preferredLanguage,
    String? themeMode,
    bool? cloudSyncEnabled,
  }) async {
    try {
      final user = await _authDatasource.updateUserProfile(
        displayName: displayName,
        preferredLanguage: preferredLanguage,
        themeMode: themeMode,
        cloudSyncEnabled: cloudSyncEnabled,
      );

      return AuthResult.success(
        user: user,
        message: 'Profile updated successfully',
      );
    } catch (e) {
      return AuthResult.failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ACCOUNT MANAGEMENT

  // Delete user account (will be implemented later if needed)
  Future<AuthResult> deleteAccount() async {
    return AuthResult.failure('Account deletion not yet implemented');
  }

  // HELPERS

  // Clear all local data for a user
  Future<void> _clearLocalData(String userId) async {
    try {
      AppLogger.d('[AuthRepository] Clearing local data for user $userId');
      
      // Delete all scans
      await _database!.deleteAllScans(userId);
      
      // Clear outbox
      await _database!.clearOutbox();
      
      AppLogger.d('[AuthRepository] Local data cleared');
    } catch (e) {
      AppLogger.d('[AuthRepository] Failed to clear local data: $e');
    }
  }
}

// AUTH RESULT


// Result object for auth operations
// Contains success/failure state and optional user/message
class AuthResult {
  final bool isSuccess;
  final String? message;
  final AppUser? user;

  const AuthResult._({
    required this.isSuccess,
    this.message,
    this.user,
  });

  factory AuthResult.success({String? message, AppUser? user}) {
    return AuthResult._(
      isSuccess: true,
      message: message,
      user: user,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      message: message,
    );
  }

  bool get isFailure => !isSuccess;

  @override
  String toString() {
    return 'AuthResult(isSuccess: $isSuccess, message: $message, user: ${user?.email})';
  }
}

