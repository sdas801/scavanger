import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scavenger_app/learningCenter.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/pages/deleteAccount/deleteAccountfirstpage.dart';
import 'package:scavenger_app/pages/subcriptions/CurrentPlanDetails.dart';
import 'package:scavenger_app/pages/subcriptions/subcriptionList.dart';
import 'package:scavenger_app/paymentSuccessfulpage.dart';
import 'package:scavenger_app/privacyAndPolicy.dart';
import 'package:scavenger_app/tramsandconditions.dart';
import 'package:scavenger_app/utility/random_picture.dart';
import 'package:scavenger_app/login_screen.dart';
import 'package:scavenger_app/videoDetailsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scavenger_app/edit_profile.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/profile.model.dart';
import 'package:scavenger_app/pages/store/purchase.page.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
  const ProfileScreen({super.key});
}

class _ProfileScreenState extends State<ProfileScreen> {
  String version = '53.0.0';
  var userid = 0;
  var username = '';
  int gameId = 0;
  String gameuniqueId = "";
  String currentPlanName = "";
  bool isExpire = false;
  UserModel userDetails = UserModel(
    id: 0,
    name: '',
    profileImage: '',
    uniqueId: '',
    username: '',
    email: '',
    phone: '',
    city: '',
    state: '',
    stateId: 0,
    country: '',
    countryId: 0,
    address: '',
    pincode: '',
  );
  @override
  void initState() {
    super.initState();
    getUserDetails();
    getSubcriptionDetails();
  }

  void getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('saved_userId')) {
      setState(() {
        userid = (prefs.getInt('saved_userId') ?? 0);
        username = (prefs.getString('saved_userName') ?? "");
      });
    }
    ApiService.getUserDetails().then((value) async {
      if (value.success) {
        if (mounted) {
          setState(() {
            userDetails = UserModel.fromJson(value.response);
            gameId = userDetails.id;
            gameuniqueId = userDetails.uniqueId;
          });
        }
      }
    });
  }

  void getSubcriptionDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subcriptionCheckString = prefs.getString('subscription_Check');
    PolicyResult? tempSubcriptionCheckNo;
    if (subcriptionCheckString != null && subcriptionCheckString.isNotEmpty) {
      try {
        Map<String, dynamic> decodedJson = jsonDecode(subcriptionCheckString);
        tempSubcriptionCheckNo = PolicyResult.fromJson(decodedJson);
        if (mounted) {
          setState(() {
            currentPlanName = tempSubcriptionCheckNo!.name;
          });
        }
      } catch (e) {
        tempSubcriptionCheckNo = null;
        setState(() {
          isExpire = true;
        });
      }
    } else {}
    print({currentPlanName});
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await prefs.setBool('isSubscriptionDataLoaded', false); // Reset flag

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void showLogoutDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Are you sure you want to logout ?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
            ),
          ),
          // content: const Text(
          //   'Are you sure you want to logout ?',
          //   style: TextStyle(fontSize: 16),
          // ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            // Confirm Button
            TextButton(
                onPressed: () {
                  logout();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF153792),
                  foregroundColor: const Color.fromARGB(255, 242, 243, 242),
                ),
                child: const Text(
                  'Log out',
                  style: TextStyle(fontSize: 16),
                )),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Container(
      width: MediaQuery.of(context).size.width,
      // height: screenSize.height,
      decoration: const BoxDecoration(color: Color.fromRGBO(11, 0, 171, 1)),
      child: Column(
        children: [
          if (userDetails.profileImage == null ||
              userDetails.profileImage == '')
            getPicture(100, 100),
          if (userDetails.profileImage != null &&
              userDetails.profileImage != '')
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userDetails.profileImage ?? ''),
            ),
          const SizedBox(height: 8.0),
          Text(
            userDetails.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            userDetails.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          /* const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfile()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                minimumSize: Size(screenSize.width - 80, 50),
              ),
              child: const Text('Edit Profile'),
            ), */
          const SizedBox(height: 20.0),
          Container(
            width: screenSize.width,
            // height: screenSize.height - 300,
            padding: const EdgeInsets.all(0.0),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(241, 241, 241, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 20),
                child: Text(
                  'Account',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(21, 55, 146, 1)),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                title: const Text(
                  'Profile',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromRGBO(21, 55, 146, 1)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                onTap: () async {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProfile()),
                  );
                  getUserDetails();
                },
              ),

              ListTile(
                leading: const Icon(Icons.library_add,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                title: const Text(
                  'Library',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromRGBO(21, 55, 146, 1)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const PurchaseItemPage(isBottom: false)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.memory,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                title: const Text(
                  'Memory',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromRGBO(21, 55, 146, 1)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const videoListPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.book,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                title: const Text(
                  'Learning Center',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromRGBO(21, 55, 146, 1)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LearningCenter()));
                },
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 20),
                child: Text(
                  'Subcriptions',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(21, 55, 146, 1)),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.assignment,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                title: Row(
                  children: [
                    const Text(
                      'Current Plan:',
                      style: const TextStyle(
                          fontSize: 16, color: Color.fromRGBO(21, 55, 146, 1)),
                    ),
                    isExpire
                        ? const Text(
                            ' Expired',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(231, 52, 52, 1),
                                fontWeight: FontWeight.w500),
                          )
                        : Text(
                            ' $currentPlanName',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(21, 55, 146, 1),
                                fontWeight: FontWeight.w500),
                          )
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const SubscriptionDetailsScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.work_history,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                title: const Text(
                  'Upgrade Plan',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromRGBO(21, 55, 146, 1)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Subcription()));
                },
              ),
              // About us
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 20),
                child: Text(
                  'Additional Information',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(21, 55, 146, 1)),
                ),
              ),
              // ListTile(
              //   leading: const Icon(Icons.lock,
              //       color: Color.fromRGBO(21, 55, 146, 1)),
              //   title: const Text(
              //     'Learning Center',
              //     style: TextStyle(
              //         fontSize: 16, color: Color.fromRGBO(21, 55, 146, 1)),
              //   ),
              //   trailing: const Icon(Icons.arrow_forward_ios,
              //       color: Color.fromRGBO(21, 55, 146, 1)),
              //   onTap: () {},
              // ),
              ListTile(
                leading: const Icon(Icons.description,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                title: const Text(
                  'Terms & Conditions',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromRGBO(21, 55, 146, 1)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TermsAndConditionsScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.description,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                title: const Text(
                  'Privacy & Policy',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromRGBO(21, 55, 146, 1)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Privacyandpolicy()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_circle,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                title: const Text(
                  'Delete Account',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(21, 55, 146, 1)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const DeleteAccountFirstPage()));
                },
              ),

              ListTile(
                leading: const Icon(Icons.logout,
                    color: Color.fromRGBO(160, 9, 9, 1)),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(160, 9, 9, 1)),
                ),
                onTap: () {
                  showLogoutDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.build_circle,
                    color: Color.fromRGBO(21, 55, 146, 1)),
                trailing: Text(version,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    )),
                title: const Text(
                  'Version',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(21, 55, 146, 1)),
                ),
                onTap: () {},
              ),
            ]),
          )
        ],
      ),
    ));
  }
}
