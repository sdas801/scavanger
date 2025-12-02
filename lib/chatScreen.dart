import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:scavenger_app/HomeScreen.dart';
import 'package:scavenger_app/constants.dart';
import 'package:scavenger_app/services/api.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scavenger_app/CreatedGameDetailsResponse.dart';
import 'services/chat_socket_service.dart';

class ChatScreen extends StatefulWidget {
  final int gameId;
  final String? teamName;
  const ChatScreen({super.key, required this.gameId, this.teamName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  socket_io.Socket? socket;
  final Logger logger = Logger();
  int userid = 0;
  String username = "";
  bool isChartLoading = false;
  int host_id = 0;

  late final ChatSocketService _chat;

  @override
  void initState() {
    super.initState();
    _chat = ChatSocketService();
    _initUser();
    // When new messages come in, scroll to bottom if we're already near bottom
    _chat.addListener(_onServiceUpdate);
    _getgameDetails();
  }

  Future<void> _getgameDetails() async {
    ApiService.gameDetails(widget.gameId).then((value) {
      if (value.success) {
        var homeResponse = Result.fromJson(value.response);
        setState(() {
          host_id = homeResponse.hostBy;
        });
        _scrollToBottom();
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text('Login failed: ${value.message}'),
        // ));
      }
    });
  }

  void _onServiceUpdate() {
    if (!mounted) return;
    setState(() {});
    _scrollToBottom();
  }

  Future<void> _initUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('saved_userId')) {
      setState(() {
        userid = (prefs.getInt('saved_userId') ?? 0);
        username = widget.teamName ?? (prefs.getString('saved_userName') ?? "");
      });
    }
    // Optionally: fetch host id here and set _hostId
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _chat.removeListener(_onServiceUpdate);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _chat.sendMessage(text: text, username: username);
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    try {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      logger.e("Scroll to bottom error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = _chat.messages;
    return PopScope(
        canPop: false,
        // onPopInvoked: (bool didPop) async {
        //   if (didPop) {
        //     return;
        //   }
        // },
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? const Center(child: Text('No messages yet'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (_, index) {
                          final message = messages[index];
                          return _messageLayout(
                            name: message.sender,
                            alignName: message.sender == username
                                ? TextAlign.end
                                : TextAlign.start,
                            color: message.sender == username
                                ? Colors.blue[300]
                                : Colors.white,
                            time: message.timestamp,
                            align: TextAlign.left,
                            boxAlign: CrossAxisAlignment.start,
                            crossAlign: message.sender == username
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            nip: message.sender == username
                                ? BubbleNip.rightTop
                                : BubbleNip.leftTop,
                            text: message.message,
                            message_id: message.userId,
                          );
                        },
                      ),
              ),
              _sendMessageTextField(),
            ],
          ),
        ));
  }

  Widget _sendMessageTextField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(80)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.2),
                      offset: const Offset(0.0, 0.50),
                      spreadRadius: 1,
                      blurRadius: 1,
                    )
                  ]),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(fontSize: 14),
                      controller: _messageController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type a message",
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ),
          SizedBox(width: 5),
          InkWell(
            onTap: _sendMessage,
            child: Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _messageLayout({
    required String message_id,
    required String text,
    required String time,
    required Color? color,
    required TextAlign align,
    required CrossAxisAlignment boxAlign,
    required BubbleNip nip,
    required CrossAxisAlignment crossAlign,
    required String name,
    required TextAlign alignName,
  }) {
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: name == username
                  ? const Color.fromARGB(255, 198, 220, 248)
                  : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft:
                    name == username ? const Radius.circular(12) : Radius.zero,
                bottomRight:
                    name == username ? Radius.zero : const Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IntrinsicWidth(
              // Makes the box size adjust to content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (name != username)
                    Text(
                      host_id.toString() == message_id ? "Host" : name,
                      textAlign: alignName,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    text,
                    textAlign: align,
                    style: TextStyle(fontSize: 16),
                  ),
                  // SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      time,
                      textAlign: align,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
