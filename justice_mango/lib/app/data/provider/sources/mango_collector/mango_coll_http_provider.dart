import 'package:shared_preferences/shared_preferences.dart';

import '../../http_provider.dart';

class MangoCollHttpProvider extends HttpProvider {
  final baseUrl = 'mango.storynap.com';

  @override
  Future<void> init() async {
    await setHeaderClientId();
    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(seconds: 60);
  }

  Future<void> setHeaderClientId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uid = preferences.getString('uid');
    dio.options.headers["X-Client-Id"] = uid ?? "";
  }
}
