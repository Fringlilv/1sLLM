import 'package:dio/dio.dart';
import 'package:get/get.dart';

final errorInterceptor = InterceptorsWrapper(
  onError: (error, handler) async {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        // 连接超时处理
        break;
      case DioExceptionType.sendTimeout:
        // 发送超时处理
        break;
      case DioExceptionType.receiveTimeout:
        // 接收超时处理
        break;
      case DioExceptionType.badResponse:
        // 服务器响应错误处理
        switch (error.response!.statusCode) {
          case 403:
            Get.offNamed('/login');
        }
        break;
      case DioExceptionType.cancel:
        // 请求取消处理
        break;
      case DioExceptionType.connectionError:
        // 连接错误处理
        break;
      case DioExceptionType.unknown:
      default:
        // 其他错误处理
        break;
    }
  },
);
