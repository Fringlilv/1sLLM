import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ones_llm/components/chat/model_panel.dart';
import 'package:ones_llm/components/chat/select_card.dart';

import 'package:ones_llm/controller/model.dart';
import 'package:ones_llm/components/markdown.dart';
import 'package:ones_llm/components/chat/message_card.dart';
import 'package:ones_llm/controller/conversation.dart';
import 'package:ones_llm/controller/message.dart';
// import 'package:flutter_chatgpt/controller/settings.dart';
import 'package:ones_llm/services/api.dart';

class ChatWindow extends StatelessWidget {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  ChatWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(20),
      child: Row(children: [
        // const Expanded(
        //   flex: 1,
        //   child: SizedBox(),
        // ),
        Expanded(
          flex: 9,
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
                            (controller.selectingMessageList.isNotEmpty
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          final msgLen = controller.messageList.length;
                          if (index < msgLen) {
                            return MessageCard(
                                message: controller.messageList[index]);
                          } else {
                            // final msg =
                            //     controller.selectingMessageList[index - msgLen];
                            // return _buildSelectingCard(
                            //     msg, () => _selectMessage(msg.role));
                            return SelectCard(
                              selectList: controller.selectingMessageList,
                              onSelect:
                                  controller.selectMessage,
                            );
                          }
                        },
                      );
                    } else {
                      return Container(
                        alignment: Alignment.center,
                        child: Text('emptyChat'.tr),
                      );
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
                        enabled:
                            Get.find<MessageController>().selecting.isFalse,
                        style: const TextStyle(fontSize: 16),
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText: "inputPrompt".tr,
                          hintText: "inputPromptTips".tr,
                          isCollapsed: true,
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                        ),
                        autovalidateMode: AutovalidateMode.always,
                        maxLines: 5,
                        minLines: 1,
                        // maxLines: null,
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
                        onPressed:
                            Get.find<MessageController>().selecting.isTrue
                                ? null
                                : () {
                                    _sendMessage();
                                  },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.send),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed:
                            Get.find<MessageController>().selecting.isTrue
                                ? null
                                : () {
                                  Get.find<ModelController>().getAvailableProviderModels();
                                  Get.dialog(
                                    const Dialog(child: ModelSelectWindow()));},
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
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
        ),
        // const Expanded(
        //   flex: 1,
        //   child: SizedBox(),
        // )
      ]),
    );
  }

  void _sendMessage() async {
    final message = _textController.text.trim();
    final MessageController messageController = Get.find();
    final ConversationController conversationController = Get.find();
    final ModelController modelController = Get.find();
    if (message.isNotEmpty) {
      var conversationId = conversationController.currentConversationId.value;
      if (conversationId.isEmpty) {
        conversationId = await conversationController.addConversation(
          name: message.substring(0, message.length > 20 ? 20 : message.length),
          description: message,
        );
        conversationController.setCurrentConversationId(conversationId);
      }
      messageController.sendMessage(
          conversationId, message, modelController.selected());
      _textController.text = '';
    }
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
