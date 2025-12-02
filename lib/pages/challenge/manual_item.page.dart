import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:scavenger_app/CreatedGameDetailsResponse.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/chalangeDetails.model.dart';
import 'package:scavenger_app/pages/challenge/item_add.page.dart';
import 'package:scavenger_app/HuntCreationCompleteScreen.dart';
import 'package:scavenger_app/services/challengeStepper.service.dart';

class ManualItemPagePage extends StatefulWidget {
  final int gameId;
  final String gameuniqueId;
  const ManualItemPagePage(
      {super.key, required this.gameId, required this.gameuniqueId});

  @override
  _ManualItemPagePageState createState() => _ManualItemPagePageState();
}

class _ManualItemPagePageState extends State<ManualItemPagePage> {
  List<HuntItem> items = [];

  bool _isLoading = false;
  bool _isItemAvailable = true;
  String gameTitle = "";
  String gamedesc = "";
  String gameduration = "";
  String gameImg = '';

  void initState() {
    _getgameDetails();
  }

  Future<void> _getgameDetails() async {
    setState(() {
      _isLoading = true;
    });

    ApiService.gameDetails(widget.gameId).then((res) {
      try {
        if (res.success) {
          final homeResponse = ChallangeDetailsModel.fromJson(res.response);
          gameTitle = homeResponse.title;
          gamedesc = homeResponse.description;
          gameImg = homeResponse.gameImg ?? '';
          setState(() {
            items = homeResponse.items;
          });
        }
      } catch (error) {
        // print(error);
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  void _handleCallback() {
    _getgameDetails();
    // You can perform any action here based on the returned result
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
        title: const Text("Create a Quest"),
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
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Add your items',
                              style: TextStyle(
                                color: Color(0xFF153792),
                                fontSize: 24,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w800,
                                height: 0,
                              ),
                            ),
                          ),
                          // const SizedBox(height: 20),
                          ChallengeStepperTabPage(activeStep: 1, totalStep: 5),
                          Container(
                            padding: const EdgeInsets.all(0.0),
                            width: screenSize.width,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x99EBF0FF),
                                  blurRadius: 14,
                                  offset: Offset(0, 4),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Profile Image
                                      gameImg == ''
                                          ? const Image(
                                              image: AssetImage(
                                                  'assets/images/game-default.jpg'),
                                              height: 50,
                                              width: 50)
                                          : CircleAvatar(
                                              radius: 25,
                                              backgroundImage:
                                                  NetworkImage(gameImg)),
                                      const SizedBox(width: 10),
                                      // Title and Time
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              gameTitle,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    21, 55, 146, 1),
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Description
                                  Text(
                                    gamedesc,
                                    style: const TextStyle(
                                      color: Color.fromRGBO(79, 68, 68, 1),
                                      fontSize: 14,
                                    ),
                                  ),

                                  // Coins
                                ],
                              ),
                            ),
                          ),
                          // Add Item Button
                        ]),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(
                          16.0), // Adjust padding as needed
                      child: IconButton(
                        icon: Image.asset('assets/images/additm.png'),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            constraints: BoxConstraints.tight(
                              Size(
                                MediaQuery.of(context).size.width,
                                MediaQuery.of(context).size.height * .8,
                              ),
                            ),
                            builder: (context) => AddItemManualy(
                              gameId: widget.gameId,
                            ),
                          ).whenComplete(() {
                            print('completed');
                            _handleCallback();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _isItemAvailable
                      ? const Text('')
                      : const Center(
                          child: Text('Please add at least one item to proceed',
                              style:
                                  TextStyle(color: Colors.red, fontSize: 12)),
                        ),

                  // Expanded(
                  ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const ClampingScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListItem(
                        title: items[index].name!,
                        subtitle: items[index].description!,
                        imagePath: items[index].imgUrl!,
                        id: items[index].id,
                        index: index,
                        onClick: (val, type, index) {
                          if (type == 'edit') {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              constraints: BoxConstraints.tight(Size(
                                  MediaQuery.of(context).size.width,
                                  MediaQuery.of(context).size.height * .8)),
                              builder: (context) => AddItemManualy(
                                  gameId: widget.gameId,
                                  itemId: val,
                                  itemName: items[index].name!,
                                  itemDescription: items[index].description!,
                                  itemImgUrl: items[index].imgUrl!),
                            ).whenComplete(() {
                              print('completed');
                              _handleCallback();
                            });
                          } else if (type == 'delete') {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Delete Confirmation"),
                                  content: const Text(
                                      "Are you sure you want to delete the item?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: const Text("No",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        ApiService.deleteItem(items[index].id)
                                            .then((res) {
                                          if (res.success) {
                                            // Perform any additional actions here
                                            Fluttertoast.showToast(
                                              msg: "Item deleted successfully",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );
                                            _handleCallback();
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: "Failed to delete the item",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );
                                          }
                                        });
                                      },
                                      child: Text("Yes"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      );
                    },
                  ),
                  // ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (items.isNotEmpty) {
                          /* Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChallengeTimeSet(
                                      gameId: widget.gameId,
                                      gameuniqueId: widget.gameuniqueId))); */
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HuntCreationCompleteScreen(
                                          gameId: widget.gameId,
                                          gameuniqueId: widget.gameuniqueId,
                                          gameType: 'challenge',
                                          cardType: 'host',
                                          myteam: '')));
                        } else {
                          setState(() {
                            _isItemAvailable = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF153792),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ), //_login,
                      child: const Text('Next'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef void ItemClickCallback(int val, String type, int index);

class ListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final int id;
  final int index;

  final ItemClickCallback onClick;

  const ListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.id,
    required this.index,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 0.0),
      color: Colors.white,
      child: ListTile(
        leading: imagePath != ''
            ? CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imagePath),
              )
            : const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/images/defaultImg.jpg'),
              ),
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(21, 55, 146, 1)),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color.fromRGBO(70, 81, 111, 1),
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 20,
                  color: Color.fromRGBO(21, 55, 146, 1),
                ),
                onPressed: () {
                  onClick(id, 'edit', index);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 20,
                  color: Color.fromRGBO(221, 4, 4, 1),
                ),
                onPressed: () {
                  onClick(id, 'delete', index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
