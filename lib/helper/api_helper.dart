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
      print("id $id");
      print("params $params");
      if (id != null) {
        params ??= {};
        params['userId'] = id;
      }
      print("params $params");

      Options options = Options(
        headers: headers,
      );

      Response response;
      if (method == 'GET') {
        response = await dio.get(
          '${Globals.base_url}/$endpoint',
          queryParameters: params,
          options: options,
        );
      } else if (method == 'POST') {
        response = await dio.post(
          '${Globals.base_url}/$endpoint',
          queryParameters: params,
          data: body,
          options: options,
        );
      } else if (method == 'PUT') {
        response = await dio.put(
          '${Globals.base_url}/$endpoint',
          queryParameters: params,
          options: options,
        );
      } else {
        throw Exception("Unsupported HTTP method: $method");
      }

      return response;
    } on DioException catch (e) {
      showToast(e.response!.data["title"]);
      print(e.response!.data["title"]);
      throw Exception("Error fetching data: $e");
    }
  }
}
