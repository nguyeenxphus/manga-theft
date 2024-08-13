import 'package:dio/dio.dart';
import 'package:manga_theft/app/data/provider/http_provider.dart';

class HttpRepository {
  final HttpProvider provider;

  HttpRepository(this.provider) {
    provider.init();
  }

  Future<Response> get(String url, {dynamic query, Map<String, String>? headers}) async {
    return await provider.get(url, query: query, headers: headers);
  }

  Future<Response> post(String url, {dynamic data, Map<String, String>? headers}) async {
    return await provider.post(url, data: data, headers: headers);
  }
}
