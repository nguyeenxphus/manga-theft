import 'package:dio/dio.dart';

abstract class HttpProvider {
  final dio = Dio();

  Future<void> init();

  Future<Response> get(String url, {dynamic query, Map<String, String>? headers}) async {
    return await dio.get(
      url,
      queryParameters: query,
      options: headers != null ? Options(headers: headers) : null,
    );
  }

  Future<Response> post(String url, {dynamic data, Map<String, String>? headers}) async {
    return await dio.post(
      url,
      data: data,
      options: headers != null ? Options(headers: headers) : null,
    );
  }
}
