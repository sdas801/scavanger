import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scavenger_app/MyTeamResponse.dart';
import 'package:scavenger_app/services/api.service.dart';

class TeamListPage extends StatefulWidget {
  // final int gameId;
  final String? teamimg;
  final String? teamname;
  final String? teamId;
  final String? name;

  const TeamListPage({
    super.key,
    required this.teamimg,
    required this.teamname,
    required this.teamId,
    required this.name,
  });

  @override
  TeamListState createState() => TeamListState();
}

class TeamListState extends State<TeamListPage> {
  bool _isLoading = false;
  bool _isteamLoading = false;
  List<ResultMyteam> teamMembers = [];

  @override
  void initState() {
    super.initState();
    _myteam();
  }

  Future<void> _myteam() async {
    setState(() {
      _isteamLoading = true;
    });
    ApiService.getMyTeamList({"teamId": widget.teamId}).then((value) {
      try {
        if (value.success) {
          var jsonResponseData = List<ResultMyteam>.from(
              value.response.map((x) => ResultMyteam.fromJson(x)));
          teamMembers = jsonResponseData;
          setState(() {
            _isteamLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('hunt failed: ${value.message}'),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          _isteamLoading = false;
        });
      }
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
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 50, // Adjust size as needed
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: (widget.teamimg != null &&
                                widget.teamimg!.isNotEmpty)
                            ? Image.network(widget.teamimg!).image
                            : const AssetImage('assets/images/defaultImg.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ' ${widget.teamname ?? widget.name}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  _isteamLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : teamMembers.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: teamMembers.length,
                              itemBuilder: (context, index) {
                                return TeamMemberWidget(
                                  imageUrl: teamMembers[index].userImg ?? '',
                                  name: teamMembers[index].name,
                                  description: "",
                                );
                              },
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 15),
                                  Icon(
                                    Icons.inbox,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    "No new team member added yet",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Closes the modal/dialog
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red, // Change to your desired color
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamMemberWidget extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;

  const TeamMemberWidget({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8, top: 15, left: 28, right: 28),
      margin: const EdgeInsets.only(bottom: 3.0),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          imageUrl.isEmpty
              ? const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/defaultImg.jpg'),
                )
              : CircleAvatar(
                  backgroundImage: NetworkImage(imageUrl),
                  radius: 20.0,
                ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
