import 'package:get/get.dart';

import 'package:ones_llm/services/api.dart';

class ModelController extends GetxController {
  final modelList = <String>['gpt-3.5-turbo', 'gpt-3.5-turbo-ca', 'gpt-4-turbo'].obs;
  final availabelModelList = <String>['gpt-3.5-turbo', 'gpt-3.5-turbo-ca', 'gpt-4-turbo'].obs;
  final selectedModelList = <String>['gpt-3.5-turbo', 'gpt-3.5-turbo-ca'].obs;

  final ApiService api = Get.find();

  // @override
  // void onInit() async {
  //   conversationList.value = await api.getConversations();
  //   super.onInit();
  // }
  void getAllModels() async {
    modelList.value = await api.getAllModels();
  }

  void getAvailableModels() async {
    availabelModelList.value = await api.getAvailableModels();
  }

}
