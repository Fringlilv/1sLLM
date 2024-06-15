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
  bool available;
  Map<String, Model> modelMap = {};
  ModelProvider({required this.name, required this.available});
}

class ModelController extends GetxController {
  final modelProviderMap = <String, ModelProvider>{}.obs;
  // final availabelModelList = <String>['gpt-3.5-turbo', 'gpt-3.5-turbo-ca', 'gpt-4-turbo'].obs;
  // final selectedModelList = <String>['gpt-3.5-turbo', 'gpt-3.5-turbo-ca'].obs;

  final ApiService api = Get.find();

  @override
  void onInit() {
    super.onInit();
    getAllModels();
  }

  void getAllModels() async {
    final modelData = await api.getAllModels();
    modelData.forEach((key, elements) {
      modelProviderMap[key] ??= ModelProvider(name: key, available: false);

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
    final keysToRemove = modelProviderMap.keys
        .where((providerKey) => !modelData.containsKey(providerKey))
        .toList();
    for (final key in keysToRemove) {
      modelProviderMap.remove(key);
    }
    update();
  }

  void getAvailableModels() async {
    final providerAvalible = await api.getAvailableProviders();
    for (final element in providerAvalible) {
      modelProviderMap[element]?.available = true;
    }
    update();
  }

  void toggleSelectModel(String provider, String model) {
    modelProviderMap[provider]?.modelMap[model]?.selected =
        !modelProviderMap[provider]!.modelMap[model]!.selected;
    update();
  }

  List<String> selected() {
    final l = <String>[];
    for (final element in modelProviderMap.values) {
      for (final model in element.modelMap.values) {
        if (model.selected) l.add(model.name);
      }
    }
    return l;
  }
}
