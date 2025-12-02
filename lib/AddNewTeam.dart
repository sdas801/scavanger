import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/services/crop.service.dart';

class AddTeam extends StatefulWidget {
  final String? itemId;
  final String? myteam;
  final String? huntImg;
  final String gamedesc;
  final String gameTitle;
  final int? checkTeam;
  final int teamid;
  final String? userImg;
  final String teamName;

  const AddTeam({
    super.key,
    required this.itemId,
    required this.myteam,
    required this.checkTeam,
    required this.gameTitle,
    required this.gamedesc,
    required this.teamid,
    required this.userImg,
    required this.teamName,
    this.huntImg,
  });

  @override
  _AddTeamState createState() => _AddTeamState();
}

class _AddTeamState extends State<AddTeam> {
  final TextEditingController _teamNameController = TextEditingController();
  bool _isLoading = false;
  bool _isLoading1 = false;
  // bool _isNameError = false;
  String huntImg = "";
  String gameTitle = "";
  String gamedesc = "";
  int checkTeam = 0;
  String teamId = "";
  String gameImg = '';

//class CreateHuntFormManualAdd extends StatelessWidget {
  File? galleryFile;
  final picker = ImagePicker();
  String uplodedImgUrl = "";

  @override
  void initState() {
    super.initState();
    huntImg = widget.huntImg!;
    gameTitle = widget.gameTitle!;
    gamedesc = widget.gamedesc!;
    checkTeam = widget.checkTeam!;
    teamId = widget.itemId!;

    if (widget.teamid != 0) {
      _teamNameController.text = widget.teamName;
      gameImg = widget.userImg!;
    }
  }

  Future<void> _clearData() async {
    if (mounted)
      setState(() {
        _teamNameController.clear();
        gameImg = "";
      });
  }

  Future<void> _createTeam() async {
    final String teamname = _teamNameController.text.trim();
    if (teamname.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter team name !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    var reqData = {
      "teamId": checkTeam == 1 ? teamId : widget.myteam,
      "name": teamname,
      "email": "",
      "phone": "",
      "user_img": gameImg
    };
    ApiService.createTeam(reqData).then((value) {
      if (value.success) {
        //  final jsonResponseData = CreateTeamResponse.fromJson(value.response);
        _teamNameController.text = '';
        Navigator.of(context).pop();
        _clearData();
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text('Login failed: ${value.message}'),
        // ));
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateTeamMember() async {
    final String teamname = _teamNameController.text.trim();
    if (teamname.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please update team name !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    var reqData = {
      "id": widget.teamid,
      "name": teamname,
      "email": "",
      "phone": "",
      "user_img": gameImg
    };
    ApiService.updateTeamMemberList(reqData).then((value) {
      if (value.success) {
        //  final jsonResponseData = CreateTeamResponse.fromJson(value.response);
        Navigator.of(context).pop();
        _clearData();
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text('Login failed: ${value.message}'),
        // ));
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img, imageQuality: 25);
    final cropImgData = await CropImageService.cropImage(pickedFile);
    setState(
      () {
        if (cropImgData != null) {
          galleryFile = File(cropImgData!.path);
          _isLoading = true;
          _uploadImage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
  }

  Future<void> _uploadImage() async {
    // setState(() {
    //   _isLoading = true;
    // });
    if (galleryFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select an image to upload'),
      ));
      return;
    }
    ApiService.uploadFile(galleryFile!.path).then((value) async {
      if (value != '') {
        var mainImg = value;
        setState(() {
          gameImg = mainImg;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Image upload failed'),
        ));
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(45),
            topRight: Radius.circular(45),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _clearData();
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 30,
                      semanticLabel: 'Close',
                    ),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  huntImg.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: Image(
                            image: NetworkImage(huntImg),
                            height: 72,
                            width: 72,
                            fit: BoxFit.cover,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: const Image(
                            image: AssetImage('assets/images/defaultImg.jpg'),
                            height: 72,
                            width: 72,
                            fit: BoxFit.cover,
                          ),
                        ),
                  Container(
                    width: MediaQuery.of(context).size.width - 100,
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gameTitle,
                          style: const TextStyle(
                            color: Color(0xFF153792),
                            fontSize: 18,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                            height: 0,
                          ),
                        ),
                        Text(
                          gamedesc,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Color(0xFF4F4444),
                            fontSize: 11,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            height: 2,
                          ),
                        ),
                        gamedesc.isNotEmpty && gamedesc.length > 30
                            ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        // title: const Text("Full Description"),
                                        content: SingleChildScrollView(
                                          child: Text(
                                            gamedesc,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontFamily: 'Jost',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: const Text(
                                  "Show More",
                                  style: TextStyle(
                                    color: Color(0xFF153792),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
                            : const SizedBox()
                      ],
                    ),
                  )
                ]),
                const SizedBox(height: 25),
                Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
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
                                          onTap: () async {
                                            // Capture image from camera
                                            final newImage = await getImage(
                                                ImageSource.camera);
                                            if (newImage != null) {
                                              setState(() {
                                                gameImg =
                                                    newImage; // Update the image URL
                                              });
                                            }
                                            Navigator.pop(context);
                                          },
                                        ),
                                        _buildUploadOption(
                                          icon: Icons.photo,
                                          label: 'Gallery',
                                          onTap: () async {
                                            // Select image from gallery
                                            final newImage = await getImage(
                                                ImageSource.gallery);
                                            if (newImage != null) {
                                              setState(() {
                                                gameImg =
                                                    newImage; // Update the image URL
                                              });
                                            }
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 27, 56, 150),
                          ),
                        ),
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: gameImg.isNotEmpty
                                    ? Image.network(
                                        gameImg,
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        size: 50,
                                        Icons.add_photo_alternate_outlined,
                                        color: Colors.black,
                                      ),
                              ),
                      ),
                    )),
                const SizedBox(height: 25),
                TextField(
                  controller: _teamNameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    LengthLimitingTextInputFormatter(30),
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(30),
                      gapPadding: 10,
                    ),
                    fillColor: const Color.fromRGBO(242, 242, 242, 1),
                    filled: true,
                    labelText: 'Team member name',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 20.0,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () {
                          if (widget.teamid != 0) {
                            _updateTeamMember();
                          } else {
                            _createTeam();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF45AA6D),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(150, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Add'),
                      ),
              ],
            ),
          ),
        ));
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
