import 'package:get/get.dart';
import 'package:ones_llm/controller/user.dart';

import 'package:ones_llm/services/api.dart';


class MessageController extends GetxController { 
  final messageList = <Message>[].obs;
  final selectingMessageList = <Message>[].obs;
  final selecting = false.obs;

  final ApiService api = Get.find();

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
    String text,
    Map<String, List<String>> selectProviderModels
  ) async {
    selecting.value = true;
    final messages = await api.getMessages(conversationId);
    final sendedMessage = Message(conversationId: conversationId, text: text, role: Get.find<UserController>().userName.value);
    messageList.value = [...messages['msgList']!, sendedMessage];

    final newMessages = await api.sendMessage(conversationId, text, selectProviderModels);
    selectingMessageList.value = newMessages;
  }

  void selectMessage(
    Message message
  ) async {
    await api.selectMessages(message.conversationId, message.role);
    selectingMessageList.value = [];
    loadAllMessages(message.conversationId);
  }

}
