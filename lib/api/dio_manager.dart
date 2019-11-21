import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_wanandroid/api/api_service.dart';
import 'package:flutter_wanandroid/api/http_code.dart';

import '../global_config.dart';

class DioManager {
  static DioManager _instance;

  static DioManager getInstance() {
    if (_instance == null) {
      _instance = DioManager();
    }

    return _instance;
  }

  Dio _dio = Dio();

  PersistCookieJar _cookieJar;

  DioManager() {
    _dio.options.headers = {};

    _dio.options.baseUrl = ApiService.base;
    _dio.options.connectTimeout = 5000;
    _dio.options.receiveTimeout = 5000;
    _dio.interceptors.add(LogInterceptor());

    String path =
        "/data/user/0/com.hao.flutter_wanandroid/app_flutter/.cookies";
    _cookieJar = PersistCookieJar(dir: path);
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  clearCookies() {
    _cookieJar?.deleteAll();
  }

  List<Cookie> getCookies() {
    List<Cookie> results = _cookieJar
        .loadForRequest(Uri.parse(ApiService.base + ApiService.login));
    return results;
  }

  get(String url, Function successCallBack,
      {Map<String, dynamic> params, Function errorCallBack}) async {
    _request(url, "get", successCallBack,
        params: params, errorCallBack: errorCallBack);
  }

  post(String url, Function successCallBack,
      {Map<String, dynamic> params, Function errorCallBack}) async {
    _request(url, "post", successCallBack,
        params: params, errorCallBack: errorCallBack);
  }

  _request(
    String url,
    String method,
    Function successCallBack, {
    Map<String, dynamic> params,
    Function errorCallBack,
  }) async {
    Response response;

    try {
      if ("get" == method) {
        response = await _dio.get(url, queryParameters: params);
      } else if ("post" == method) {
        response = await _dio.post(url, queryParameters: params);
      }
    } on DioError catch (error) {
      Response errorResponse;

      if (error.response != null) {
        errorResponse = error.response;
      } else {
        errorResponse = Response(statusCode: HttpCode.HTTP_ERROR);
      }

      if (error.type == DioErrorType.CONNECT_TIMEOUT) {
        errorResponse.statusCode = HttpCode.HTTP_CONNECT_TIMEOUT;
      } else if (error.type == DioErrorType.RECEIVE_TIMEOUT) {
        errorResponse.statusCode = HttpCode.HTTP_RECEIVE_TIMEOUT;
      }

      if (GlobalConfig.isDebug) {
        print("请求异常：" + error.toString());
        print("请求异常url：" + url);
      }

      _error(errorCallBack, response.statusCode, error.message);
      return "";
    }

    if (GlobalConfig.isDebug) {
      print("请求url：" + url);
      if (params != null) {
        print("请求参数：" + params.toString());
      }
      if (response != null) {
        print("请求结果：" + response.toString());
      }
    }

    String dataStr = json.encode(response.data);
    Map<String, dynamic> dataMap = json.decode(dataStr);
    if (dataMap == null || dataMap["errorCode"] != HttpCode.SUCCESS) {
      _error(errorCallBack, dataMap["errorCode"], dataMap["errorMsg"]);
    } else {
      successCallBack(dataMap["data"]);
    }
  }

  _error(Function errorCallBack, int errorCode, String errorMsg) {
    if (errorCallBack != null) {
      errorCallBack(errorCode, errorMsg);
    }
  }
}
