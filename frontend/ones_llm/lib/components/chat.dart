import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:ones_llm/components/markdown.dart';
import 'package:ones_llm/controller/conversation.dart';
import 'package:ones_llm/controller/message.dart';
// import 'package:flutter_chatgpt/controller/settings.dart';
import 'package:ones_llm/services/api.dart';

var uuid = const Uuid();

class ChatWindow extends StatefulWidget {
  const ChatWindow({super.key});

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // 定义一个 GlobalKey
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: GetX<MessageController>(
              builder: (controller) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToNewMessage();
                });
                if (controller.messageList.isNotEmpty) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: controller.messageList.length,
                    itemBuilder: (context, index) {
                      return _buildMessageCard(controller.messageList[index]);
                    },
                  );
                } else {
                  return Container(
                    alignment: Alignment.center,
                    child: const Text('empty'),
                  );
                  // return GetX<PromptController>(builder: ((controller) {
                  //   if (controller.prompts.isEmpty) {
                  //     return const Center(
                  //       child: Center(child: Text("正在加载prompts...")),
                  //     );
                  //   } else if (controller.prompts.isNotEmpty) {
                  //     return PromptsView(controller.prompts, (value) {
                  //       _controller.text = value;
                  //     });
                  //   } else {
                  //     return const Center(child: Text("加载prompts列表失败，请检查网络"));
                  //   }
                  // }));
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey, // 将 GlobalKey 赋值给 Form 组件的 key 属性
            child: KeyboardListener (
              focusNode: FocusNode(),
              onKeyEvent: _handleKeyEvent,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      style: const TextStyle(fontSize: 13),
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: "inputPrompt".tr,
                        hintText: "inputPromptTips".tr,
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                      ),
                      autovalidateMode: AutovalidateMode.always,
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        _sendMessage();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = _textController.text.trim();
    final MessageController messageController = Get.find();
    final ConversationController conversationController = Get.find();
    if (message.isNotEmpty) {
      var conversationId =
          conversationController.currentConversationUuid.value;
      if (conversationId.isEmpty) {
        conversationId = await conversationController.addConversation(
          name: message.substring(0, message.length > 20 ? 20 : message.length),
          description: message,
        );
        conversationController.setCurrentConversationId(conversationId);
      }
      messageController.sendMessage(conversationId, message);
      _formKey.currentState!.reset();
    }
  }

  Widget _buildMessageCard(Message message) {
    if (message.role == Role.user) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FaIcon(FontAwesomeIcons.person),
              SizedBox(
                width: 5,
              ),
              Text("User"),
              SizedBox(
                width: 10,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Card(
                    color: Colors.blue[100],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(
                        message.text,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 10,
              ),
              const FaIcon(FontAwesomeIcons.robot),
              const SizedBox(
                width: 5,
              ),
              Text(message.role == Role.system ? "System" : "assistant"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  elevation: 8,
                  margin: const EdgeInsets.all(8),
                  child: Markdown(text: message.text),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  void _handleKeyEvent(KeyEvent value) {
    if (value.logicalKey == LogicalKeyboardKey.enter) {
      _sendMessage();
    }
  }

  void _scrollToNewMessage() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}