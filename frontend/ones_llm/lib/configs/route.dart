import 'package:get/get.dart';

import 'package:ones_llm/pages/home.dart';
import 'package:ones_llm/pages/login.dart';


final routes = [
  GetPage(name: '/', page: () => MyHomePage()),
  GetPage(name: '/login', page: () => LoginPage()),
  // GetPage(name: '/second', page: () => const SecondPage()),
  // GetPage(name: '/setting', page: () => SettingPage())
];