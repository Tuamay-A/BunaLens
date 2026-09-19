import 'package:get/get.dart';

import '../../core/utils/logger.dart';

// Controller for bottom navigation shell
class ShellController extends GetxController {
  final _currentIndex = 0.obs;

  int get currentIndex => _currentIndex.value;

  void changeTab(int index) {
    if (index >= 0 && index < 4) _currentIndex.value = index;
  }

  void goToHome()      => changeTab(0);
  void goToHistory()   => changeTab(1);
  void goToDashboard() => changeTab(2);
  void goToProfile()   => changeTab(3);

  @override
  void onInit() {
    super.onInit();
    AppLogger.d('[ShellController] Initialized');
  }

  @override
  void onClose() {
    AppLogger.d('[ShellController] Disposed');
    super.onClose();
  }
}
