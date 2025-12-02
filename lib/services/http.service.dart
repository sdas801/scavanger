import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scavenger_app/pre_login.dart';
import 'package:scavenger_app/main.dart';
import 'package:scavenger_app/UploadImageResponse.dart';

Future<http.Response> get(String url) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('auth_token');
  print('authToken $authToken');
  // Create headers map
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // Conditionally add the Authorization header
  if (authToken != null && authToken.isNotEmpty) {
    headers['Authorization'] = 'Bearer $authToken';
  }

  // Send HTTP GET request
  final response = await http.get(Uri.parse(url), headers: headers);

  // Handle unauthorized access error
  if (response.statusCode == 401) {
    // Perform actions such as logging out the user or showing an error message
    // For example, you can clear the auth token and redirect to login
    await prefs.remove('auth_token');
    await prefs.remove('saved_userId');
    // Redirect to login or show an error message
    // e.g., Navigator.pushReplacementNamed(context, '/login');
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => const SecondScreen()),
    );
  }

  return response;
}

Future<http.Response> post(String url, dynamic body) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('auth_token');

  // Create headers map
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
  print('authToken $authToken');
  // Conditionally add the Authorization header
  if (authToken != null && authToken.isNotEmpty) {
    headers['Authorization'] = 'Bearer $authToken';
  }
  return await http.post(Uri.parse(url),
      body: jsonEncode(body), headers: headers);
}

Future<String> upload(String uploadUrl, dynamic filePath) async {
  var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
  request.files.add(await http.MultipartFile.fromPath('file', filePath));

  var response = await request.send();
  print(response);
  if (response.statusCode == 200) {
    print('Image uploaded successfully.');
    final jsonResponse = jsonDecode(await response.stream.bytesToString());
    final jsonResponseData = UploadImageResponse.fromJson(jsonResponse);

    if (jsonResponseData.success) {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //   content: Text('hunt successful!'),
      // ));

      //Navigate to the next screen or perform other actions
      return jsonResponseData.result.secureUrl;
    } else {
      return '';
    }
  } else {
    print('Image upload failed with status: ${response.statusCode}');
    return '';
  }
}