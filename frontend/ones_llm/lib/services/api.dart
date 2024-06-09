import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/browser.dart' if (dart.library.io) 'package:ones_llm/crossPlatform/fakeDioBrowser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart' hide Response;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

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
  Message(
      {this.id,
      required this.conversationId,
      required this.text,
      required this.role,
      this.modelName});
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

enum LoginResponse {
  success,
  badUser,
  badPasswd,
  unknown
}

class ApiService extends GetxService {
  late Dio _dio;
  final baseUrl = 'http://localhost:8000';

  @override
  void onInit() async {
    super.onInit();
    _dio = Dio();
    if (kIsWeb){
      var adapter = BrowserHttpClientAdapter(withCredentials: true);
      _dio.httpClientAdapter = adapter;
    }
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: 10000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 10000);
    _dio.options.headers["Accept"] = "application/json";
    // _dio.options.headers["X-Requested-With"] = "XMLHttpRequest";
    // _dio.options.headers["Access-Control-Allow-Origin"] = "*";
    _dio.interceptors.add(LogInterceptor(responseBody: true));
    _dio.interceptors.add(CookieManager(PersistCookieJar()));
  }

  Future<T> _get<T>(String path,
    {Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress}
  ) async {
    try {
      final response = await _dio.get<String>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return jsonDecode(response.data!) as T;
    } on DioException catch (_) {
      // 处理错误，例如自动重试
      rethrow;
    }
  }

  Future<Response<T>> _post<T>(String path,
    {dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress}
  ) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (_) {
      // 处理错误，例如自动重试
      rethrow;
    }
  }

  Future<LoginResponse> login(username, password) async {
    try {
      final response = await _get<String>(
        '/login',
        queryParameters: {'user': username, 'pd': password}
      );
      print(response);
      switch(response){
        case 'success':
          return LoginResponse.success;
        default:
          return LoginResponse.unknown;
      }
    } on DioException catch (_) {
      // 处理错误，例如自动重试
      rethrow;
    }
  }

  Future<LoginResponse> logout() async {
    // try {
      // final response = await _get<String>(
      //   '/login',
      //   queryParameters: {'user': username, 'pd': password}
      // );
      // switch(response.data){
      //   case 'success':
      //     loginUser = username;
      //     return LoginResponse.success;
      //   default:
          return LoginResponse.unknown;
    //   }
    // } on DioException catch (_) {
    //   // 处理错误，例如自动重试
    //   rethrow;
    // }
  }

  Future<List<String>> getModelList() async {
    try {
      // final response = await _get<Map<String, dynamic>>(
      //   '/chat/list',
      // );
      // List<Conversation> convList = [];
      // response.forEach((key, value) {
      //   convList.add(Conversation(name: value['chat_title'], description: value['chat_title'], id: key));
      // });
      return ['gpt-3.5-turbo-ca'];
    } on DioException catch (_) {
      // 处理错误，例如自动重试
      rethrow;
    }
  }

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _get<Map<String, dynamic>>(
        '/chat/list',
      );
      List<Conversation> convList = [];
      response.forEach((key, value) {
        convList.add(Conversation(name: value['chat_title'], description: value['chat_title'], id: key));
      });
      return convList;
    } on DioException catch (_) {
      // 处理错误，例如自动重试
      rethrow;
    }
  }

  Future<String> addConversation() async {
    try {
      final response = await _get<String>(
        '/chat/new',
      );
      return response;
    } on DioException catch (_) {
      // 处理错误，例如自动重试
      rethrow;
    }
  }

  Future<bool> renameConversation(
    conversationId,
    newName
  ) async {
    try {
      final response = await _get<String>(
        '/chat/title',
        queryParameters: {'cid': conversationId, 'title': newName}
      );
      return true;
    } on DioException catch (_) {
      // 处理错误，例如自动重试
      rethrow;
    }
  }

  Future<bool> deleteConversation(
    conversationId
  ) async {
    try {
      final response = await _get<String>(
        '/chat/del',
        queryParameters: {'cid': conversationId}
      );
      return true;
    } on DioException catch (_) {
      // 处理错误，例如自动重试
      rethrow;
    }
  }

  Future<Map<String, List<Message>>> getMessages(
    conversationId,
  ) async {
    try {
      final response = await _get<Map<String, dynamic>>(
        '/chat/get',
        queryParameters: {'cid': conversationId}
      );
      List<Message> messageList = [];
      response['msg_list'].forEach((element) {
        messageList.add(Message(conversationId: conversationId, text: element['content'], role: element['role']));
      });
      List<Message> tempMessageList = [];
      if (response['recv_msg_tmp'] is Map) {
        response['recv_msg_tmp'].forEach((k, v) {
          tempMessageList.add(Message(conversationId: conversationId, text: v['content'], role: v['role']));
        });
      }
      return {"msgList": messageList, "tmpList": tempMessageList};
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<List<Message>> sendMessage(
    String conversationId,
    String text,
    List<String> modelList,
  ) async {
     try {
      final response = await _get<Map<String, dynamic>>(
        '/chat/gen',
        queryParameters: {'cid': conversationId, 'p': base64Encode(utf8.encode(text)), 'ml': base64Encode(utf8.encode(jsonEncode(modelList)))}
      );
      List<Message> messageList = [];
      response.forEach((key, value) {
        messageList.add(Message(conversationId: conversationId, modelName: key, text: value['content'], role: value['role']));
      });
      return messageList;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<bool> selectMessages(
    String conversationId,
    String model,
  ) async {
    try {
      final response = await _get<String>(
        '/chat/sel',
        queryParameters: {'cid': conversationId, 'name': base64Encode(utf8.encode(model))}
      );
      return true;
    } on DioException catch (_) {
      rethrow;
    }
  }

}
