import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';

class AssistantRequest {
  static Future<dynamic> receiveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));

    try {
      // If we're getting the human-readable address...
      if (httpResponse.statusCode == 200) { // '200' means that it was successful.
        String responseData = httpResponse.body; // 'responseData' is in JSON format.
        var decodedResponseData = jsonDecode(responseData);
        return decodedResponseData;
      } else {
        return AppStrings.connectToApiError;
      }
    } catch(exception) {
      return AppStrings.connectToApiError;
    }
  }
}