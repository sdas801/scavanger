import 'package:flutter/material.dart';
import 'package:scavenger_app/MyGameItemListResponse.dart';
import 'package:scavenger_app/services/api.service.dart';

/* 
  It is a statefull widget.
  This page will use to show players game items with accept and reject sign.
  This class will take gameId and gameType as parameter.
*/
class PlayerDashboard extends StatefulWidget {
  final int gameId;
  final String teamId;
  final String gameType;
  const PlayerDashboard(
      {super.key,
      required this.gameId,
      required this.teamId,
      required this.gameType});

  @override
  _PlayerDashboardState createState() => _PlayerDashboardState();
}

class _PlayerDashboardState extends State<PlayerDashboard> {
  List<ResultGameTeam> items = [];

  @override
  void initState() {
    super.initState();
    _myGameItemList();
  }

  Future<void> _myGameItemList() async {
    ApiService.fetchGameItems({"teamId": widget.teamId}).then((res) {
      try {
        if (res.success) {
          var itemList = List<ResultGameTeam>.from(
              res.response.map((x) => ResultGameTeam.fromJson(x)));
          setState(() {
            items = itemList;
          });
        }
      } catch (e) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Result'),
          actions: const [],
          backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
          foregroundColor: Colors.white,
        ),
        backgroundColor: const Color.fromRGBO(11, 0, 171, 1),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: Column(children: [
              // This is a list of items of the game. List should contain item image, item name, item description, tick and cross size
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListItem(
                      item: items[index],
                      gameType: widget.gameType,
                    );
                  },
                ),
              )
            ])));
  }
}

class ListItem extends StatelessWidget {
  bool _isLoading = false;
  final _PlayerDashboardState huntdash = new _PlayerDashboardState();
  final ResultGameTeam item;
  final String gameType;

  //ListItem({required this.item});
  //final VoidCallback onImageSelected;

//    ListItem({super.key, required this.onImageSelected,required this.item});
// final VoidCallback onImageSelected;

  ListItem({Key? key, required this.item, required this.gameType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;

    switch (item.status) {
      case "0":
        statusText = 'None';
        statusColor = Colors.grey;
        break;
      case "1":
        statusText = 'Accept';
        statusColor = Colors.green;
        break;
      case "2":
        statusText = 'Reject';
        statusColor = Colors.red;
        break;
      case "3":
        statusText = 'Resubmit';
        statusColor = Colors.yellow;
        break;
      default:
        statusText = 'Unknown';
        statusColor = Colors.black;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(item.item
                .imgUrl), //NetworkImage("http://res.cloudinary.com/dkmusbmoj/image/upload/v1721998933/ljtb22w93tavg1tzeiaf.jpg"),
            radius: 30.0,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.item.name,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(21, 55, 146, 1.0),
                  ),
                ),
                Text(
                  item.item.description,
                  style: const TextStyle(
                      color: Color.fromRGBO(70, 81, 111, 1), fontSize: 14.0),
                ),
                const SizedBox(height: 4.0),
                Text(
                  gameType == 'hunt' ? statusText : '',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          item.status == "1"
              ? const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/accept.png'),
                  radius: 25.0,
                )
              : const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/cross1.png'),
                  radius: 25.0,
                )
        ],
      ),
    );
  }
}
