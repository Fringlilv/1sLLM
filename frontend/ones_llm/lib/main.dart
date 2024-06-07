import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:ones_llm/configs/route.dart';
import 'package:ones_llm/configs/translations.dart';
import 'package:ones_llm/controller/conversation.dart';
import 'package:ones_llm/controller/message.dart';
import 'package:ones_llm/controller/user.dart';
import 'package:ones_llm/pages/home.dart';
import 'package:ones_llm/services/api.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ApiService());
    Get.put(UserController());
    Get.put(ConversationController());
    Get.put(MessageController());
    return GetMaterialApp(
      initialRoute: '/login',
      getPages: routes,
      unknownRoute:
          GetPage(name: '/', page: () => MyHomePage()),
      theme: FlexThemeData.light(scheme: FlexScheme.ebonyClay),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.ebonyClay),
      themeMode: ThemeMode.system,
      locale: const Locale('zh'),
      translations: OnesLLMTranslations(),
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
    );
  }
}