import 'package:get/get.dart';

import 'package:ones_llm/services/api.dart';

class ConversationController extends GetxController {
  final conversationList = <Conversation>[].obs;
  final ApiService api = Get.find();

  final currentConversationUuid = "".obs;

  static ConversationController get to => Get.find();
  // @override
  // void onInit() async {
  //   conversationList.value = await api.getConversations();
  //   super.onInit();
  // }

  void getConversations() async {
    conversationList.value = await api.getConversations();
  }

  void setCurrentConversationId(String id) async {
    currentConversationUuid.value = id;
    update();
  }

  void deleteConversation(int index) async {
    Conversation conversation = conversationList[index];
    await api.deleteConversation(conversation.id);
    conversationList.value = await api.getConversations();
    update();
  }

  void renameConversation(Conversation conversation) async {
    await api.renameConversation(conversation.id, conversation.name);
    conversationList.value = await api.getConversations();
    update();
  }

  Future<String> addConversation({name, description}) async {
    final id = await api.addConversation();
    conversationList.add(Conversation(
      name: name, 
      description: description, 
      id: id)
    );
    conversationList.value = await api.getConversations();
    update();
    print(conversationList);
    return id;
  }
}
