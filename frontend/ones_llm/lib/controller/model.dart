import 'package:get/get.dart';

import 'package:ones_llm/services/api.dart';

class Model {
  String name;
  bool selected;
  // bool available;
  Model({required this.name, required this.selected});
}

class ModelProvider {
  String name;
  // bool available = false;
  Map<String, Model> modelMap = {};
  ModelProvider({required this.name});
}

class ModelController extends GetxController {
  final modelProviderMap = <String, ModelProvider>{}.obs;

  final ApiService api = Get.find();

  @override
  void onInit() {
    super.onInit();
    getAllProviders();
  }

  void getAllProviders() async {
    final modelData = await api.getAllProviders();
    for (var elements in modelData) {
      modelProviderMap[elements] ??= ModelProvider(name: elements);
    }
    final keysToRemove = modelProviderMap.keys
        .where((providerKey) => !modelData.contains(providerKey))
        .toList();
    for (final key in keysToRemove) {
      modelProviderMap.remove(key);
    }
    update();
  }

  void getAvailableProviderModels() async {
    final modelData = await api.getAvailableProviderModels();
    modelData.forEach((key, elements) {
      modelProviderMap[key] ??= ModelProvider(name: key);

      final existingNames = modelProviderMap[key]!.modelMap.keys.toSet();
      final uniqueElements = elements.toSet().difference(existingNames);
      final removedNames = existingNames.difference(elements.toSet());

      for (final element in uniqueElements) {
        modelProviderMap[key]!.modelMap[element] =
            Model(name: element, selected: false);
      }

      for (final modelName in removedNames) {
        modelProviderMap[key]!.modelMap.remove(modelName);
      }
    });
    update();
  }

  void toggleSelectModel(String provider, String model) {
    modelProviderMap[provider]?.modelMap[model]?.selected =
        !modelProviderMap[provider]!.modelMap[model]!.selected;
    update();
  }

  Map<String, List<String>> selected() {
    final l = {for (var element in modelProviderMap.keys) element: <String>[]};
    for (final element in modelProviderMap.values) {
      for (final model in element.modelMap.values) {
        if (model.selected) l[element.name]?.add(model.name);
      }
    }
    l.removeWhere((k, v) => v.isEmpty);
    return l;
  }
}
