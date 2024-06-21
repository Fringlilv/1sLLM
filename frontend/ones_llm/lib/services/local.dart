

import 'package:get/get.dart';

class LocalService extends GetxService {
  String _userName = '';

  String get userName {
    return _userName;
  }

  set userName(String value) {
    _userName = value;
  }

  @override
  void onInit() async {
    super.onInit();
  }

}
