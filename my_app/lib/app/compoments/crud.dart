import 'dart:convert';
import 'package:http/http.dart' as http;
/*import 'package:path/path.dart';
import 'dart:io';*/
class Crud {
  /*final String _basicAuth = 'Basic ${base64Encode(utf8.encode('omar:omar'))}';*/

  Map<String, String> get myheaders => {
   /* 'Authorization': _basicAuth,*/
    'Content-Type': 'application/json', // Default content type
  };

  // Method for GET requests
  Future<Map<String, dynamic>?> getRequest(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: myheaders);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error HTTP ${response.statusCode}: ${response.reasonPhrase}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error Catch $e');
      return null;
    }
  }

  // Method for POST requests
  Future<Map<String, dynamic>?> postRequest(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: myheaders,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error HTTP ${response.statusCode}: ${response.reasonPhrase}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception lors de la requête : $e');
      return null;
    }
  }

}
