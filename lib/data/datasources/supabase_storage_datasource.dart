// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

// Datasource for Supabase Storage operations
// Handles upload, download, and delete operations for scan images
class SupabaseStorageDatasource {
  final SupabaseClient _client;
  static const String _bucketName = 'scan-images';

  SupabaseStorageDatasource({required SupabaseClient client})
      : _client = client;

  // UPLOAD

  Future<String> uploadImage({
    required String userId,
    required String scanId,
    required String localFilePath,
  }) async {
    try {
      final file = File(localFilePath);

      // Check if file exists
      if (!await file.exists()) {
        throw Exception('Image file not found: $localFilePath');
      }

      // Get file extension
      final extension = path.extension(localFilePath).toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
      
      if (!validExtensions.contains(extension)) {
        throw Exception('Invalid image format. Supported: jpg, jpeg, png, webp');
      }

      // Build storage path: userId/scanId.extension
      final storagePath = '$userId/$scanId$extension';

      // Read file bytes
      final bytes = await file.readAsBytes();

      // Determine content type
      final contentType = _getContentType(extension);

      // Upload to Supabase Storage
      await _client.storage.from(_bucketName).uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: false, // Don't overwrite existing files
            ),
          );

      // Get public URL
      final publicUrl = _client.storage.from(_bucketName).getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload image from bytes (useful for web or when file is already in memory)
  Future<String> uploadImageBytes({
    required String userId,
    required String scanId,
    required Uint8List bytes,
    required String extension, // e.g., 'jpg', 'png'
  }) async {
    try {
      // Validate extension
      final ext = extension.startsWith('.') ? extension : '.$extension';
      final validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
      
      if (!validExtensions.contains(ext.toLowerCase())) {
        throw Exception('Invalid image format. Supported: jpg, jpeg, png, webp');
      }

      // Build storage path
      final storagePath = '$userId/$scanId$ext';

      // Determine content type
      final contentType = _getContentType(ext);

      // Upload to Supabase Storage
      await _client.storage.from(_bucketName).uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _client.storage.from(_bucketName).getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image bytes: $e');
    }
  }

  // DOWNLOAD

  // Download an image from Supabase Storage
  // Returns the image bytes
  Future<Uint8List> downloadImage(String storagePath) async {
    try {
      final bytes = await _client.storage.from(_bucketName).download(storagePath);
      return bytes;
    } catch (e) {
      throw Exception('Failed to download image: $e');
    }
  }

  // Download image and save to local file
  Future<String> downloadImageToFile({
    required String storagePath,
    required String localFilePath,
  }) async {
    try {
      final bytes = await downloadImage(storagePath);
      final file = File(localFilePath);
      
      // Create parent directory if it doesn't exist
      await file.parent.create(recursive: true);
      
      // Write bytes to file
      await file.writeAsBytes(bytes);
      
      return localFilePath;
    } catch (e) {
      throw Exception('Failed to download image to file: $e');
    }
  }

  // DELETE

  // Delete a single image from Supabase Storage
  Future<void> deleteImage(String storagePath) async {
    try {
      await _client.storage.from(_bucketName).remove([storagePath]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Delete multiple images from Supabase Storage
  Future<void> deleteImages(List<String> storagePaths) async {
    try {
      if (storagePaths.isEmpty) return;
      await _client.storage.from(_bucketName).remove(storagePaths);
    } catch (e) {
      throw Exception('Failed to delete images: $e');
    }
  }

  // Delete all images for a user (on account deletion)
  Future<void> deleteUserImages(String userId) async {
    try {
      // List all files in user's folder
      final files = await _client.storage
          .from(_bucketName)
          .list(path: userId);

      if (files.isEmpty) return;

      // Build paths
      final paths = files.map((file) => '$userId/${file.name}').toList();

      // Delete all
      await _client.storage.from(_bucketName).remove(paths);
    } catch (e) {
      throw Exception('Failed to delete user images: $e');
    }
  }


  // UTILITIES

  // Get public URL for an image (doesn't check if it exists)
  String getPublicUrl(String storagePath) {
    return _client.storage.from(_bucketName).getPublicUrl(storagePath);
  }


  String? extractStoragePathFromUrl(String publicUrl) {
    try {
      final uri = Uri.parse(publicUrl);
      final segments = uri.pathSegments;
      
      // Find 'scan-images' bucket in path
      final bucketIndex = segments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex >= segments.length - 1) {
        return null;
      }
      
      // Everything after bucket name is the storage path
      final pathSegments = segments.sublist(bucketIndex + 1);
      return pathSegments.join('/');
    } catch (e) {
      return null;
    }
  }

  // Check if an image exists in storage
  Future<bool> imageExists(String storagePath) async {
    try {
      // Try to get file info
      final files = await _client.storage
          .from(_bucketName)
          .list(path: path.dirname(storagePath));
      
      final fileName = path.basename(storagePath);
      return files.any((file) => file.name == fileName);
    } catch (e) {
      return false;
    }
  }

  // Get file size in bytes
  Future<int?> getFileSize(String storagePath) async {
    try {
      final files = await _client.storage
          .from(_bucketName)
          .list(path: path.dirname(storagePath));
      
      final fileName = path.basename(storagePath);
      final file = files.firstWhere(
        (file) => file.name == fileName,
        orElse: () => throw Exception('File not found'),
      );
      
      return file.metadata?['size'] as int?;
    } catch (e) {
      return null;
    }
  }

  // HELPERS

  // Get MIME content type from file extension
  String _getContentType(String extension) {
    final ext = extension.toLowerCase();
    return switch (ext) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.png' => 'image/png',
      '.webp' => 'image/webp',
      '.gif' => 'image/gif',
      _ => 'application/octet-stream',
    };
  }

  // Build storage path from userId and scanId
  String buildStoragePath(String userId, String scanId, String extension) {
    final ext = extension.startsWith('.') ? extension : '.$extension';
    return '$userId/$scanId$ext';
  }
}
