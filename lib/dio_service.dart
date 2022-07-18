import 'dart:convert';

import 'package:dio/dio.dart';

class DioService {

  /* Base Url */
  static String baseUrl = "https://sso.egov.uz";

  /* Header */
  static Map<String, String> headers() {
    Map<String, String> headers = {
      'Content-type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    return headers;
  }

  /* Base options */
  static final BaseOptions _baseDioOptions = BaseOptions(
    baseUrl: baseUrl,
    headers: headers(),
  );

  static Dio dio = Dio(_baseDioOptions);

  /* Dio Requests */
  static Future<String?> get({required String api, required Map<String, dynamic> params}) async{
    try{
      Response response = await dio.get(api, queryParameters: params);
      if(response.statusCode == 200) return jsonEncode(response.data);
      return null;
    } on DioError catch(e) {
      return null;
    }
  }

  static Future<String?> post({required String api, required Map<String, String> params}) async{
    try{
      Response response = await dio.post(api, queryParameters: params);
      if(response.statusCode == 200 || response.statusCode == 201) return jsonEncode(response.data);
      return null;
    } on DioError catch(e) {
      return null;
    }
  }
}