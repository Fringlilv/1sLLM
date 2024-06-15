import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ones_llm/controller/conversation.dart';
import 'package:ones_llm/controller/message.dart';
// import 'package:ones_llm/controller/user.dart';
// import 'package:flutter_chatgpt/controller/settings.dart';
import 'package:ones_llm/services/api.dart';

class ConversationWindow extends StatelessWidget {
  const ConversationWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(150),
          border: const Border(right: BorderSide(width: .1))),
      constraints: const BoxConstraints(maxWidth: 250),
      child: GetX<ConversationController>(builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.conversationList.isEmpty
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'noConversationTips'.tr,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: controller.conversationList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 1,
                          color: Theme.of(context).colorScheme.background.withAlpha(235),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          child: Obx(() => ListTile(
                            tileColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(70),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            // selectedColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(20),
                            onTap: () {
                              _tapConversation(index);
                            },
                            selected:
                                controller.currentConversationId.value ==
                                    controller.conversationList[index].id,
                            leading: Icon(
                              Icons.chat,
                              color: Theme.of(context).colorScheme.primaryContainer.withAlpha(200),
                            ),
                            title: Text(
                              controller.conversationList[index].name,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer),
                            ),
                            trailing: Builder(builder: (context) {
                              return IconButton(
                                  onPressed: () {
                                    //显示一个overlay操作
                                    _showConversationDetail(context, index);
                                  },
                                  icon: Icon(
                                    Icons.more_horiz,
                                    color:
                                        Theme.of(context).colorScheme.onPrimaryContainer,
                                  ));
                            }),
                          ),),
                        );
                      },
                    ),
                  ),
            const Divider(thickness: .5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onBackground),
                      backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.background),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                    ),
                    onPressed: () {
                      onTapNewConversation();
                      closeDrawer();
                    },
                    label: Text('newConversation'.tr),
                    icon: const Icon(Icons.add_box),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  TextButton.icon(
                    style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onBackground),
                      backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.background),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                    ),
                    onPressed: () {
                      controller.getConversations();
                      closeDrawer();
                    },
                    label: Text('refresh'.tr),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  // GetX<SettingsController>(builder: (controller) {
                  //   return TextButton.icon(
                  //     onPressed: () {},
                  //     label: Text("Version：${controller.version.value}"),
                  //     icon: const Icon(Icons.info),
                  //   );
                  // }),
                  TextButton.icon(
                    style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onBackground),
                      backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.background),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                    ),
                    onPressed: () {
                      closeDrawer();
                      Get.toNamed('/setting');
                    },
                    label: Text('settings'.tr),
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
            )
          ],
        );
      }),
    );
  }

  void _showConversationDetail(BuildContext context, int index) {
    final ConversationController controller = Get.find();
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: "delete",
          child: Text('delete'.tr),
        ),
        PopupMenuItem(
          value: "rename",
          child: Text('reName'.tr),
        ),
      ],
    ).then((value) {
      if (value == "delete") {
        controller.deleteConversation(index);
      } else if (value == "rename") {
        _renameConversation(context, index);
      }
    });
  }

  void onTapNewConversation() {
    ConversationController controller = Get.find();
    controller.setCurrentConversationId("");
    MessageController messageController = Get.find();
    messageController.clearMessages();
  }

  void _renameConversation(BuildContext context, int index) {
    final ConversationController conversationController = Get.find();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController controller = TextEditingController();
        controller.text = conversationController.conversationList[index].name;
        return AlertDialog(
          title: Text("renameConversation".tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'enterNewName'.tr,
                  hintText: 'enterNewName'.tr,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                ),
                autovalidateMode: AutovalidateMode.always,
                maxLines: null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("cancel".tr),
            ),
            TextButton(
              onPressed: () {
                conversationController.renameConversation(Conversation(
                  name: controller.text,
                  description: "",
                  id: conversationController.conversationList[index].id,
                ));
                Navigator.of(context).pop();
              },
              child: Text("ok".tr),
            ),
          ],
        );
      },
    );
  }

  _tapConversation(int index) {
    ConversationController controller = Get.find();
    closeDrawer();
    String conversationId = controller.conversationList[index].id;
    controller.setCurrentConversationId(conversationId);
    MessageController controllerMessage = Get.find();
    controllerMessage.loadAllMessages(conversationId);
    
  }

  void closeDrawer() {
    if (GetPlatform.isMobile) {
      Get.back();
    }
  }
}
