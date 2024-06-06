import 'package:get/get.dart';

import 'package:ones_llm/services/api.dart';


class MessageController extends GetxController {
  final messageList = <Message>[].obs;
  final newMessageList = <Message>[].obs;
  final ApiService api = Get.find();

  void loadAllMessages(String conversationUUid) async {
    messageList.value = await api.getMessages(conversationUUid);
  }

  void sendMessage(
    String conversationId,
    String text
  ) async {
    final messages = await api.getMessages(conversationId);
    final sendedMessage = Message(conversationId: conversationId, text: text, role: Role.user);
    messageList.value = [...messages, sendedMessage];

    final newMessages = await api.sendMessage(conversationId, text);
    newMessageList.value = newMessages;
    
    messageList.value = [...messages, sendedMessage, newMessages[0]];
  }
}
