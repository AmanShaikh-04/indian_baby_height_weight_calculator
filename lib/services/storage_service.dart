import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<bool> checkAndSetFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirst = prefs.getBool('is_first_launch') ?? true;
    if (isFirst) {
      await prefs.setBool('is_first_launch', false);
    }
    return isFirst;
  }

  static Future<String> getSystemSetting() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('setting_system') ?? 'metric';
  }

  static Future<List<Map<String, dynamic>>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> rawProfiles = prefs.getStringList('ibhwc_profiles') ?? [];
    return rawProfiles.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> saveProfiles(List<Map<String, dynamic>> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ibhwc_profiles', profiles.map((p) => jsonEncode(p)).toList());
  }

  static Future<String?> getActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('active_profile_id');
  }

  static Future<void> setActiveProfileId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove('active_profile_id');
    } else {
      await prefs.setString('active_profile_id', id);
    }
  }

  static Future<List<Map<String, dynamic>>> getDiary() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> rawDiary = prefs.getStringList('ibhwc_diary') ?? [];
    return rawDiary.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> saveDiary(List<Map<String, dynamic>> diary) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ibhwc_diary', diary.map((e) => jsonEncode(e)).toList());
  }
}