import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:ones_llm/services/api.dart';

class SettingController extends GetxController {
  final themeMode = ThemeMode.system.obs;
  final locale = const Locale('zh').obs;

  final useStream = true.obs;
  final useWebSearch = false.obs;

  final version = "1.0.0".obs;

  final ApiService api = Get.find();

  static SettingController get to => Get.find();

  @override
  void onInit() async {
    // await getThemeModeFromPreferences();
    await getLocaleFromPreferences();
    await initAppVersion();
    super.onInit();
  }

  initAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
  }

  void setThemeMode(ThemeMode model) async {
    Get.changeThemeMode(model);
    themeMode.value = model;
    GetStorage _box = GetStorage();
    _box.write('theme', model.toString().split('.')[1]);
  }

  // getThemeModeFromPreferences() async {
  //   ThemeMode themeMode;
  //   GetStorage _box = GetStorage();
  //   String themeText = _box.read('theme') ?? 'system';
  //   try {
  //     themeMode =
  //         ThemeMode.values.firstWhere((e) => describeEnum(e) == themeText);
  //   } catch (e) {
  //     themeMode = ThemeMode.system;
  //   }
  //   setThemeMode(themeMode);
  // }

  void switchLocale() {
    locale.value =
        _parseLocale(locale.value.languageCode == 'en' ? 'zh' : 'en');
  }

  Locale _parseLocale(String locale) {
    switch (locale) {
      case 'en':
        return const Locale('en');
      case 'zh':
        return const Locale('zh');
      default:
        throw Exception('system locale');
    }
  }


  void setLocale(Locale lol) {
    Get.updateLocale(lol);
    locale.value = lol;
    GetStorage _box = GetStorage();
    _box.write('locale', lol.languageCode);
  }

  getLocaleFromPreferences() async {
    Locale locale;
    GetStorage _box = GetStorage();
    String localeText = _box.read('locale') ?? 'zh';
    try {
      locale = _parseLocale(localeText);
    } catch (e) {
      locale = Get.deviceLocale!;
    }
    setLocale(locale);
  }

  fillApiKeyToControllers(Map<String, TextEditingController> controllerMap) async {
    final keys = await api.getAllApiKey();
    for (final ctrl in controllerMap.entries) {
      ctrl.value.text = keys[ctrl.key] ?? '';
    }
  }

  setApiKeyFromControllers(Map<String, TextEditingController> controllerMap) async {
    for (final ctrl in controllerMap.entries) {
      api.setApiKey(ctrl.key, ctrl.value.text);
    }
  }

}
