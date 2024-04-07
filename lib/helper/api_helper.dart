import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db_model/constants.dart';

class ApiHelper {
  Dio dio = Dio();
  Future<Response> fetchData({
    required String method,
    required String endpoint,
    Map<String, dynamic>? params, dynamic body,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? id = prefs.getInt("id");
      Map<String, String> headers = {
        'authorization': basicAuth,
      };
      if (id != null) {
        params ??= {};
        params['userId'] = id;
      }

      Options options = Options(
        headers: headers,
      );

      Response response;
      if (method == 'GET') {
        response = await dio.get(
          '$base_url/$endpoint',
          queryParameters: params,
          options: options,
        );
      } else if (method == 'POST') {
        response = await dio.post(
          '$base_url/$endpoint',
          queryParameters: params,
          data: body,
          options: options,
        );
      } else {
        throw Exception("Unsupported HTTP method: $method");
      }

      return response;
    } catch (e) {
      print(e);
      throw Exception("Error fetching data: $e");
    }
  }
}
