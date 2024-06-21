import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'package:ones_llm/components/basic/radius_widgets.dart';
import 'package:ones_llm/controller/conversation.dart';
import 'package:ones_llm/controller/login.dart';

class _LoginWindow extends StatelessWidget {
  _LoginWindow({super.key});

  // final login = Get.find<UserController>().statu;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      init: LoginController(),
        builder: (controller) => Container(
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withAlpha(20),
                // border: const Border(right: BorderSide(width: .1)),
                borderRadius: BorderRadius.circular(30),
              ),
              constraints: BoxConstraints(
                  maxWidth: 500,
                  maxHeight: controller.statu == LoginStatu.signUp ? 500 : 400),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: RadiusTextFormField(
                      controller: controller.userController,
                      labelText: "username".tr,
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                  Expanded(
                    flex: 2,
                    child: RadiusTextFormField(
                      controller: controller.pdController,
                      labelText: "password".tr,
                    ),
                  ),
                  controller.statu == LoginStatu.signUp
                      ? const Expanded(flex: 1, child: SizedBox())
                      : const SizedBox(),
                  controller.statu == LoginStatu.signUp
                      ? Expanded(
                          flex: 2,
                          child: RadiusTextFormField(
                            controller: controller.pd2Controller,
                            labelText: "password2".tr,
                          ),
                        )
                      : const SizedBox(),
                  const Expanded(flex: 1, child: SizedBox()),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.statu == LoginStatu.signUp
                            ? controller.toLogin
                            : controller.toSignUp,
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(controller.statu == LoginStatu.signUp
                            ? 'toLogin'.tr
                            : 'toSignup'.tr),
                      ),
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.statu == LoginStatu.signUp
                            ? controller.signUp
                            : controller.login,
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(controller.statu == LoginStatu.signUp
                            ? 'signup'.tr
                            : 'login'.tr),
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }
}

class LoginWindow extends StatelessWidget {
  const LoginWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
        child: _LoginWindow());
  }
}

class LoginDialog extends StatelessWidget {
  const LoginDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: _LoginWindow(),
    );
  }
}
