import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:scavenger_app/login_response.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/profile.model.dart';
import 'package:scavenger_app/model/master.model.dart';
import 'package:scavenger_app/custom_textfield.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scavenger_app/services/common.service.dart';
import 'dart:io';
import 'package:scavenger_app/services/crop.service.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? galleryFile;
  final picker = ImagePicker();
  String profileImg = '';
  String _reqdob = '';
  bool isLoader = false;
  String county = "";
  String _countryName = "";
  String _stateName = "";

  UserModel userDetails = UserModel(
    id: 0,
    name: '',
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
    dob: '',
  );
  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  int? _country = 0;
  int? _state = 0;
  final TextEditingController _address = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _pincode = TextEditingController();
  List<Country> countryList = [];
  List<CState> stateList = [];

  @override
  void initState() {
    super.initState();
    getUserDetails();
    // _getCountryList();
  }

  void getUserDetails() async {
    ApiService.getUserDetails().then((value) async {
      if (mounted) {
        if (value.success) {
          setState(() {
            userDetails = UserModel.fromJson(value.response);
            _email.text = userDetails.email;
            _name.text = userDetails.name;
            _phone.text = userDetails.phone;
            profileImg = userDetails.profileImage ?? '';
            if (userDetails.dob != null) {
              _dob.text = DateFormat('MMM dd, yyyy').format(
                  DateFormat('yyyy-MM-dd').parse(userDetails.dob ?? ''));
              _reqdob = DateFormat('dd-MM-yyyy').format(
                  DateFormat('yyyy-MM-dd').parse(userDetails.dob ?? ''));
            }
            _country = userDetails.countryId;
            county = userDetails.country ?? '';
            if (userDetails.countryId != null) {
              _getStateList("");
            }
            _countryName = userDetails.country ?? '';
            _stateName = userDetails.state ?? '';
            _state = userDetails.stateId;
            _address.text = userDetails.address ?? '';
            _city.text = userDetails.city ?? '';
            _pincode.text = userDetails.pincode ?? '';
          });
        }
      }
    });
  }

  Future<List<Country>> _getCountryList(String? searchKey) async {
    final value =
        await ApiService.getCountryList({"searchText": searchKey ?? ''});
    if (value.success) {
      return value.response.map<Country>((e) => Country.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  Future<List<CState>> _getStateList(String? searchKey) async {
    final value = await ApiService.getStateList(
        {"countryId": userDetails.countryId, "searchText": searchKey ?? ''});
    if (value.success) {
      setState(() {
        stateList =
            value.response.map<CState>((e) => CState.fromJson(e)).toList();
      });
      return value.response.map<CState>((e) => CState.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  Future<void> _uploadImage() async {
    if (galleryFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select an image to upload'),
      ));
      return;
    }

    ApiService.uploadFile(galleryFile!.path).then((value) async {
      if (value != '') {
        setState(() {
          profileImg = value;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Image upload failed'),
        ));
      }
    });
  }

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img, imageQuality: 25);

    final cropImgData =
        await CropImageService.cropImage(pickedFile, cropStyle: 'circle');
    setState(
      () {
        if (cropImgData != null) {
          galleryFile = File(cropImgData!.path);
          _uploadImage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
  }

  bool validateMobile(String value) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.isEmpty) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  _updateProfile() {
    String? formattedDate =
        _reqdob.trim().isEmpty ? null : normalizeDate(_reqdob);
    final String name = _name.text;
    final String phoneNo = _phone.text;
    if (name.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter Name !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color.fromARGB(255, 180, 13, 41),
        textColor: Colors.white,
      );
      return;
    }

    if(phoneNo.isNotEmpty && !validateMobile(phoneNo)) {
      Fluttertoast.showToast(
        msg: "Please enter valid phone number!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color.fromARGB(255, 180, 13, 41),
        textColor: Colors.white,
      );
      return;
    }

    formattedDate = normalizeDate(_reqdob);

    var reqData = {
      "name": name,
      "email": _email.text,
      "user_img": profileImg,
      "phone": phoneNo,
      "dob": formattedDate != '' ? formattedDate : null,
      "country": _country,
      "state": _state,
    };
    setState(() {
      isLoader = true;
    });
    try {
      ApiService.updateUserDetails(reqData).then((value) async {
        if (value.success) {
          setState(() {
            isLoader = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
            ),
          );
          final loginResponse = UpdateResult.fromJson(value.response);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('saved_userId', loginResponse.id);
          prefs.setString('saved_userName', loginResponse.name);
          Navigator.pop(context);
        } else {
          setState(() {
            isLoader = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile'),
            ),
          );
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  if (profileImg != '')
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(profileImg),
                    ),
                  if (profileImg == '')
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          AssetImage('assets/images/profilePicfunny.png'),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.blue),
                      ),
                      onPressed: () {
                        // getImage(ImageSource.gallery);
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return SizedBox(
                                height: 200,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Upload Quest Image',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildUploadOption(
                                            icon: Icons.camera_alt,
                                            label: 'Camera',
                                            onTap: () {
                                              // Handle Camera option
                                              getImage(ImageSource.camera);
                                              Navigator.pop(context);
                                            },
                                          ),
                                          _buildUploadOption(
                                            icon: Icons.photo,
                                            label: 'Gallery',
                                            onTap: () {
                                              getImage(ImageSource.gallery);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ));
                          },
                        );
                      },
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _name,
              labelText: 'Name:',
              hintText: 'Enter your name:',
              maxLines: 1,
            ),
            const SizedBox(height: 20),
            CustomTextField(
                controller: _email,
                labelText: 'Email:',
                hintText: 'Enter your email:',
                maxLines: 1,
                enabled: false),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _phone,
              labelText: 'Phone:',
              hintText: 'Enter your phone number',
              maxLines: 1,
              keyboardType: TextInputType.phone, // Numeric input
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Only allow digits
              ],
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _dob,
              labelText: 'Date of Birth:',
              hintText: 'Enter your date of birth:',
              maxLines: 1,
              readOnly: true,
              onTap: () {
                showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        initialEntryMode: DatePickerEntryMode.input,
                        keyboardType: TextInputType.text)
                    .then((value) {
                  if (value != null) {
                    _dob.text = DateFormat('MMM dd,yyyy').format(value);
                    userDetails.dob = _dob.text;

                    _reqdob = DateFormat('yyyy-MM-dd').format(value);
                  }
                });
              },
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Country:",
                style: TextStyle(
                  color: Color(0xFF153792), // Custom label color
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 55,
              // margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                // border:
                //     Border.all(color: Colors.grey), // Set your desired color
                borderRadius:
                    BorderRadius.circular(30), // Optional: Add rounded corners
              ),
              child: SearchableDropdown<int>.paginated(
                hintText: Text(
                  _countryName.isNotEmpty ? _countryName : 'Select a Country',
                ),
                margin: const EdgeInsets.only(left: 20, right: 20),
                paginatedRequest: (int page, String? searchKey) async {
                  final countryList1 = await _getCountryList(searchKey);

                  return countryList1
                      .map((country) => SearchableDropdownMenuItem(
                            value: country.id,
                            label: country.name,
                            child: Text(country.name),
                          ))
                      .toList();
                },
                // requestItemCount: 25,
                onChanged: (int? value) {
                  setState(() {
                    try {
                      userDetails.countryId = value;
                      _country = value;
                      userDetails.country = countryList
                          .firstWhere((element) => element.id == value)
                          .name;
                    } catch (e) {
                      userDetails.country = '';
                    }
                  });
                  print({"country id.1234...", userDetails.countryId});

                  _getStateList("");
                },
              ),
            ),
            const SizedBox(height: 10),
            if (stateList.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stateList.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "State:",
                        style: TextStyle(
                          color: Color(0xFF153792), // Custom label color
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 55,
                      // margin: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        // border:
                        //     Border.all(color: Colors.grey), // Set your desired color
                        borderRadius: BorderRadius.circular(
                            30), // Optional: Add rounded corners
                      ),
                      child: SearchableDropdown<int>.paginated(
                        hintText: Text(_stateName.isNotEmpty
                            ? _stateName
                            : 'Select a State'),
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        paginatedRequest: (int page, String? searchKey) async {
                          final stateList = await _getStateList(searchKey);
                          return stateList
                              .map((state) => SearchableDropdownMenuItem(
                                    value: state.id,
                                    label: state.name,
                                    child: Text(state.name),
                                  ))
                              .toList();
                        },
                        requestItemCount: 25,
                        onChanged: (int? value) {
                          setState(() {
                            try {
                              _state = value ?? 0;
                              userDetails.stateId = _state;
                              userDetails.state = stateList
                                  .firstWhere((element) => element.id == _state)
                                  .name;
                            } catch (e) {
                              userDetails.state = '';
                            }
                          });
                        },
                      ),
                    )
                  ]
                ],
              ),
            const SizedBox(height: 20),
            isLoader
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () {
                      _updateProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF153792),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Update'),
                  ),
          ],
        ),
      ),
    );
  }
}

Widget _buildUploadOption({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF153792),
            size: 40,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    ),
  );
}
