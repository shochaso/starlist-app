import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../errors/app_exceptions.dart';
import '../config/app_config.dart';

/// APIクライアントクラス
/// 
/// HTTPリクエストの送信と応答の処理を担当します。
class ApiClient {
  final Dio _dio;
  
  /// コンストラクタ
  ApiClient({Dio? dio}) : _dio = dio ?? Dio() {
    _setupInterceptors();
  }
  
  /// インターセプターの設定
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // リクエストのログ出力（デバッグモードのみ）
          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
            print('REQUEST HEADERS: ${options.headers}');
            print('REQUEST DATA: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // レスポンスのログ出力（デバッグモードのみ）
          if (kDebugMode) {
            print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
            print('RESPONSE DATA: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // エラーのログ出力（デバッグモードのみ）
          if (kDebugMode) {
            print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
            print('ERROR MESSAGE: ${e.message}');
            print('ERROR DATA: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }
  
  /// 認証トークンの設定
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  /// 認証トークンのクリア
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
  
  /// GETリクエストの送信
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// POSTリクエストの送信
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// PUTリクエストの送信
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// DELETEリクエストの送信
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// PATCHリクエストの送信
  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// エラーハンドリング
  AppException _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException('接続がタイムアウトしました', details: error);
          
        case DioExceptionType.badCertificate:
          return NetworkException('SSL証明書の検証に失敗しました', details: error);
          
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          
          String message = 'サーバーエラーが発生しました';
          String? code;
          
          if (data is Map<String, dynamic>) {
            message = data['message'] ?? message;
            code = data['code']?.toString();
          } else if (data is String) {
            try {
              final jsonData = json.decode(data);
              if (jsonData is Map<String, dynamic>) {
                message = jsonData['message'] ?? message;
                code = jsonData['code']?.toString();
              }
            } catch (_) {
              // JSONデコードに失敗した場合は何もしない
            }
          }
          
          if (statusCode == 401 || statusCode == 403) {
            return AuthException(message, code: code, details: error);
          } else if (statusCode == 404) {
            return NotFoundException(message, code: code, details: error);
          } else if (statusCode! >= 500) {
            return ServerException(message, code: code, details: error);
          } else {
            return ApiException(message, statusCode: statusCode, code: code, details: error);
          }
          
        case DioExceptionType.connectionError:
          return NetworkException('ネットワーク接続エラーが発生しました', details: error);
          
        case DioExceptionType.cancel:
          return ApiException('リクエストがキャンセルされました', details: error);
          
        case DioExceptionType.unknown:
        default:
          if (error.error is SocketException) {
            return NetworkException('ネットワーク接続エラーが発生しました', details: error);
          }
          return UnexpectedException('予期せぬエラーが発生しました', details: error);
      }
    }
    
    return UnexpectedException('予期せぬエラーが発生しました', details: error);
  }
}