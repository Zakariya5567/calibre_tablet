import 'package:dio/dio.dart';

class ApiRepo {
  //POST REQUEST
  postRequest(
      {required String url,
      required Map<String, dynamic> data,
      required Options options}) async {
    try {
      final response = await Dio().post(url, data: data, options: options);
      return response;
    } on DioException catch (exception) {
      return exception.response;
    }
  }

  //DOWNLOAD REQUEST
  downloadRequest({required String url, required Options options}) async {
    try {
      final response = await Dio().post(url, options: options);
      return response;
    } on DioException catch (exception) {
      return exception.response;
    }
  }
}
