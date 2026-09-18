import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/logger.dart';
import '../../data/models/grade_result.dart';
import '../../data/repositories/grading_repository.dart';

class ResultController extends GetxController {
  // Resolved in onInit() — never in field declarations
  late final GradingRepository _gradingRepository;

  late final GradeResult result;
  final notes = ''.obs;
  final isEditingNotes = false.obs;
  final isSaving = false.obs;
  final isDeleting = false.obs;
  final notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Resolve dependencies here — GetX routing is fully settled by now
    _gradingRepository = Get.find<GradingRepository>();
    result = Get.arguments as GradeResult;
    notes.value = result.notes ?? '';
    notesController.text = notes.value;
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }

  void toggleEditNotes() {
    isEditingNotes.value = !isEditingNotes.value;
    if (!isEditingNotes.value) {
      notesController.text = notes.value;
    }
  }

  Future<void> saveNotes() async {
    try {
      isSaving.value = true;
      final newNotes = notesController.text.trim();
      await _gradingRepository.updateNotes(result.id, newNotes);
      notes.value = newNotes;
      isEditingNotes.value = false;
      Get.snackbar('Saved', 'Notes updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    } catch (e) {
      AppLogger.e('[ResultController] Error saving notes', err: e);
      Get.snackbar('Error', 'Failed to save notes',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteScan() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Scan'),
        content: const Text(
            'Are you sure you want to delete this scan? '
            'This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      isDeleting.value = true;
      await _gradingRepository.deleteScan(result.id);
      Get.back();
      Get.snackbar('Deleted', 'Scan deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    } catch (e) {
      AppLogger.e('[ResultController] Error deleting scan', err: e);
      Get.snackbar('Error', 'Failed to delete scan',
          snackPosition: SnackPosition.BOTTOM);
      isDeleting.value = false;
    }
  }

  void shareScan() {
    Get.snackbar('Coming Soon', 'Share functionality will be available soon',
        snackPosition: SnackPosition.BOTTOM);
  }
}
