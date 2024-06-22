import 'package:flutter/material.dart';
import 'package:ones_llm/components/common/radius_widgets.dart';
import 'package:ones_llm/controller/model.dart';
import 'package:ones_llm/controller/setting.dart';
import 'package:get/get.dart';

class SettingPage extends GetResponsiveView {
  SettingPage({super.key});
  // final modelController = Get.find<ModelController>();
  // final controller = Get.find<SettingController>();
  final keyControllers = { for (final element in Get.find<ModelController>().modelProviderMap.keys) element : TextEditingController() };

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
              RadiusTextFormField(controller: apiKey.value, labelText: apiKey.key,)
            ],
            ElevatedButton(onPressed: ()=>controller.setApiKeyFromControllers(keyControllers), child: Text('updataKey'.tr)),
            
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
            ...controller.isLogin?[
              const Divider(),
              ElevatedButton(
                onPressed: controller.logout,
                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Get.context!.theme.colorScheme.error)), 
                child: Text('logout'.tr),
              ),
            ]:[]

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
