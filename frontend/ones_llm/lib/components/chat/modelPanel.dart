import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:get/get.dart';
import 'package:ones_llm/controller/model.dart';

class ModelSelectWindow extends StatelessWidget {
  // final List<Map<String, dynamic>> groups;
  // final Function(int groupIndex, int optionIndex) onOptionTap;

  const ModelSelectWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ModelController>(builder: (controller) {
      return SingleChildScrollView(
        child: Column(
          children: controller.modelProviderMap.values.map((provider) {
            return ExpandablePanel(
              header: ListTile(
                title: Text(provider.name),
                // subtitle: Text(provider.name),
              ),
              collapsed: SizedBox(),
              expanded: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 5.0,
                  children: provider.modelMap.values.map((model) {
                    return ElevatedButton(
                      onPressed: () => controller.toggleSelectModel(
                          provider.name, model.name),
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              model.selected
                                  ? Colors.blue
                                  : Colors.grey),
                          shadowColor: const MaterialStatePropertyAll(
                              Colors.transparent), 
                          elevation: const MaterialStatePropertyAll(
                              0), 
                          shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          padding: const MaterialStatePropertyAll(
                              EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8))),
                      child: Text(model.name,
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center),
                    );
                  }).toList(),
                ),
              ),
              theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center),
            );
          }).toList(),
        ),
      );
    });
  }

// Widget buildButton(String text, int groupIndex) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 3.0),
//       child: ElevatedButton(
//         onPressed: () => onOptionTap(groupIndex, groupIndex), // 参数保持一致
//         style: ButtonStyle(
//           backgroundColor: MaterialStatePropertyAll(Colors.grey), // 设置统一的背景颜色，这里以灰色为例
//           shadowColor: MaterialStatePropertyAll(Colors.transparent), // 移除阴影以模拟无边框效果
//           elevation: MaterialStatePropertyAll(0), // 设置elevation为0以去除阴影效果
//           shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
//           padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 12, horizontal: 8))
//         ),
//         child: Text(text, style: TextStyle(color: Colors.white), textAlign: TextAlign.center), // 文字颜色需调整以确保在深色背景下可见
//       ),
//     );
// }
}
