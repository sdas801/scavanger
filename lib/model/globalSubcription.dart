import 'dart:convert';

import 'package:scavenger_app/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<PolicyResult?> getSubscriptionDataFun() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? subcriptionCheckString = prefs.getString('subscription_Check');
  PolicyResult? tempSubcriptionCheckNo;
  if (subcriptionCheckString != null && subcriptionCheckString.isNotEmpty) {
    try {
      Map<String, dynamic> decodedJson = jsonDecode(subcriptionCheckString);
      tempSubcriptionCheckNo = PolicyResult.fromJson(decodedJson);
    } catch (e) {
      tempSubcriptionCheckNo = null;
    }
  } else {
    tempSubcriptionCheckNo = null;
  }

  print({">>>>>>>>>>lllllallalalala",tempSubcriptionCheckNo});
  return tempSubcriptionCheckNo != null ?tempSubcriptionCheckNo:null;
}
