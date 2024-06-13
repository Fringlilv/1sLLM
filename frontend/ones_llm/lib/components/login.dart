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
  final _pd2Controller = TextEditingController();
  final userController = Get.find<UserController>();
  final login = Get.find<UserController>().statu;

  @override
  Widget build(BuildContext context) {
    return Obx(() => 
      Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(20),
          // border: const Border(right: BorderSide(width: .1)),
          borderRadius: BorderRadius.circular(30),
        ),
        constraints: BoxConstraints(maxWidth: 500, maxHeight: login.value == LoginStatu.signUp?500:400),
        child: Column(
          children: [
            // const Expanded(flex: 1, child: SizedBox()),
            Expanded(
              flex: 2,
              child: TextFormField(
                style: const TextStyle(fontSize: 16),
                controller: _userController,
                decoration: InputDecoration(
                  labelText: "username".tr,
                  labelStyle: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(150)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    // borderSide: BorderSide.none,
                  ),
                  fillColor: Theme.of(context).colorScheme.background.withAlpha(150),
                ),
              ),
            ),
            const Expanded(flex: 1, child: SizedBox()),
            Expanded(
              flex: 2,
              child: TextFormField(
                style: const TextStyle(fontSize: 16),
                controller: _pdController,
                decoration: InputDecoration(
                  labelText: "password".tr,
                  labelStyle: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(150)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    // borderSide: BorderSide.none,
                  ),
                  fillColor: Theme.of(context).colorScheme.background.withAlpha(150),
                ),
              ),
            ),
            login.value == LoginStatu.signUp?
            const Expanded(flex: 1, child: SizedBox()):SizedBox(),
            login.value == LoginStatu.signUp?
              Expanded(
              flex: 2,
              child: TextFormField(
                style: const TextStyle(fontSize: 16),
                controller: _pd2Controller,
                decoration: InputDecoration(
                  labelText: "password2".tr,
                  labelStyle: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(150)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    // borderSide: BorderSide.none,
                  ),
                  fillColor: Theme.of(context).colorScheme.background.withAlpha(150),
                ),
              ),
            ):SizedBox(),
            Expanded(
              flex: 1,
              child:
                  Obx(() => Text(userController.failmessage.value)),
            ),
            Expanded(
              flex: 1,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login.value == LoginStatu.signUp?_toLogin:_toSignUp,
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(login.value == LoginStatu.signUp?'toLogin'.tr:'toSignup'.tr),
                ),
              ),
            ),
            const Expanded(flex: 1, child: SizedBox()),
            Expanded(
              flex: 1,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onTapLogin,
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(login.value == LoginStatu.signUp?'signup'.tr:'login'.tr),
                ),
              ),
            ),
            // const Expanded(flex: 1, child: SizedBox()),
          ],
        ),
      ),
    ));
  }

  void _onTapLogin() {
    final username = _userController.text.trim();
    final password = _pdController.text.trim();
    if(login.value != LoginStatu.signUp) {
      userController.login(username, password, () {
      Get.offNamed('/home');
      Get.find<ConversationController>().getConversations();
    });
    } else {
      if(_pd2Controller.text.trim()!=password){
        userController.failmessage.value = "notSame";
        return;
      }
      userController.signUp(username, password, () {});
    }
  }

  void _toSignUp() {
    userController.statu.value = LoginStatu.signUp;
    _userController.text = '';
    _pdController.text = '';
    _pd2Controller.text = '';
  }

  void _toLogin() {
    userController.statu.value = LoginStatu.notLogin;
    _userController.text = '';
    _pdController.text = '';
    _pd2Controller.text = '';
  }
}
