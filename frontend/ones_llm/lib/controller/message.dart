import 'package:get/get.dart';
import 'package:ones_llm/controller/user.dart';

import 'package:ones_llm/services/api.dart';


class MessageController extends GetxController {
  final messageList = <Message>[].obs;
  final newMessageList = <Message>[].obs;
  final ApiService api = Get.find();

  void loadAllMessages(String conversationId) async {
    messageList.value = await api.getMessages(conversationId);
  }

  void sendMessage(
    String conversationId,
    String text
  ) async {
    final messages = await api.getMessages(conversationId);
    final sendedMessage = Message(conversationId: conversationId, text: text, role: Get.find<UserController>().userName.value);
    messageList.value = [...messages, sendedMessage];

    final newMessages = await api.sendMessage(conversationId, text, ['model']);
    newMessageList.value = newMessages;
    await api.selectMessages(conversationId, 'model');
    
    messageList.value = [...messages, sendedMessage, newMessages[0]];
  }
}
