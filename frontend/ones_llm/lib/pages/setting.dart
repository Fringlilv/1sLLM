import 'package:flutter/material.dart';
import 'package:ones_llm/components/common/text_form.dart';
import 'package:ones_llm/controller/model.dart';
import 'package:ones_llm/controller/setting.dart';
import 'package:get/get.dart';

class SettingPage extends GetResponsiveView {
  SettingPage({super.key});
  // final modelController = Get.find<ModelController>();
  // final controller = Get.find<SettingController>();
  final keyControllers = {
    for (final element in Get.find<ModelController>().modelProviderMap.keys)
      element: TextEditingController()
  };

  @override
  Widget? builder() {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: GetBuilder<SettingController>(
          init: SettingController(),
          builder: (controller) {
            controller.fillApiKeyToControllers(keyControllers);
            return ListView(
              children: [
                const Divider(),
                ListTile(
                  dense: true,
                  title: Text('Api Key',
                      style: Theme.of(Get.context!).textTheme.titleLarge),
                ),
                ...[
                  for (final apiKey in keyControllers.entries)
                    RadiusTextFormField(
                      controller: apiKey.value,
                      labelText: apiKey.key,
                    )
                ],
                ElevatedButton(
                    onPressed: () =>
                        controller.setApiKeyFromControllers(keyControllers),
                    child: Text('updateKey'.tr)),
                const Divider(),
                ListTile(
                  dense: true,
                  title: Text('theme'.tr,
                      style: Theme.of(Get.context!).textTheme.titleLarge),
                ),
                RadioListTile(
                  title: Text('followSystem'.tr),
                  value: ThemeMode.system,
                  groupValue: controller.themeMode.value,
                  onChanged: (value) {
                    controller.setThemeMode(ThemeMode.system);
                  },
                ),
                RadioListTile(
                  title: Text('darkMode'.tr),
                  value: ThemeMode.dark,
                  groupValue: controller.themeMode.value,
                  onChanged: (value) {
                    controller.setThemeMode(ThemeMode.dark);
                  },
                ),
                RadioListTile(
                  title: Text('whiteMode'.tr),
                  value: ThemeMode.light,
                  groupValue: controller.themeMode.value,
                  onChanged: (value) {
                    controller.setThemeMode(ThemeMode.light);
                  },
                ),
                const Divider(),
                ListTile(
                  dense: true,
                  title: Text('language'.tr,
                      style: Theme.of(Get.context!).textTheme.titleLarge),
                ),
                RadioListTile(
                  title: Text('zh'.tr),
                  value: 'zh',
                  groupValue: controller.localeText,
                  onChanged: (value) {
                    controller.setLocale(const Locale('zh'));
                  },
                ),
                RadioListTile(
                  title: Text('en'.tr),
                  value: 'en',
                  groupValue: controller.localeText,
                  onChanged: (value) {
                    controller.setLocale(const Locale('en'));
                  },
                ),
                ...controller.isLogin
                    ? [
                        const Divider(),
                        ElevatedButton(
                          onPressed: controller.logout,
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Get.context!.theme.colorScheme.error)),
                          child: Text('logout'.tr),
                        ),
                      ]
                    : []
              ],
            );
          }),
    );
  }
}
