import 'package:get/get.dart';

import 'package:ones_llm/services/api.dart';

enum LoginStatu {
  notLogin,
  tryingLogin,
  failLogin,
  hasLogin
}

class UserController extends GetxController {
  final statu = LoginStatu.notLogin.obs;
  final failmessage = ''.obs;
  final ApiService api = Get.find();

  @override
  void onInit() async {
    super.onInit();
    login('admin', 'admin');
  }

  void login(String username, String password) async {
    statu.value = LoginStatu.tryingLogin;
    final res = await api.login(username, password);
    switch(res){
      case LoginResponse.success:
        failmessage.value = '';
        statu.value = LoginStatu.hasLogin;
      case LoginResponse.badUser:
        statu.value = LoginStatu.failLogin;
        failmessage.value = 'badUser'.tr;
      case LoginResponse.badPasswd:
        statu.value = LoginStatu.failLogin;
        failmessage.value = 'badPassword'.tr;
      case LoginResponse.unknown:
        statu.value = LoginStatu.failLogin;
        failmessage.value = 'unknownError'.tr;
    }
  }

  void logout() async {
    statu.value = LoginStatu.notLogin;
    final res = await api.logout();
  }
}
