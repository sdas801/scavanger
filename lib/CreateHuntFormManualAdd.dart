import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:scavenger_app/UploadImageResponse.dart';
import 'package:scavenger_app/services/crop.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'constants.dart';
import 'custom_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scavenger_app/services/api.service.dart';

class CreateHuntFormManualAdd extends StatefulWidget {
  final int gameId;
  final String gameuniqueId;
  final int? itemId;
  final int? itemid;
  final String? itemName;
  final String? itemDescription;
  final String? itemImgUrl;
  const CreateHuntFormManualAdd(
      {super.key,
      required this.gameId,
      required this.gameuniqueId,
      this.itemId,
      this.itemid,
      this.itemName,
      this.itemDescription,
      this.itemImgUrl});

  @override
  _CreateHuntFormManualAddState createState() =>
      _CreateHuntFormManualAddState();
}

class _CreateHuntFormManualAddState extends State<CreateHuntFormManualAdd> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isLoading1 = false;
  bool _itemNameErr = false;
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
      if (mounted)
        setState(() {
          _currentLength = _itemNameController.text.length;
        });
    });
  }

  Future<void> _additemManually() async {
    _itemNameErr = false;
    final String name = _itemNameController.text;
    final String desc = _descriptionController.text;
    if (name.isEmpty) {
      if (mounted)
        setState(() {
          _itemNameErr = true;
        });
      return;
    }
    var payload = {
      "gameid": widget.gameId,
      "gameuniqueid": widget.gameuniqueId,
      "itemname": name,
      "description": desc,
      "point": 10,
      "imageurl": uplodedImgUrl,
      "type": "M"
    };
    if (mounted)
      setState(() {
        _isLoading = true;
      });
    ApiService.addGameItemManually(payload).then((respoData) {
      try {
        if (respoData.success) {
          // final jsonResponseData = ManualAddItemResponse.fromJson(respoData.response);
          Navigator.pop(context, 'add item from Screen!');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to add item: ${respoData.message}'),
          ));
        }
      } catch (error) {
      } finally {
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      }
    });
  }

  Future<void> _updateGameItem() async {
    final String name = _itemNameController.text;
    final String desc = _descriptionController.text;
    _itemNameErr = false;
    if (name.isEmpty) {
      if (mounted)
        setState(() {
          _itemNameErr = true;
        });
      return;
    }
    if (mounted)
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
    ApiService.updateChallengeItem(reqData).then((res) {
      try {
        if (res.success) {
          Navigator.pop(context, 'add item from Screen!');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to add item: ${res.message}'),
          ));
        }
      } catch (error) {
      } finally {
        if (mounted)
          setState(() {
            _isLoading = false;
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

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img, imageQuality: 25);
    final cropImgData = await CropImageService.cropImage(pickedFile);
    if (mounted)
      setState(
        () {
          _isLoading1 = true;
          if (cropImgData != null) {
            galleryFile = File(cropImgData!.path);
            _uploadImage();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
                const SnackBar(content: Text('Nothing is selected')));
          }
          _isLoading1 = false;
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
    if (mounted)
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

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                const SizedBox(
                                  height: 10,
                                ),
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
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    controller: _itemNameController,
                                    labelText: 'Item Name',
                                    hintText: 'Name of item',
                                    maxLines: 1,
                                    fillColor:
                                        const Color.fromRGBO(242, 242, 242, 1),
                                    borderRadius: 12,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(
                                          _maxLength),
                                    ],
                                    // Set max length
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          '$_currentLength/$_maxLength',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_itemNameErr)
                                    const Text(
                                      'Please enter item name',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  const SizedBox(
                                    height: 20,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        // Add your icon or image here

                        const SizedBox(height: 20),
                      // Description Input
                        CustomTextField(
                          controller: _descriptionController,
                          labelText: 'Description',
                          hintText: 'Description',
                          maxLines: 3,
                          fillColor: const Color.fromRGBO(242, 242, 242, 1),
                          borderRadius: 12,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(100),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                                ), //_login,
                                child: const Text('Add Item'),
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
