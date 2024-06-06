import 'dart:js_interop';
import 'package:crypto/crypto.dart';
import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
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
  Role role;
  String text;
  Message(
      {this.id,
      required this.conversationId,
      required this.text,
      required this.role});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': conversationId,
      'role': role.index,
      'text': text,
    };
  }

  @override
  String toString() {
    return 'Message{id: $id, conversationId: $conversationId, role: $role, text: $text}';
  }
}

enum Role {
  system,
  user,
  assistant,
}

enum LoginResponse {
  success,
  badUser,
  badPasswd,
  unknown
}

class ApiService extends GetxService {
  late Dio _dio;
  final baseUrl = 'localhost:56789';
  String? loginUser;

  @override
  void onInit() async {
    super.onInit();
    _dio = Dio();
    // var adapter = BrowserHttpClientAdapter(withCredentials: true);
    // _dio.httpClientAdapter = adapter;
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: 5000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 3000);
    _dio.interceptors.add(LogInterceptor(responseBody: true));
    _dio.interceptors.add(CookieManager(PersistCookieJar()));
  }

  Future<Response<T>> _get<T>(String path,
    {Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress}
  ) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
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
      switch(response.data){
        case 'success':
          loginUser = username;
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

  Future<List<Conversation>> getConversations() async {
    List<Conversation> convList = [];
    try {
      final response = await _get<Map<String, String>>(
        '/chat/list',
      );
      response.data!.forEach((key, value) {
        convList.add(Conversation(name: value, description: value, id: key));
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
      return response.data!;
    } on DioException catch (_) {
      // 处理错误，例如自动重试
      rethrow;
    }
  }

  Future<List<Message>> renameConversation<T>(
    uuid,
    {required name,}
  ) async {
    List<Message> message_list = [];
    message_list.add(Message(conversationId: uuid, text: 'text', role: Role.user));
    return message_list;
    // try {
    //   final response = await _dio.post<T>(
    //     path,
    //     data: data,
    //     queryParameters: queryParameters,
    //     options: options,
    //     cancelToken: cancelToken,
    //     onSendProgress: onSendProgress,
    //     onReceiveProgress: onReceiveProgress,
    //   );
    //   return Conversation(name: name, description: description, uuid: uuid);
    // } on DioException catch (_) {
    //   // 处理错误，例如自动重试
    //   rethrow;
    // }
  }

  Future<List<Message>> deleteConversation<T>(
    uuid
  ) async {
    List<Message> message_list = [];
    message_list.add(Message(conversationId: uuid, text: 'text', role: Role.user));
    return message_list;
    // try {
    //   final response = await _dio.post<T>(
    //     path,
    //     data: data,
    //     queryParameters: queryParameters,
    //     options: options,
    //     cancelToken: cancelToken,
    //     onSendProgress: onSendProgress,
    //     onReceiveProgress: onReceiveProgress,
    //   );
    //   return Conversation(name: name, description: description, uuid: uuid);
    // } on DioException catch (_) {
    //   // 处理错误，例如自动重试
    //   rethrow;
    // }
  }

  Future<List<Message>> getMessages(
    conversationId,
  ) async {
    List<Message> message_list = [];
    message_list.add(Message(conversationId: conversationId, text: 'text', role: Role.user));
    return message_list;
  }

  Future<List<Message>> sendMessage(
    id,
    text,
  ) async {
    List<Message> message_list = [];
    message_list.add(Message(conversationId: id, text: 'text', role: Role.user));
    return message_list;
  }

  Future<bool> selectMessages(
    text,
    {required uuid,}
  ) async {
    List<Message> message_list = [];
    message_list.add(Message(conversationId: uuid, text: 'text', role: Role.user));
    return true;
  }

}
