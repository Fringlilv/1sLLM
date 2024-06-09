import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ones_llm/controller/conversation.dart';

import 'package:ones_llm/controller/user.dart';

class LoginWindow extends StatefulWidget {
  const LoginWindow({super.key});

  @override
  State<LoginWindow> createState() => _LoginWindowState();
}

class _LoginWindowState extends State<LoginWindow> {
  final _userController = TextEditingController();
  final _pdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(50),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(20),
          // border: const Border(right: BorderSide(width: .1)),
          borderRadius: BorderRadius.circular(30),
        ),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
        child: Column(
          children: [
            // const Expanded(flex: 1, child: SizedBox()),
            Expanded(
              flex: 2,
              child: TextFormField(
                style: const TextStyle(fontSize: 16),
                controller: _userController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "username".tr,
                  labelStyle: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(150)),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.background.withAlpha(150),
                ),
                autovalidateMode: AutovalidateMode.always,
                maxLines: null,
              ),
            ),
            const Expanded(flex: 1, child: SizedBox()),
            Expanded(
              flex: 2,
              child: TextFormField(
                style: const TextStyle(fontSize: 16),
                controller: _pdController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "password".tr,
                  labelStyle: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(150)),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.background.withAlpha(150),
                ),
                autovalidateMode: AutovalidateMode.always,
                maxLines: null,
              ),
            ),
            Expanded(
              flex: 1,
              child:
                  Obx(() => Text(Get.find<UserController>().failmessage.value)),
            ),
            Expanded(
              flex: 1,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onTapLogin,
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text('login'.tr),
                ),
              ),
            ),
            // const Expanded(flex: 1, child: SizedBox()),
          ],
        ),
      ),
    );
  }

  void _onTapLogin() {
    UserController u = Get.find();
    final username = _userController.text.trim();
    final password = _pdController.text.trim();
    u.login(username, password, () {
      Get.offNamed('/home');
      Get.find<ConversationController>().getConversations();
    });
  }
}
