import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:scavenger_app/UploadImageResponse.dart';
import 'dart:convert';
import 'package:scavenger_app/constants.dart';
import 'package:scavenger_app/custom_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/services/crop.service.dart';

class AddItemManualy extends StatefulWidget {
  final int gameId;
  final int? itemId;
  final int? itemid;
  final String? itemName;
  final String? itemDescription;
  final String? itemImgUrl;
  const AddItemManualy(
      {super.key,
      required this.gameId,
      this.itemId,
      this.itemid,
      this.itemName,
      this.itemDescription,
      this.itemImgUrl});

  @override
  _AddItemManualyState createState() => _AddItemManualyState();
}

class _AddItemManualyState extends State<AddItemManualy> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isLoading1 = false;
  bool _isNameError = false;
  int _currentLength = 0;
  final int _maxLength = 35;

//class CreateHuntFormManualAdd extends StatelessWidget {
  File? galleryFile;
  final picker = ImagePicker();
  String uplodedImgUrl = "";

  @override
  void initState() {
    super.initState();
    if (widget.itemId != null) {
      _itemNameController.text = widget.itemName!;
      _descriptionController.text = widget.itemDescription!;
      uplodedImgUrl = widget.itemImgUrl!;
    }
    _itemNameController.addListener(() {
      setState(() {
        _currentLength = _itemNameController.text.length;
      });
    });
  }

  Future<void> _additemManually() async {
    final String name = _itemNameController.text;
    final String desc = _descriptionController.text;
    _isNameError = false;
    if (name.isEmpty) {
      setState(() {
        _isNameError = true;
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    ApiService.insertChallengeItemsManually({
      "challengeid": widget.gameId,
      "itemname": name,
      "description": desc,
      "imageurl": uplodedImgUrl,
      "point": 10
    }).then((res) {
      try {
        setState(() {
          _isLoading = false;
        });
        if (res.success) {
          Navigator.pop(context, 'add item from Screen!');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to add item: ${res.message}'),
          ));
        }
      } catch (error) {
        // print(error);
      }
    });
  }

  Future<void> _updateGameItem() async {
    final String name = _itemNameController.text;
    final String desc = _descriptionController.text;
    _isNameError = false;
    if (name.isEmpty) {
      setState(() {
        _isNameError = true;
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    var reqData = {
      "challengeid": widget.gameId,
      "name": name,
      "description": desc,
      "imageurl": uplodedImgUrl,
      "id": widget.itemid
    };
    print({">>>>>>>>>>>reqData", reqData});
    ApiService.updateChallengeItem(reqData).then((res) {
      try {
        setState(() {
          _isLoading = false;
        });
        if (res.success) {
          Navigator.pop(context, 'add item from Screen!');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to add item: ${res.message}'),
          ));
        }
      } catch (error) {
        // print(error);
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

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img, imageQuality: 25);
    final cropImgData = await CropImageService.cropImage(pickedFile);
    setState(
      () {
        _isLoading1 = true;
        if (cropImgData != null) {
          galleryFile = File(cropImgData!.path);
          _uploadImage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
  }

  Future<void> _uploadImage() async {
    if (galleryFile == null) return;
    String uploadUrl = '${ApiConstants.uploadUrl}/upload';
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files
        .add(await http.MultipartFile.fromPath('file', galleryFile!.path));
    var response = await request.send();
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(await response.stream.bytesToString());
      final jsonResponseData = UploadImageResponse.fromJson(jsonResponse);
      if (jsonResponseData.success) {
        uplodedImgUrl = jsonResponseData.result.secureUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('hunt failed: ${jsonResponseData.mesasge}'),
        ));
      }
    } else {
      print('Image upload failed with status: ${response.statusCode}');
    }
    setState(() {
      _isLoading1 = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 245, 243, 243),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenSize.width,
          child: Center(
            child: SizedBox(
              width: screenSize.width,
              height: MediaQuery.of(context).size.height / 1,
              
              child: DecoratedBox(
                decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
              ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        // Row for Image & Item Name
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Picker
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () => _showPicker(context: context),
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 27, 56, 150)),
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: const Color.fromRGBO(
                                          242, 242, 242, 1),
                                    ),
                                    child: _isLoading1
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : uplodedImgUrl == '' ||
                                                uplodedImgUrl == null
                                            ? const Center(
                                                child: Icon(
                                                    Icons
                                                        .add_photo_alternate_outlined,
                                                    size: 50,
                                                    color: Colors.grey))
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  uplodedImgUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Center(
                                                      child: Icon(Icons.image,
                                                          size: 50,
                                                          color: Colors.grey),
                                                    );
                                                  },
                                                )),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                galleryFile == null
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
                            const SizedBox(width: 10),
                            // Item Name Input
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    controller: _itemNameController,
                                    labelText: 'Item Name',
                                    hintText: 'Enter item name',
                                    maxLines: 1,
                                    fillColor:
                                        const Color.fromRGBO(242, 242, 242, 1),
                                    borderRadius: 12,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(
                                          _maxLength),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          '$_currentLength/$_maxLength',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            // backgroundColor: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_isNameError)
                                    const Text(
                                      'Please enter a valid name',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Description Input
                        CustomTextField(
                          controller: _descriptionController,
                          labelText: 'Description',
                          hintText: 'Enter item description',
                          maxLines: 3,
                          fillColor: const Color.fromRGBO(242, 242, 242, 1),
                          borderRadius: 12,
                          inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                            ],
                        ),
                        const SizedBox(height: 20),
                        // Add Item Button
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: () {
                                  if (widget.itemId != null) {
                                    _updateGameItem();
                                  } else {
                                    _additemManually();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF153792),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(widget.itemId == null
                                    ? 'Add Item'
                                    : 'Update Item'),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}