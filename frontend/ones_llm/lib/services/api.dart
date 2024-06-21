import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/browser.dart'
    if (dart.library.io) 'package:ones_llm/crossPlatform/fakeDioBrowser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart' hide Response;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:ones_llm/services/api/error.dart';

class Conversation {
  String name;
  String description;
  String id;

  Conversation(
      {required this.name, required this.description, required this.id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Message {
  int? id;
  String conversationId;
  String role;
  String text;
  String? modelName;
  bool error;
  Message(
      {this.id,
      required this.conversationId,
      required this.text,
      required this.role,
      this.modelName,
      this.error = false});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': conversationId,
      'role': role,
      'text': text,
    };
  }

  @override
  String toString() {
    return 'Message{id: $id, conversationId: $conversationId, role: $role, text: $text}';
  }
}

enum LoginResponse { success, badUserOrPassed, unknown }

class ApiService extends GetxService {
  late Dio _dio;
  final baseUrl = 'http://localhost:8000';

  @override
  void onInit() async {
    super.onInit();
    _dio = Dio();
    if (kIsWeb) {
      var adapter = BrowserHttpClientAdapter(withCredentials: true);
      _dio.httpClientAdapter = adapter;
    } else {
      _dio.interceptors.add(CookieManager(PersistCookieJar()));
    }
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: 10000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 10000);
    _dio.options.headers["Accept"] = "application/json";
    _dio.interceptors.add(LogInterceptor(responseBody: true));
    _dio.interceptors.add(errorInterceptor);
  }

  Future<T> _get<T>(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress}) async {
    try {
      final response = await _dio.get<String>(
        path,
        queryParameters: queryParameters?.map(
            (key, value) => MapEntry(key, base64Encode(utf8.encode(value is String?value:jsonEncode(value))))),
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return jsonDecode(response.data!) as T;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<Response<T>> _post<T>(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters?.map(
            (key, value) => MapEntry(key, base64Encode(utf8.encode(value)))),
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<LoginResponse> login(username, password) async {
    final response = await _get<String>('/user/login',
        queryParameters: {'user': username, 'pd': password});
    switch (response) {
      case 'success':
        return LoginResponse.success;
      case 'invalid_username_or_password':
        return LoginResponse.badUserOrPassed;
      default:
        return LoginResponse.unknown;
    }
  }

  Future<LoginResponse> logout() async {
    final response = await _get<String>('/user/logout');
    switch (response) {
      case 'success':
        return LoginResponse.success;
      default:
        return LoginResponse.unknown;
    }
  }

  Future<LoginResponse> register() async {
    final response = await _get<String>('/user/logout');
    switch (response) {
      case 'success':
        return LoginResponse.success;
      default:
        return LoginResponse.unknown;
    }
  }

  Future<Map<String, String>> getAllApiKey() async {
    final response = await _get<Map<String, dynamic>>(
      '/api/list',
    );
    return Map.from(response);
  }

  Future<bool> setApiKey(String provider, String key) async {
    final response = await _get<String>('/api/add', queryParameters: {
      'name': provider,
      'key': key,
    });
    return true;
  }

  Future<List<String>> getAllProviders() async {
    final response = await _get<List<dynamic>>(
      '/api/providers',
    );
    return response.cast();
  }

  Future<Map<String, List<String>>> getAvailableProviderModels() async {
    final response = await _get<Map<String, dynamic>>(
      '/api/models',
    );
    final Map<String, List<String>> res = {};
    for (var element in response.entries) {
      res[element.key] = (element.value as List<dynamic>).map((item) => item as String).toList();
    }
    return res;
  }

  Future<List<Conversation>> getConversations() async {
    final response = await _get<Map<String, dynamic>>(
      '/chat/list',
    );
    List<Conversation> convList = [];
    response.forEach((key, value) {
      convList.add(Conversation(
          name: value['chat_title'],
          description: value['chat_title'],
          id: key));
    });
    return convList;
  }

  Future<String> addConversation() async {
    final response = await _get<String>(
      '/chat/new',
    );
    return response;
  }

  Future<bool> renameConversation(conversationId, newName) async {
    final response = await _get<String>('/chat/title',
        queryParameters: {'cid': conversationId, 'title': newName});
    return true;
  }

  Future<bool> deleteConversation(conversationId) async {
    final response = await _get<String>('/chat/del',
        queryParameters: {'cid': conversationId});
    return true;
  }

  Future<Map<String, List<Message>>> getMessages(
    conversationId,
  ) async {
    final response = await _get<Map<String, dynamic>>('/chat/get',
        queryParameters: {'cid': conversationId});
    List<Message> messageList = [];
    response['msg_list'].forEach((element) {
      messageList.add(Message(
          conversationId: conversationId,
          text: element['content'],
          role: element['role']));
    });
    List<Message> tempMessageList = [];
    if (response['recv_msg_tmp'] is Map) {
      response['recv_msg_tmp'].forEach((k, v) {
        tempMessageList.add(Message(
            conversationId: conversationId,
            text: v['content'],
            role: v['role']));
      });
    }
    return {"msgList": messageList, "tmpList": tempMessageList};
  }

  Future<List<Message>> sendMessage(
    String conversationId,
    String text,
    Map<String, List<String>> providerModels,
  ) async {
    final response = await _get<Map<String, dynamic>>('/chat/gen',
        queryParameters: {
          'cid': conversationId,
          'p': text,
          'provider_models': providerModels
        });
    List<Message> messageList = [];
    response.forEach((key, value) {
      switch (value['code']) {
        case 1:
          messageList.add(Message(
              conversationId: conversationId,
              modelName: key,
              text: value['content'],
              role: value['role']));
          break;
        case 0:
          messageList.add(Message(
              conversationId: conversationId,
              modelName: key,
              text: value['content'],
              role: value['role'],
              error: true));
          break;
      }
    });
    return messageList;
  }

  Future<bool> selectMessages(
    String conversationId,
    String model,
  ) async {
    final response = await _get<String>('/chat/sel',
        queryParameters: {'cid': conversationId, 'name': model});
    return true;
  }
}
