import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scavenger_app/AddPrizelistResponse.dart';
import 'package:scavenger_app/CreateHuntFormLastPage.dart';
import 'package:scavenger_app/CreatedGameDetailsResponse.dart';
import 'package:scavenger_app/UploadImageResponse.dart';
import 'package:scavenger_app/services/crop.service.dart';
import 'package:scavenger_app/services/stepper.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'constants.dart';
import 'custom_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/gameUpdate.model.dart';

class CreateHuntPictureForm extends StatefulWidget {
  final int gameId;
  final String gameuniqueId;
  const CreateHuntPictureForm(
      {super.key, required this.gameId, required this.gameuniqueId});

  @override
  _CreateHuntPictureFormState createState() => _CreateHuntPictureFormState();
}

class _CreateHuntPictureFormState extends State<CreateHuntPictureForm> {
  final TextEditingController _prize1Controller = TextEditingController();
  final TextEditingController _prize2Controller = TextEditingController();
  final TextEditingController _prize3Controller = TextEditingController();

  bool _isLoading = false;
  bool _isLoading1 = false;
  bool _isLoading2 = false;
  bool _isLoading3 = false;
  File? galleryFile; //,galleryFile2,galleryFile3;
  File? galleryFile2;
  File? galleryFile3;
  final picker = ImagePicker();
  final picker2 = ImagePicker();
  final picker3 = ImagePicker();
  String uplodedImgUrl = "";
  String uplodedImgUrl2 = "";
  String uplodedImgUrl3 = "";
  bool isTimed = false;

  @override
  void initState() {
    super.initState();
    _gameDetails();
  }

  void _gameDetails() {
    setState(() {
      _isLoading1 = true;
      _isLoading2 = true;
      _isLoading3 = true;
    });
    ApiService.gameDetails(widget.gameId).then((value) {
      if (value.success) {
        var result = GamePrizePage.fromJson(value.response);
        isTimed = result.isTimed ?? false;

        setState(() {
          _prize1Controller.text = result.prizes[0].firstDesc ?? '';
          _prize2Controller.text = result.prizes[0].secondDesc ?? '';
          _prize3Controller.text = result.prizes[0].thirdDesc ?? '';
          uplodedImgUrl = result.prizes[0].firstPrizeImgUrl ?? '';
          uplodedImgUrl2 = result.prizes[0].secondPrizeImgUrl ?? '';
          uplodedImgUrl3 = result.prizes[0].thirdPrizeImgUrl ?? '';
          _isLoading1 = false;
          _isLoading2 = false;
          _isLoading3 = false;
        });
      }
    });
  }

