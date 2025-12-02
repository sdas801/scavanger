import 'package:flutter/material.dart';
import 'package:scavenger_app/HuntCreationCompleteScreen.dart';
import 'package:scavenger_app/services/stepper.service.dart';
import 'custom_textfield.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/gameUpdate.model.dart';

class CreateHuntFormLastPage extends StatefulWidget {
  final int gameId;
  final String gameuniqueId;
  const CreateHuntFormLastPage(
      {super.key, required this.gameId, required this.gameuniqueId});

  @override
  _CreateHuntFormLastPageState createState() => _CreateHuntFormLastPageState();
}

class _CreateHuntFormLastPageState extends State<CreateHuntFormLastPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final List<Item> items = [
    Item('All but one team member (photographer) must be in each image.',
        'assets/images/listIcon.png', true),
    Item('The item must be clearly shown in the image.',
        'assets/images/listIcon.png', true),
    Item('The item description must be followed accurately to receive credit.',
        'assets/images/listIcon.png', true),
    Item('Have fun!', 'assets/images/listIcon.png', true),
  ];
  bool _isLoading = false;
  bool isTimeCheck = false;

  @override
  void initState() {
    super.initState();
    _gameDetails();
  }

  void _gameDetails() {
    ApiService.gameDetails(widget.gameId).then((value) {
      if (value.success) {
        var result = GameRule.fromJson(value.response);
        var data = GameStep2.fromJson(value.response);
        isTimeCheck = data.isTimed ?? false;
        if (mounted)
          setState(() {
            var d = result.rule ?? '';
            List<String> parts = d.split('_');
            for (var item in items) {
              if (parts.contains(item.title)) {
                item.isChecked = true;
              }
            }
            _descriptionController.text = parts[parts.length - 1];
          });
      }
    });
  }

  Future<void> _createGame6() async {
    var rules = '';
    bool isAllChecked = false;
    for (var item in items) {
      if (item.isChecked == true) {
        isAllChecked = true;
        rules = '$rules${item.title}_';
      } else {
        rules = '${rules}_';
      }
    }
    bool isRuleTyped = _descriptionController.text.trim().isNotEmpty;

    if (!isAllChecked && !isRuleTyped) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please check at least one rule or enter a new rule.'),
      ));
      return;
    }
    rules = rules + _descriptionController.text;
    if (mounted)
      setState(() {
        _isLoading = true;
      });

    var reqData = {"id": widget.gameId, "game_rules": rules};
    ApiService.updateGameRules(reqData).then((res) async {
      if (res.success) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HuntCreationCompleteScreen(
                    gameId: widget.gameId,
                    gameuniqueId: widget.gameuniqueId,
                    gameType: 'hunt',
                    cardType: 'host',
                    myteam: '')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('data add failed: ${res.message}'),
        ));
      }
    });
    if (mounted)
      setState(() {
        _isLoading = false;
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
        title: const Text("Create Hunt"),
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
                          text: 'Create a Hunt',
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
                    "Create rules for your Hunt",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 15, color: Color(0xFF82929D)),
                  ),
                  const SizedBox(height: 20),
                  // Image.asset(
                  //   'assets/images/hunt5.png', // Update the image asset accordingly
                  //   height: 30,
                  //   fit: BoxFit.fill,
                  // ),
                  isTimeCheck
                      ? StepperTabPage(
                          activeStep: 6, totalStep: 5, gameId: widget.gameId)
                      : StepperTabPage(
                          activeStep: 4, totalStep: 5, gameId: widget.gameId),

                  const SizedBox(height: 20),
                  const Text(
                    'Please select any of these rules that you would like the players to see. You also can add your own rules below.',
                    style: TextStyle(
                      color: Color(0xFF153792), // Custom label color
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          if (mounted)
                            setState(() {
                              // Toggle the checkbox state on title tap (handling nullable bool)
                              if (items[index].isChecked == null) {
                                items[index].isChecked =
                                    true; // If it's null, set it to true
                              } else {
                                items[index].isChecked = !items[index]
                                    .isChecked!; // Toggle the boolean value
                              }
                            });
                        },
                        child: ListTile(
                          leading: SizedBox(
                            width: 18,
                            height: 18,
                            child: Checkbox(
                              tristate: true,
                              value: items[index].isChecked,
                              onChanged: (value) {
                                if (mounted)
                                  setState(() {
                                    items[index].isChecked = value ?? false;
                                  });
                              },
                            ),
                          ),
                          title: Text(items[index].title),
                          textColor: const Color(0xFF334164),
                          tileColor: (items[index].isChecked ?? false)
                              ? Colors.blue.shade100
                              : Colors.transparent,
// Background color when checked
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  CustomTextField(
                      controller: _descriptionController,
                      labelText:
                          'You may add any additional rules for your hunt below ',
                      hintText: '',
                      maxLines: 3,
                      borderRadius: 12),
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
                            //  Navigator.push(
                            //           context,
                            //         MaterialPageRoute(builder: (context) => CreateHuntPictureForm()));
                            _createGame6();
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

class Item {
  String title;
  String imagePath;
  bool? isChecked = false;

  Item(this.title, this.imagePath, this.isChecked);
}

showAlertDialog(BuildContext context) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    child: Text("Ok"),
    onPressed: () {},
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text("Congratulations !"),
    content: const Text(
        "Your Hunt is Hosted Successfully .Please Share This code H9W RTX 2T 8 to Invite your team members."),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
