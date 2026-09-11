// User profile model representing cloud-synced user data
// Maps to the `profiles` table in Supabase
class AppUser {
  final String id; // UUID from auth.users
  final String email;
  final String? displayName;
  final String preferredLanguage; // 'en' or 'am'
  final String themeMode; // 'system', 'light', 'dark'
  final bool cloudSyncEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    required this.preferredLanguage,
    required this.themeMode,
    required this.cloudSyncEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get display name or fallback to email username
  String get effectiveDisplayName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    // Fallback: use email username (part before @)
    return email.split('@').first;
  }

  // Get initials for avatar (up to 2 characters)
  String get initials {
    final name = effectiveDisplayName;
    if (name.isEmpty) return '?';

    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  // Create from Supabase JSON response
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      themeMode: json['theme_mode'] as String? ?? 'system',
      cloudSyncEnabled: json['cloud_sync_enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to JSON for Supabase updates
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'preferred_language': preferredLanguage,
      'theme_mode': themeMode,
      'cloud_sync_enabled': cloudSyncEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? preferredLanguage,
    String? themeMode,
    bool? cloudSyncEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      themeMode: themeMode ?? this.themeMode,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, displayName: $displayName, '
        'preferredLanguage: $preferredLanguage, themeMode: $themeMode, '
        'cloudSyncEnabled: $cloudSyncEnabled)';
  }
}