  void _showPicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPicker2({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage2(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage2(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPicker3({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage3(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage3(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img, imageQuality: 25);
    final cropImgData = await CropImageService.cropImage(pickedFile);
    // XFile? xfilePick = pickedFile;
    setState(
      () {
        // _isLoading1 = true;
        if (cropImgData != null) {
          galleryFile = File(cropImgData!.path);
          _uploadImage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
        // _isLoading1 = false;
      },
    );
  }

  Future getImage2(
    ImageSource img,
  ) async {
    final pickedFile = await picker2.pickImage(source: img, imageQuality: 25);
    final cropImgData = await CropImageService.cropImage(pickedFile);
    // XFile? xfilePick = pickedFile;
    setState(
      () {
        // _isLoading2 = true;
        if (cropImgData != null) {
          galleryFile2 = File(cropImgData!.path);

          _uploadImage2();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
        // _isLoading2 = false;
      },
    );
  }

  Future getImage3(
    ImageSource img,
  ) async {
    final pickedFile = await picker3.pickImage(source: img, imageQuality: 25);
    final cropImgData = await CropImageService.cropImage(pickedFile);
    // XFile? xfilePick = pickedFile;
    setState(
      () {
        if (cropImgData != null) {
          galleryFile3 = File(cropImgData!.path);
          _uploadImage3();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
  }

  Future<void> _uploadImage() async {
    _isLoading1 = true;
    if (galleryFile == null) return;

    String uploadUrl =
        '${ApiConstants.uploadUrl}/upload'; // Replace with your server URL

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files
        .add(await http.MultipartFile.fromPath('file', galleryFile!.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(await response.stream.bytesToString());
      final jsonResponseData = UploadImageResponse.fromJson(jsonResponse);

      if (jsonResponseData.success) {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   content: Text('hunt successful!'),
        // ));

        //Navigate to the next screen or perform other actions
        uplodedImgUrl = jsonResponseData.result.secureUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('hunt failed: ${jsonResponseData.mesasge}'),
        ));
      }
    } else {
    }

    ApiService.uploadFile(galleryFile!.path).then((value) async {
      setState(() {
        _isLoading = false;
      });
      if (value != '') {
        setState(() {
          uplodedImgUrl = value;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Image upload failed'),
        ));
      }
    });

    setState(() {
      _isLoading1 = false;
    });
  }

  Future<void> _uploadImage2() async {
    _isLoading2 = true;
    if (galleryFile2 == null) return;
    String uploadUrl =
        '${ApiConstants.uploadUrl}/upload'; // Replace with your server URL

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files
        .add(await http.MultipartFile.fromPath('file', galleryFile2!.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(await response.stream.bytesToString());
      final jsonResponseData = UploadImageResponse.fromJson(jsonResponse);

      if (jsonResponseData.success) {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   content: Text('hunt successful!'),
        // ));

        //Navigate to the next screen or perform other actions
        uplodedImgUrl2 = jsonResponseData.result.secureUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('hunt failed: ${jsonResponseData.mesasge}'),
        ));
      }
    } else {
    }
    setState(() {
      _isLoading2 = false;
    });
  }

  Future<void> _uploadImage3() async {
    _isLoading3 = true;
    if (galleryFile3 == null) return;
    String uploadUrl =
        '${ApiConstants.uploadUrl}/upload'; // Replace with your server URL

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files
        .add(await http.MultipartFile.fromPath('file', galleryFile3!.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Image uploaded successfully.');
      final jsonResponse = jsonDecode(await response.stream.bytesToString());
      final jsonResponseData = UploadImageResponse.fromJson(jsonResponse);

      if (jsonResponseData.success) {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   content: Text('hunt successful!'),
        // ));

        //Navigate to the next screen or perform other actions
        uplodedImgUrl3 = jsonResponseData.result.secureUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('hunt failed: ${jsonResponseData.mesasge}'),
        ));
      }
    } else {
      print('Image upload failed with status: ${response.statusCode}');
    }
    setState(() {
      _isLoading3 = false;
    });
  }

  Future<void> _createGame3() async {
    setState(() {
      _isLoading = true;
    });

    final String prize1 = _prize1Controller.text;
    final String prize2 = _prize2Controller.text;
    final String prize3 = _prize3Controller.text;

    var reqData = {
      "game_id": widget.gameId,
      "first_desc": prize1,
      "first_prize_img_url": uplodedImgUrl,
      "second_desc": prize2,
      "second_prize_img_url": uplodedImgUrl2,
      "third_desc": prize3,
      "third_prize_img_url": uplodedImgUrl3,
    };
    ApiService.uploadGamePicture(reqData).then((res) async {
      try {
        if (res.success) {
          // final jsonResponseData = AddPrizelistResponse.fromJson(res.response);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateHuntFormLastPage(
                      gameId: widget.gameId,
                      gameuniqueId: widget.gameuniqueId)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('data add failed: ${res.message}'),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Create a Hunt"),
        automaticallyImplyLeading: false, // Remove the back button
        backgroundColor: const Color(0xFF0B00AB),
        foregroundColor: Colors.white,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.notifications),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      backgroundColor: const Color(0xFF0B00AB),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Center(
          child: Container(
            width: screenSize.width, // 80% of the screen width
            height: screenSize.height,
            decoration: const ShapeDecoration(
              color: Color(0xFFF2F2F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
              ),
            ),

            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.asset(
                    'assets/images/1 1.png', // Update the image asset accordingly
                    height: 117,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 20),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Assign Prizes',
                          style: TextStyle(
                            color: Color(0xFF153792),
                            fontSize: 30,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w800,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 0),
                  const Text(
                    "If you have prizes you have the option to add descriptions of the prizes and a picture.",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 15, color: Color(0xFF82929D)),
                  ),
                  const SizedBox(height: 20),
                  // Image.asset(
                  //   'assets/images/hunt4.png', // Update the image asset accordingly
                  //   height: 30,
                  //   fit: BoxFit.fill,
                  // ),
                  // const SizedBox(height: 20),
                  isTimed
                      ? StepperTabPage(
                          activeStep: 4, totalStep: 5, gameId: widget.gameId)
                      : StepperTabPage(
                          activeStep: 3, totalStep: 5, gameId: widget.gameId),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    _showPicker(context: context);
                                  },
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                width: 2,
                                                color: const Color.fromARGB(
                                                    255, 27, 56, 150))),
                                        child: _isLoading1
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator())
                                            : uplodedImgUrl != ""
                                                ? ClipRRect(
                                                    child: Image.network(
                                                    uplodedImgUrl,
                                                    height: 100,
                                                    width: 100,
                                                  ))
                                                : ClipRRect(
                                                    child: galleryFile == null
                                                        ? const Icon(
                                                            size: 50,
                                                            Icons
                                                                .add_photo_alternate_outlined,
                                                            color: Colors.black,
                                                          )
                                                        : Image.file(
                                                            galleryFile!,
                                                            height: 100,
                                                            width: 100,
                                                          ))),
                                  )),
                              const SizedBox(
                                height: 10,
                              ),
                              uplodedImgUrl.isEmpty
                                  ? const Text("Image (optional)",
                                      style: const TextStyle(
                                        color: Color(
                                            0xFF153792), // Custom label color
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ))
                                  : const Text("Change image",
                                      style: const TextStyle(
                                        color: Color(
                                            0xFF153792), // Custom label color
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      )),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Column(
                            children: [
                              CustomTextField(
                                // controller: _itemNameController,
                                controller: _prize1Controller,
                                labelText: '1st Place (Optional)',
                                hintText: 'Prize Description',
                                maxLines: 2,
                                fillColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                borderRadius: 12,
                              ),
                              // if (_itemNameErr)
                              //   const Text(
                              //     'Please enter item name',
                              //     style: TextStyle(
                              //         color: Colors.red, fontSize: 12),
                              //   ),
                              const SizedBox(
                                height: 40,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  // CustomTextField(
                  //     controller: _prize1Controller,
                  //     labelText: '1st Place (Optional):',
                  //     hintText: 'Prize description',
                  //     maxLines: 3,
                  //     borderRadius: 12),
                  // const SizedBox(height: 20),
                  // const Text(
                  //   'Add a Picture (Optional):',
                  //   style: TextStyle(
                  //       fontWeight: FontWeight.w500,
                  //       color: Color.fromRGBO(21, 55, 146, 1)),
                  // ),
                  // if (uplodedImgUrl != "")
                  //   Container(
                  //     height: 150,
                  //     width: double.infinity,
                  //     decoration: BoxDecoration(
                  //         border: Border.all(color: Colors.green),
                  //         borderRadius: BorderRadius.circular(10.0),
                  //         color: Colors.white),
                  //     child: Center(child: Image.network(uplodedImgUrl)),
                  //   ),
                  // if (uplodedImgUrl == "")
                  //   Container(
                  //     height: 150,
                  //     width: double.infinity,
                  //     decoration: BoxDecoration(
                  //         border: Border.all(color: Colors.green),
                  //         borderRadius: BorderRadius.circular(10.0),
                  //         color: Colors.white),
                  //     child: galleryFile == null
                  //         ? const Center(
                  //             child: Icon(Icons.image,
                  //                 size: 50, color: Colors.grey))
                  //         : Center(child: Image.file(galleryFile!)),
                  //   ),
                  // const SizedBox(height: 20),
                  // _isLoading1
                  //     ? const Center(child: CircularProgressIndicator())
                  //     : ElevatedButton.icon(
                  //         onPressed: () {
                  //           // Add your change photo logic here
                  //           _showPicker(context: context);
                  //         },
                  //         icon:
                  //             const Icon(Icons.camera_alt, color: Colors.green),
                  //         label: const Text('Add / Change Picture',
                  //             style: TextStyle(color: Color(0xFF0EA771))),
                  //         style: OutlinedButton.styleFrom(
                  //           backgroundColor:
                  //               const Color.fromARGB(255, 175, 248, 222),
                  //           minimumSize: const Size(double.infinity, 50),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(30.0),
                  //           ),
                  //         ),
                  //       ),
                  const SizedBox(height: 20),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    _showPicker2(context: context);
                                  },
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                width: 2,
                                                color: const Color.fromARGB(
                                                    255, 27, 56, 150))),
                                        child: _isLoading2
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator())
                                            : uplodedImgUrl2 != ""
                                                ? ClipRRect(
                                                    child: Image.network(
                                                    uplodedImgUrl2,
                                                    height: 100,
                                                    width: 100,
                                                  ))
                                                : ClipRRect(
                                                    child: galleryFile2 == null
                                                        ? const Icon(
                                                            size: 50,
                                                            Icons
                                                                .add_photo_alternate_outlined,
                                                            color: Colors.black,
                                                          )
                                                        : Image.file(
                                                            galleryFile2!,
                                                            height: 100,
                                                            width: 100,
                                                          ))),
                                  )),
                              const SizedBox(
                                height: 10,
                              ),
                              uplodedImgUrl2.isEmpty
                                  ? const Text("Image (optional)",
                                      style: const TextStyle(
                                        color: Color(
                                            0xFF153792), // Custom label color
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ))
                                  : const Text("Change image",
                                      style: const TextStyle(
                                        color: Color(
                                            0xFF153792), // Custom label color
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      )),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _prize2Controller,
                                labelText: '2nd Place (Optional)',
                                hintText: 'Prize Description',
                                maxLines: 2,
                                fillColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                borderRadius: 12,
                              ),
                              // if (_itemNameErr)
                              //   const Text(
                              //     'Please enter item name',
                              //     style: TextStyle(
                              //         color: Colors.red, fontSize: 12),
                              //   ),
                              const SizedBox(
                                height: 40,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  // CustomTextField(
                  //     controller: _prize2Controller,
                  //     labelText: '2nd Place (Optional):',
                  //     hintText: 'Prize description',
                  //     maxLines: 3,
                  //     borderRadius: 12),
                  // const Text(
                  //   'Add a Picture (Optional):',
                  //   style: TextStyle(
                  //       fontWeight: FontWeight.w500,
                  //       color: Color.fromRGBO(21, 55, 146, 1)),
                  // ),
                  // Container(
                  //   height: 150,
                  //   width: double.infinity,
                  //   decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.green),
                  //       borderRadius: BorderRadius.circular(10.0),
                  //       color: Colors.white),
                  //   child: galleryFile2 == null
                  //       ? const Center(
                  //           child:
                  //               Icon(Icons.image, size: 50, color: Colors.grey))
                  //       : Center(child: Image.file(galleryFile2!)),
                  // ),
                  // const SizedBox(height: 20),
                  // _isLoading2
                  //     ? const Center(child: CircularProgressIndicator())
                  //     : ElevatedButton.icon(
                  //         onPressed: () {
                  //           // Add your change photo logic here
                  //           _showPicker2(context: context);
                  //         },
                  //         icon:
                  //             const Icon(Icons.camera_alt, color: Colors.green),
                  //         label: const Text('Add / Change Picture',
                  //             style: TextStyle(color: Color(0xFF0EA771))),
                  //         style: OutlinedButton.styleFrom(
                  //           backgroundColor:
                  //               const Color.fromARGB(255, 175, 248, 222),
                  //           minimumSize: const Size(double.infinity, 50),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(30.0),
                  //           ),
                  //         ),
                  //       ),
                  const SizedBox(height: 20),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    _showPicker3(context: context);
                                  },
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                width: 2,
                                                color: const Color.fromARGB(
                                                    255, 27, 56, 150))),
                                        child: _isLoading3
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator())
                                            : uplodedImgUrl3 != ""
                                                ? ClipRRect(
                                                    child: Image.network(
                                                    uplodedImgUrl3,
                                                    height: 100,
                                                    width: 100,
                                                  ))
                                                : ClipRRect(
                                                    child: galleryFile3 == null
                                                        ? const Icon(
                                                            size: 50,
                                                            Icons
                                                                .add_photo_alternate_outlined,
                                                            color: Colors.black,
                                                          )
                                                        : Image.file(
                                                            galleryFile3!,
                                                            height: 100,
                                                            width: 100,
                                                          ))),
                                  )),
                              const SizedBox(
                                height: 10,
                              ),
                              uplodedImgUrl3.isEmpty
                                  ? const Text("Image (optional)",
                                      style: const TextStyle(
                                        color: Color(
                                            0xFF153792), // Custom label color
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ))
                                  : const Text("Change image",
                                      style: const TextStyle(
                                        color: Color(
                                            0xFF153792), // Custom label color
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      )),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _prize3Controller,
                                labelText: '3rd Place (Optional)',
                                hintText: 'Prize Description',
                                maxLines: 2,
                                fillColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                borderRadius: 12,
                              ),
                              // if (_itemNameErr)
                              //   const Text(
                              //     'Please enter item name',
                              //     style: TextStyle(
                              //         color: Colors.red, fontSize: 12),
                              //   ),
                              const SizedBox(
                                height: 40,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  // CustomTextField(
                  //     controller: _prize3Controller,
                  //     labelText: '3rd Place (Optional):',
                  //     hintText: 'Prize description',
                  //     maxLines: 3,
                  //     borderRadius: 12),
                  // const SizedBox(height: 20),
                  // const Text(
                  //   'Add a Picture (Optional):',
                  //   style: TextStyle(
                  //       fontWeight: FontWeight.w500,
                  //       color: Color.fromRGBO(21, 55, 146, 1)),
                  // ),
                  // Container(
                  //   height: 150,
                  //   width: double.infinity,
                  //   decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.green),
                  //       borderRadius: BorderRadius.circular(10.0),
                  //       color: Colors.white),
                  //   child: galleryFile3 == null
                  //       ? const Center(
                  //           child:
                  //               Icon(Icons.image, size: 50, color: Colors.grey))
                  //       : Center(child: Image.file(galleryFile3!)),
                  // ),

                  // const SizedBox(height: 20),
                  // _isLoading3
                  //     ? const Center(child: CircularProgressIndicator())
                  //     : ElevatedButton.icon(
                  //         onPressed: () {
                  //           // Add your change photo logic here
                  //           _showPicker3(context: context);
                  //         },
                  //         icon:
                  //             const Icon(Icons.camera_alt, color: Colors.green),
                  //         label: const Text('Add / Change Picture',
                  //             style: TextStyle(color: Color(0xFF0EA771))),
                  //         style: OutlinedButton.styleFrom(
                  //           backgroundColor:
                  //               const Color.fromARGB(255, 175, 248, 222),
                  //           minimumSize: const Size(double.infinity, 50),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(30.0),
                  //           ),
                  //         ),
                  //       ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () {
                            // if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {

                            // }
                            // else{
                            //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            //     content: Text('Please enter data'),
                            //  ));
                            // }
                            _createGame3();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF153792),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ), //_login,
                          child: const Text('Next'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
