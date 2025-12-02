import 'package:flutter/material.dart';

class DetailsWidget extends StatelessWidget {
  final String gameImg;
  final String gameName;
  final String fetchDate;
  final String fetchTime;
  final String desData;
  final List<String> splitData;
  final String gameType;

  const DetailsWidget({
    Key? key,
    required this.gameImg,
    required this.gameName,
    required this.fetchDate,
    required this.fetchTime,
    required this.desData,
    required this.gameType,
    this.splitData = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFF153792),
                width: 3,
              ),
            ),
            child: gameImg.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      gameImg,
                      fit: BoxFit.cover,
                      width: 150,
                      height: 150,
                    ),
                  )
                : const CircleAvatar(
                    radius: 75,
                    backgroundImage: AssetImage('assets/images/defaultImg.jpg'),
                  ),
          ),
          Text(
            gameName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF153792),
              fontSize: 22,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w800,
            ),
          ),
          if (fetchDate != "" && fetchTime != "") ...[
            Text(
              fetchDate,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF153792),
                fontSize: 12,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w800,
              ),
            ),
          ] else ...[
            const SizedBox.shrink(),
          ],
          Text(
            desData,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF153792),
              fontSize: 14,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w800,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
          ),
          const SizedBox(height: 5),
          if (splitData.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Rules:",
                  style: TextStyle(
                    color: Color(0xFF153792),
                    fontSize: 18,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10), // Add some spacing after "Rules:"
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: splitData.map((rule) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8.0), // Space between rules
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Icon(
                                Icons.circle,
                                color: Color(0xFF153792),
                                size: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              rule,
                              style: const TextStyle(
                                color: Color(0xFF153792),
                                fontSize: 14,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}
