import 'package:get/get.dart';
import 'package:ones_llm/controller/user.dart';

import 'package:ones_llm/services/api.dart';


class MessageController extends GetxController {
  final modelList = <String>['gpt-3.5-turbo', 'gpt-3.5-turbo-ca', 'gpt-4-turbo'].obs;
  final selectedModelList = <String>['gpt-3.5-turbo', 'gpt-3.5-turbo-ca', 'gpt-4-turbo'].obs;
  
  final messageList = <Message>[].obs;
  final selectingMessageList = <Message>[].obs;
  final selecting = false.obs;

  final ApiService api = Get.find();
  

  void initModelList() async {
    modelList.value = await api.getModelList();
  }

  void loadAllMessages(String conversationId) async {
    if (conversationId == '')return;
    final msg = await api.getMessages(conversationId);
    messageList.value = msg['msgList']!;
    selectingMessageList.value = msg['tmpList']!;
    selecting.value = selectingMessageList.isNotEmpty? true : false;
  }

  void clearMessages() async {
    messageList.value = [];
    selectingMessageList.value = [];
    selecting.value = false;
  }

  void sendMessage(
    String conversationId,
    String text
  ) async {
    selecting.value = true;
    final messages = await api.getMessages(conversationId);
    final sendedMessage = Message(conversationId: conversationId, text: text, role: Get.find<UserController>().userName.value);
    messageList.value = [...messages['msgList']!, sendedMessage];

    final newMessages = await api.sendMessage(conversationId, text, selectedModelList);
    selectingMessageList.value = newMessages;
    // await api.selectMessages(conversationId, 'gpt-3.5-turbo-ca');
    
    // messageList.value = [...messages, sendedMessage, newMessages[0]];
  }

  void selectMessage(
    String conversationId,
    String modelName,
  ) async {
    await api.selectMessages(conversationId, modelName);
    selectingMessageList.value = [];
    // final newMessages = []
    // messageList.value = [...messages, sendedMessage, newMessages[0]];
    loadAllMessages(conversationId);
  }

}
