import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/grading_repository.dart';

class CameraController extends GetxController {
  // Resolved in onInit() — never in field declarations
  late final GradingRepository _grader;
  late final AuthRepository _authRepository;

  final ImagePicker _picker = ImagePicker();
  final isProcessing = false.obs;
  final pickedPath = RxnString();
  final previewBytes = Rxn<Uint8List>();

  @override
  void onInit() {
    super.onInit();
    // Resolve dependencies here — GetX routing is fully settled by now
    _grader = Get.find<GradingRepository>();
    _authRepository = Get.find<AuthRepository>();
  }

  Future<void> pickFromCamera() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 92,
        maxWidth: 1600,
      );
      if (file == null) return;
      await _handlePicked(file);
    } catch (e) {
      Get.snackbar('Camera error', e.toString());
    }
  }

  Future<void> pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
        maxWidth: 1600,
      );
      if (file == null) return;
      await _handlePicked(file);
    } catch (e) {
      Get.snackbar('Gallery error', e.toString());
    }
  }

  Future<void> _handlePicked(XFile file) async {
    isProcessing.value = true;
    try {
      pickedPath.value = file.path;
      final bytes = await file.readAsBytes();
      previewBytes.value = bytes;

      final userId = _authRepository.currentUserId;

      final result = kIsWeb
          ? await _grader.gradeBytes(file.path, bytes, userId: userId)
          : await _grader.grade(file.path, userId: userId);

      Get.toNamed(AppRoutes.result, arguments: result);
    } catch (e) {
      Get.snackbar('Grading failed', e.toString());
    } finally {
      isProcessing.value = false;
    }
  }
}
