import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          border: const Border(right: BorderSide(width: .1))),
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        children: [
          Expanded(flex: 1, child: TextFormField(
            style: const TextStyle(fontSize: 13),
            controller: _userController,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              labelText: "username".tr,
              hintText: "username".tr,
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
          ),),
          const SizedBox(width: 16),
          Expanded(flex: 1, child: TextFormField(
            style: const TextStyle(fontSize: 13),
            controller: _pdController,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              labelText: "password".tr,
              hintText: "password".tr,
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
          ),),
          const SizedBox(width: 16),
          Obx(() => Text(Get.find<UserController>().failmessage.value)),
          Expanded(flex: 1, child: ElevatedButton(
            onPressed: _onTapLogin,
            style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              padding: EdgeInsets.zero,
            ),
            child: Text('login'.tr),
          ),),
        ],
      )
    );
  }

  void _onTapLogin(){
    UserController u = Get.find();
    final username = _userController.text.trim();
    final password = _pdController.text.trim();
    u.login(username, password);
    
  }

}