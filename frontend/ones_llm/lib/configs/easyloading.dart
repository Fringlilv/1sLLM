import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

void initEasyLoading() {
  EasyLoading.instance
    ..backgroundColor = Get.theme.colorScheme.primaryContainer
    ..textColor = Get.theme.colorScheme.onPrimaryContainer;
}
