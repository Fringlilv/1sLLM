import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ones_llm/controller/user.dart';

import 'package:ones_llm/components/markdown.dart';
import 'package:ones_llm/controller/conversation.dart';
import 'package:ones_llm/controller/message.dart';
// import 'package:flutter_chatgpt/controller/settings.dart';
import 'package:ones_llm/services/api.dart';

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
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(20),
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
                    itemCount: controller.messageList.length +
                        controller.selectingMessageList.length,
                    itemBuilder: (context, index) {
                      final msgLen = controller.messageList.length;
                      if (index < msgLen) {
                        return _buildMessageCard(controller.messageList[index]);
                      } else {
                        final msg =
                            controller.selectingMessageList[index - msgLen];
                        return _buildSelectingCard(
                            msg, () => _selectMessage(msg.role));
                      }
                    },
                  );
                } else {
                  return Container(
                    alignment: Alignment.center,
                    child: Text('emptyChat'.tr),
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
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => TextFormField(
                    enabled: Get.find<MessageController>().selecting.isFalse,
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
                    focusNode: FocusNode(
                      onKeyEvent: _handleKeyEvent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 48,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: Get.find<MessageController>().selecting.isTrue
                        ? null
                        : () {
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
              ),
            ],
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
      var conversationId = conversationController.currentConversationId.value;
      if (conversationId.isEmpty) {
        conversationId = await conversationController.addConversation(
          name: message.substring(0, message.length > 20 ? 20 : message.length),
          description: message,
        );
        conversationController.setCurrentConversationId(conversationId);
      }
      messageController.sendMessage(conversationId, message);
      _textController.text = '';
    }
  }

  void _selectMessage(String modelName) async {
    final MessageController messageController = Get.find();
    final ConversationController conversationController = Get.find();
    messageController.selectMessage(
        conversationController.currentConversationId.value, modelName);
  }

  Widget _buildMessageCard(Message message) {
    final userName = Get.find<UserController>().userName.value;
    if (message.role == userName) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const FaIcon(FontAwesomeIcons.person),
              const SizedBox(
                width: 5,
              ),
              Text(userName),
              const SizedBox(
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 16,
                        ),
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
              Text(message.role),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Expanded(
              //   child: Card(
              //     elevation: 8,
              //     margin: const EdgeInsets.all(8),
              //     child: Markdown(text: message.text),
              //   ),
              // ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Card(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    elevation: 8,
                    child: Markdown(text: message.text),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildSelectingCard(Message message, void Function() onSelect) {
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
            Text(message.role),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
              onPressed: onSelect,
              child: Text('selectResponse'.tr),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Card(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  elevation: 8,
                  child: Markdown(text: message.text),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  KeyEventResult _handleKeyEvent(node, event) {
    if (event is KeyDownEvent &&
        event.physicalKey == PhysicalKeyboardKey.enter &&
        !HardwareKeyboard.instance.physicalKeysPressed.any((key) => {
              PhysicalKeyboardKey.shiftLeft,
              PhysicalKeyboardKey.shiftRight,
            }.contains(key))) {
      _sendMessage();
      return KeyEventResult.handled;
    } else if (event is KeyRepeatEvent) {
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }

  void _scrollToNewMessage() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
