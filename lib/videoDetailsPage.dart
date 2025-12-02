import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:scavenger_app/model/videoPlayList.modal.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:scavenger_app/services/download.service.dart';
import 'package:scavenger_app/shared/nodatafound.widget.dart';
import 'package:scavenger_app/shared/video.widget.dart';
import 'package:shimmer/shimmer.dart';

typedef void VideoCallback(String val);

class videoListPage extends StatefulWidget {
  final int? gameId;
  final String? gameuniqueId;
  const videoListPage({super.key, this.gameId = 0, this.gameuniqueId = ''});

  @override
  _VideoListPage createState() => _VideoListPage();
}

class _VideoListPage extends State<videoListPage> {
  late TabController _tabController;
  bool _isLoading = false;
  List<HuntItemList> items = [];
  List<ChallengeList> challengeVideoList = [];
  final String baseUrl = "https://d1nb9mmvrnnzth.cloudfront.net";
  int selectedGameId = 0;

  @override
  void initState() {
    super.initState();
    _getgameDetails();
    challengeApiVideoList();
  }

  Future<void> _getgameDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    var reqData = {"limit": 100, "offset": 0};
    ApiService.getGameVideoList(reqData).then((value) {
      try {
        if (value.success) {
          log('${value.response}');
          final gameList = List<HuntItemList>.from(
              value.response.map((x) => HuntItemList.fromJson(x)));
          if (mounted) {
            setState(() {
              items = gameList;
            });
          }
        }
      } catch (error) {
        // print(error);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> challengeApiVideoList() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    var reqData = {"limit": 100, "offset": 0};
    ApiService.getChallengeVideoList(reqData).then((value) {
      try {
        if (value.success) {
          final gameItemList = List<ChallengeList>.from(
              value.response.map((x) => ChallengeList.fromJson(x)));
          if (mounted) {
            setState(() {
              challengeVideoList = gameItemList;
            });
          }
        }
      } catch (error) {
        // print(error);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  void deleteGame() async {
    try {
      final res = await ApiService.deleteGame({"id": selectedGameId});
      if (res.success) {
        _getgameDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to delete : ${res.message ?? "Unknown error"}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {}
  }

  void deleteChallenge() async {
    final res =
        await ApiService.deleteChallenge({"challengeid": selectedGameId});
    if (res.success) {
      challengeApiVideoList();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete : ${res.message ?? "Unknown error"}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    // } catch (error) {}
  }

  playVideo(BuildContext context, String url) {
    var vUrl = "https://d1nb9mmvrnnzth.cloudfront.net/$url";
    // print(vUrl);
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: SizedBox(
                  height: 400,
                  width: 500,
                  child: VideoWidget(url: vUrl, play: true)));
        });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text("Video Memories"),
            automaticallyImplyLeading: false, // Remove the back button
            backgroundColor: const Color(0xFF0B00AB),
            foregroundColor: Colors.white,
            bottom: const TabBar(
              //  controller: _tabController,
              indicatorColor: Colors.blue,
              labelColor: Color.fromARGB(255, 252, 252, 252),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "Hunt"),
                Tab(text: "Challenges"),
              ],
            ),
            // actions
            //   IconButton(
            //     icon: const Icon(Icons.notifications),
            //     onPressed: () {},
            //   ),
            // ],
          ),
          body: TabBarView(
            children: [
              _buildListView(items, _isLoading, baseUrl),
              _buildListChallengeView(challengeVideoList, _isLoading, baseUrl),
            ],
          ),
        ));
  }

  void confirmDelete(context, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // challenge
                if (type == 'challenge') {
                  deleteChallenge();
                } else {
                  deleteGame();
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onDownloadVideo(String url, String fileName) async {
    await downloadVideo(url, fileName);
  }

  Widget _buildListView(
      List<HuntItemList> items, bool _isLoading, String baseUrl) {
    return items.isEmpty && !_isLoading
        ? const NoDataFound()
        : ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: _isLoading ? items.length + 6 : items.length,
            itemBuilder: (context, index) {
              if (index < items.length) {
                return ListItem(
                  title: items[index].title,
                  subtitle: items[index].description,
                  imagePath: items[index].game_img,
                  videoFile: items[index].videoFile,
                  index: index,
                  playVideo: (val) {
                    // Play video function
                  },
                  onClick: (index, type) async {
                    if (type == 'download') {
                      String fullUrl = "$baseUrl/${items[index].videoFile}";
                      items[index].videoFile == "removed"
                          ? ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                              content: Text('Video was removed'),
                            ))
                          : await _onDownloadVideo(
                              fullUrl, items[index].videoFile);
                    } else {
                      selectedGameId = items[index].id;
                      confirmDelete(context, 'hunt');
                    }
                  },
                );
              } else {
                return _shimmerEffect();
              }
            },
          );
  }

  Widget _buildListChallengeView(
      List<ChallengeList> challengeList, bool _isLoading, String baseUrl) {
    return challengeList.isEmpty && !_isLoading
        ? const NoDataFound()
        : ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount:
                _isLoading ? challengeList.length + 6 : challengeList.length,
            itemBuilder: (context, index) {
              if (index < challengeList.length) {
                return ListItem(
                  title: challengeList[index].name,
                  subtitle: challengeList[index].description,
                  imagePath: challengeList[index].imageurl,
                  videoFile: challengeList[index].videofile,
                  index: index,
                  playVideo: (val) {
                    // Play video function
                  },
                  onClick: (index, String type) async {
                    if (type == 'download') {
                      String fullUrl =
                          "$baseUrl/${challengeList[index].videofile}";
                      challengeList[index].videofile == "removed"
                          ? ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                              content: Text('Video was removed'),
                            ))
                          : await _onDownloadVideo(
                              fullUrl, challengeList[index].videofile);
                    } else {
                      selectedGameId = challengeList[index].id;
                      confirmDelete(context, 'challenge');
                    }
                  },
                );
              } else {
                return _shimmerEffect();
              }
            },
          );
  }

  Widget _shimmerEffect() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 70,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

typedef void ItemClickCallback(int index, String type);

class ListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String videoFile;
  final VideoCallback playVideo;
  final int index;
  final ItemClickCallback onClick;

  const ListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.videoFile,
    required this.playVideo,
    required this.index,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: ListTile(
        onTap: () {
          playVideo(videoFile);
        },
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
            color: Color.fromRGBO(21, 55, 146, 1),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color.fromRGBO(19, 49, 131, 1),
            fontWeight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
            height: 1,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download),
              color: Colors.blue,
              onPressed: () => onClick(index, 'download'),
            ),
            const SizedBox(width: 5),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () => onClick(index, 'delete'),
            ),
          ],
        ),
      ),
    );
  }
}
