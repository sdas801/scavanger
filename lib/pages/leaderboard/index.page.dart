import 'package:flutter/material.dart';
import 'package:scavenger_app/utility/random_picture.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/model/mainLeaderboard.model.dart';

/* 
  This is the leaderboard page. It is a stateful widget that displays the leaderboard of the game.
  The leaderboard is a list of users and their scores. The users are sorted by their scores in descending order.
  The leaderboard is fetched from the server and displayed in a list view.
*/

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  double borderWidth = 4.0;
  List<MainLeaderboardModel> gameList = [];

  @override
  void initState() {
    super.initState();
    getLeaderBoardData();
  }

  getLeaderBoardData() async {
    try {
      print('Getting Leaderboard Data');
      ApiService.mainLeaderBoard().then((res) {
        if (res.success) {
          setState(() {
            gameList = List<MainLeaderboardModel>.from(
                res.response.map((x) => MainLeaderboardModel.fromJson(x)));
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Container(
      padding: const EdgeInsets.all(0.0),
      margin: const EdgeInsets.all(0.0),
      height: screenSize.height,
      width: screenSize.width,
      color: const Color.fromRGBO(11, 0, 171, 1),
      child: Container(
          height: screenSize.height,
          width: screenSize.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0)),
          ),
          child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 60),
              child: gameList.isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'My Hunts',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Color.fromRGBO(21, 55, 146, 1),
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            height: 75,
                            width: screenSize.width,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: gameList.length,
                                itemBuilder: (ctx, elem) {
                                  return GameImageView(gameList[elem]);
                                }),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Row(
                            children: [
                              Text(
                                'Maga Contest Winner',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Color.fromRGBO(21, 55, 146, 1),
                                    fontSize: 19.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              Text(
                                'Filter by Series ',
                                style: TextStyle(
                                    color: Color.fromRGBO(70, 81, 110, 1),
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Image(
                                image:
                                    AssetImage('assets/images/filter_ico.png'),
                                width: 25,
                                height: 25,
                              )
                            ],
                          ),
                          Expanded(
                              child: ListView.separated(
                                  itemCount: gameList.length,
                                  separatorBuilder: (context, index) {
                                    return const Divider();
                                  },
                                  itemBuilder: (ctx, elem) {
                                    return LeaderboardItem(gameList[elem]);
                                  })),
                          const SizedBox(height: 100),
                        ])
                  : const Center(
                      child: Image(
                          image: AssetImage(
                              'assets/images/no-data-leaderboard.png')),
                    ))),
    ));
  }
}

class GameImageView extends StatelessWidget {
  double borderWidth = 4.0;
  double imageSize = 73;
  final MainLeaderboardModel gameDtl;
  GameImageView(this.gameDtl, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3.0), // Padding for border effect
      decoration: BoxDecoration(
          shape: BoxShape.circle, // Circular shape
          border: Border(
            top: BorderSide(
                color: const Color.fromRGBO(11, 0, 171, 1),
                width: borderWidth), // Border top width
            bottom: BorderSide(
                color: const Color.fromRGBO(11, 0, 171, 1),
                width: borderWidth), // Border bottom width
            left: BorderSide(
                color: const Color.fromRGBO(11, 0, 171, 1),
                width: borderWidth), // Border left width
            right: BorderSide(
                color: const Color.fromRGBO(11, 0, 171, 1),
                width: borderWidth), // Border right width
          )),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.0), // Adjust radius as needed
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            gameDtl.gameImg == '' || gameDtl.gameImg == null
                ? getPicture(imageSize, imageSize)
                : Image(
                    image: NetworkImage(gameDtl.gameImg ?? ''),
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                  ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardItem extends StatelessWidget {
  final MainLeaderboardModel gameDtl;
  const LeaderboardItem(this.gameDtl, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            gameDtl.title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(21, 55, 146, 1)),
          ),
        ),
        // Trophy and Money Row
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.emoji_events, color: Colors.orange, size: 20),
            SizedBox(width: 5),
            Text(
              "\$40",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Top 3 Users
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (gameDtl.topPlayers.length >= 2)
              buildProfileCard(
                  context,
                  gameDtl.topPlayers[1].userName,
                  {
                    "name": gameDtl.prizes?.secondDesc ?? "",
                    "img": gameDtl.prizes?.secondImg ?? ""
                  },
                  gameDtl.topPlayers[1].position.toString(),
                  2,
                  const Color.fromRGBO(14, 212, 255, 1),
                  gameDtl.topPlayers[1].userImg ??
                      'assets/images/profilePicfunny.png'),
            const SizedBox(width: 12),
            if (gameDtl.topPlayers.isNotEmpty)
              buildProfileCard(
                  context,
                  gameDtl.topPlayers[0].userName,
                  {
                    "name": gameDtl.prizes?.firstDesc ?? "",
                    "img": gameDtl.prizes?.firstImg ?? ""
                  },
                  gameDtl.topPlayers[0].position.toString(),
                  2,
                  const Color.fromRGBO(255, 212, 44, 1),
                  gameDtl.topPlayers[0].userImg ??
                      'assets/images/profilePicfunny.png',
                  isCrown: true),
            const SizedBox(width: 12),
            if (gameDtl.topPlayers.length >= 3)
              buildProfileCard(
                  context,
                  gameDtl.topPlayers[2].userName,
                  {
                    "name": gameDtl.prizes?.thirdDesc ?? "",
                    "img": gameDtl.prizes?.thirdImg ?? ""
                  },
                  gameDtl.topPlayers[2].position.toString(),
                  2,
                  const Color.fromRGBO(53, 225, 153, 1),
                  gameDtl.topPlayers[2].userImg ??
                      'assets/images/profilePicfunny.png'),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildProfileCard(BuildContext context, String itemName, dynamic prize,
      String description, int rank, Color borderColor, String imagePath,
      {bool isCrown = false}) {
    var cardWidth = MediaQuery.of(context).size.width * 0.27;
    print('width of container: ${MediaQuery.of(context).size.width * 0.27}');
    return Container(
      width: cardWidth,
      // color: Colors.red,
      child: Stack(
        children: [
          Container(
              width: cardWidth,
              margin: const EdgeInsets.only(top: 60),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 2),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 25, left: 10, right: 10, bottom: 10),
                    child: Column(
                      children: [
                        /* Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            imagePath != ''
                                ? CircleAvatar(
                                    radius: 30,
                                    backgroundImage: AssetImage(imagePath),
                                  )
                                : const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.person,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        size: 30),
                                  ),
                          ],
                        ), */
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            itemName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900]),
                          ),
                        ),
                        if (prize['name'] != '')
                          Text(
                            prize['name'],
                            style: const TextStyle(
                                fontSize: 14, color: Colors.orange),
                          ),
                        if (prize['img'] != '')
                          Image(
                              image: NetworkImage(prize['img']),
                              width: 30,
                              height: 30),
                      ],
                    ),
                  ),
                ],
              )),
          Positioned(
            top: 30,
            left: cardWidth / 4.5,
            child: imagePath != ''
                ? CircleAvatar(
                    radius: 28,
                    backgroundColor: borderColor,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(imagePath),
                    ),
                  )
                : const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        color: Color.fromARGB(255, 255, 255, 255), size: 30),
                  ),
          ),
          if (isCrown)
            Positioned(
              top: 0,
              left: cardWidth / 2.8,
              child: const Image(
                  image: AssetImage('assets/images/king_1.png'),
                  width: 30,
                  height: 30),
            ),
        ],
      ),
    );
  }
}
