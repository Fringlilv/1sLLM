import 'package:flutter/material.dart';
import 'package:ones_llm/controller/model.dart';
import 'package:ones_llm/controller/setting.dart';
import 'package:get/get.dart';

class SettingPage extends GetResponsiveView {
  SettingPage({super.key});

  @override
  Widget? builder() {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: Obx(() {
        final modelController = Get.find<ModelController>();
        final settingController = Get.find<SettingController>();
        final keyControllers = { for (final element in modelController.modelProviderMap.entries) element.key : TextEditingController() };
        settingController.fillApiKeyToControllers(keyControllers);
        return ListView(
          children: [
            const Divider(),
            const ListTile(
              dense: true,
              title: Text('Api Key',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...[
              for (final apiKey in keyControllers.entries)
              TextFormField(
                style: const TextStyle(fontSize: 16),
                controller: apiKey.value,
                decoration: InputDecoration(
                  labelText: apiKey.key,
                  labelStyle: TextStyle(fontSize: 16, color: Theme.of(Get.context!).colorScheme.onPrimaryContainer.withAlpha(150)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    // borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(Get.context!).colorScheme.background.withAlpha(150),
                ),
            ),
            ],
            
            const Divider(),
            ListTile(
              dense: true,
              title: Text('theme'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            RadioListTile(
              title: Text('followSystem'.tr),
              value: ThemeMode.system,
              groupValue: settingController.themeMode.value,
              onChanged: (value) {
                settingController.setThemeMode(ThemeMode.system);
              },
            ),
            RadioListTile(
              title: Text('darkMode'.tr),
              value: ThemeMode.dark,
              groupValue: settingController.themeMode.value,
              onChanged: (value) {
                settingController.setThemeMode(ThemeMode.dark);
              },
            ),
            RadioListTile(
              title: Text('whiteMode'.tr),
              value: ThemeMode.light,
              groupValue: settingController.themeMode.value,
              onChanged: (value) {
                settingController.setThemeMode(ThemeMode.light);
              },
            ),
            const Divider(),
            ListTile(
              dense: true,
              title: Text('language'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            RadioListTile(
              title: Text('zh'.tr),
              value: 'zh',
              groupValue: settingController.locale.value.languageCode,
              onChanged: (value) {
                settingController.setLocale(const Locale('zh'));
              },
            ),
            RadioListTile(
              title: Text('en'.tr),
              value: 'en',
              groupValue: settingController.locale.value.languageCode,
              onChanged: (value) {
                settingController.setLocale(const Locale('en'));
              },
            ),
            const Divider(),
            // SwitchListTile(
            //     title: Text(
            //       "useStreamApi".tr,
            //       style: const TextStyle(
            //           fontSize: 12, fontWeight: FontWeight.bold),
            //     ),
            //     value: controller.useStream.value,
            //     onChanged: (value) {
            //       controller.setUseStream(value);
            //     }),
            // const Divider(),
            // SwitchListTile(
            //     title: Text(
            //       "useWebSearch".tr,
            //       style: const TextStyle(
            //           fontSize: 12, fontWeight: FontWeight.bold),
            //     ),
            //     value: controller.useWebSearch.value,
            //     onChanged: (value) {
            //       controller.setUseWebSearch(value);
            //     }),
            // const Divider(),
            // DropdownButtonFormField(
            //   value: controller.llm.value,
            //   decoration: InputDecoration(
            //     labelText: 'llmHint'.tr,
            //     hintText: 'llmHint'.tr,
            //     labelStyle: TextStyle(
            //         fontWeight: FontWeight.bold,
            //         color: Theme.of(Get.context!).colorScheme.primary),
            //     floatingLabelBehavior: FloatingLabelBehavior.auto,
            //     contentPadding:
            //         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(5),
            //       borderSide: BorderSide.none,
            //     ),
            //     filled: true,
            //   ),
            //   items: <String>['OpenAI']
            //       .map<DropdownMenuItem<String>>((String value) {
            //     return DropdownMenuItem<String>(
            //       value: value,
            //       child: Text(
            //         value,
            //       ),
            //     );
            //   }).toList(),
            //   onChanged: (String? newValue) {
            //     if (newValue == null) return;
            //     controller.setLlm(newValue);
            //   },
            // ),
            // const Divider(),
            // controller.llm.value == "You"
            //     ? TextFormField(
            //         initialValue: controller.youCode.value,
            //         decoration: InputDecoration(
            //           labelText: 'youCode'.tr,
            //           hintText: 'youCodeTips'.tr,
            //           labelStyle: TextStyle(
            //               fontWeight: FontWeight.bold,
            //               color: Theme.of(Get.context!).colorScheme.primary),
            //           floatingLabelBehavior: FloatingLabelBehavior.auto,
            //           contentPadding: const EdgeInsets.symmetric(
            //               horizontal: 16, vertical: 8),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(5),
            //             borderSide: BorderSide.none,
            //           ),
            //           filled: true,
            //         ),
            //         autovalidateMode: AutovalidateMode.always,
            //         maxLines: 1,
            //         onChanged: (value) => {
            //           controller.setYouCode(value),
            //         },
            //         onEditingComplete: () {},
            //         onFieldSubmitted: (value) {
            //           controller.setYouCode(value);
            //         },
            //       )
            //     : const SizedBox(),
            // const SizedBox(
            //   height: 20,
            // ),
            // controller.llm.value == "OpenAI"
            //     ? TextFormField(
            //         initialValue: controller.openAiKey.value,
            //         decoration: InputDecoration(
            //           labelText: 'enterKey'.tr,
            //           hintText: 'enterKey'.tr,
            //           labelStyle: TextStyle(
            //               fontWeight: FontWeight.bold,
            //               color: Theme.of(Get.context!).colorScheme.primary),
            //           floatingLabelBehavior: FloatingLabelBehavior.auto,
            //           contentPadding: const EdgeInsets.symmetric(
            //               horizontal: 16, vertical: 8),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(5),
            //             borderSide: BorderSide.none,
            //           ),
            //           filled: true,
            //           suffixIcon: IconButton(
            //             icon: Icon(
            //               Icons.remove_red_eye,
            //               color: controller.isObscure.value
            //                   ? Colors.grey
            //                   : Colors.blue,
            //             ),
            //             onPressed: () {
            //               controller.isObscure.value =
            //                   !controller.isObscure.value;
            //             },
            //           ),
            //         ),
            //         autovalidateMode: AutovalidateMode.always,
            //         maxLines: 1,
            //         onChanged: (value) => {
            //           controller.setOpenAiKey(value),
            //           OpenAI.apiKey = value,
            //         },
            //         onFieldSubmitted: (value) {
            //           controller.setOpenAiKey(value);
            //         },
            //         obscureText: controller.isObscure.value,
            //       )
            //     : const SizedBox(),
            // controller.llm.value == "OpenAI"
            //     ? const SizedBox(
            //         height: 20,
            //       )
            //     : const SizedBox(),
            // controller.llm.value == "OpenAI" || controller.llm.value == "You"
            //     ? DropdownButtonFormField(
            //         value: controller.openAiBaseUrl.value,
            //         isExpanded: true,
            //         decoration: InputDecoration(
            //           labelText: 'setProxyUrlTips'.tr,
            //           hintText: 'setProxyUrlTips'.tr,
            //           labelStyle: TextStyle(
            //               fontWeight: FontWeight.bold,
            //               color: Theme.of(Get.context!).colorScheme.primary),
            //           floatingLabelBehavior: FloatingLabelBehavior.auto,
            //           contentPadding: const EdgeInsets.symmetric(
            //               horizontal: 16, vertical: 8),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(5),
            //             borderSide: BorderSide.none,
            //           ),
            //           filled: true,
            //         ),
            //         items: <String>[
            //           'https://api.openai-proxy.com',
            //           'https://api.openai.com',
            //           'https://api.wgpt.in'
            //         ].map<DropdownMenuItem<String>>((String value) {
            //           return DropdownMenuItem<String>(
            //             value: value,
            //             child: Text(
            //               value, // 缩短显示文本
            //               overflow: TextOverflow.ellipsis, // 超出长度省略号显示
            //             ),
            //           );
            //         }).toList(),
            //         onChanged: (String? newValue) {
            //           if (newValue == null) return;
            //           controller.setOpenAiBaseUrl(newValue);
            //         },
            //       )
            //     : const SizedBox(),
            // controller.llm.value == "OpenAI" || controller.llm.value == "You"
            //     ? const SizedBox(
            //         height: 20,
            //       )
            //     : const SizedBox(),
            // controller.llm.value == "OpenAI" || controller.llm.value == "You"
            //     ? DropdownButtonFormField(
            //         value: controller.gptModel.value,
            //         isExpanded: true,
            //         decoration: InputDecoration(
            //           labelText: 'gptModel'.tr,
            //           hintText: 'gptModel'.tr,
            //           labelStyle: TextStyle(
            //               fontWeight: FontWeight.bold,
            //               color: Theme.of(Get.context!).colorScheme.primary),
            //           floatingLabelBehavior: FloatingLabelBehavior.auto,
            //           contentPadding: const EdgeInsets.symmetric(
            //               horizontal: 16, vertical: 8),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(5),
            //             borderSide: BorderSide.none,
            //           ),
            //           filled: true,
            //         ),
            //         items: <String>[
            //           'gpt-3.5-turbo',
            //           'gpt-3.5-turbo-16k',
            //           'gpt-4',
            //           'gpt-4-0314',
            //         ].map<DropdownMenuItem<String>>((String value) {
            //           return DropdownMenuItem<String>(
            //             value: value,
            //             child: Text(value),
            //           );
            //         }).toList(),
            //         onChanged: (String? newValue) {
            //           if (newValue == null) return;
            //           controller.setGptModel(newValue);
            //         })
            //     : const SizedBox(),
          ],
        );}
      ),
    );
  }
}
