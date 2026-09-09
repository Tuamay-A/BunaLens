import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/logger.dart';
import '../models/grade_result.dart';

class LocalStorageDataSource {
  static const _historyKey = 'buna_lens_history_v1';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    AppLogger.d('LocalStorage ready.');
  }

  // ---- History ----

  List<GradeResult> loadHistory() {
    final raw = _prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List)
        .map((e) => GradeResult.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return list;
  }

  Future<void> saveHistory(List<GradeResult> items) async {
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_historyKey, raw);
  }

  Future<void> addToHistory(GradeResult item) async {
    final list = loadHistory();
    list.insert(0, item);
    if (list.length > 200) list.removeRange(200, list.length);
    await saveHistory(list);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }
}