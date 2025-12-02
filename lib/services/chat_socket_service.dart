import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants.dart'; // for ApiConstants.socketUrl / socketPath

class ChatMessage {
  final String message;
  final String sender;
  final String userId;
  final String timestamp; // already formatted for UI
  ChatMessage({
    required this.message,
    required this.sender,
    required this.userId,
    required this.timestamp,
  });
}

class ChatSocketService extends ChangeNotifier {
  static final ChatSocketService _instance = ChatSocketService._internal();
  factory ChatSocketService() => _instance;
  ChatSocketService._internal();

  io.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  int _userId = 0;
  int _roomId = 0;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  // Emits when a single *new* message arrives (useful for badges)
  final _onNewMessageController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get onNewMessage => _onNewMessageController.stream;

  void connect({
    required int userId,
    required int roomId,
    required String baseUrl,
    required String path,
  }) {
    _userId = userId;
    _roomId = roomId;

    // Reuse existing connection if already joined same room.
    if (isConnected && _roomId == roomId) return;

    // Close any previous connection
    _disposeSocket();

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setPath(path.startsWith('/') ? path : '/$path')
          .enableReconnection()
          .setReconnectionAttempts(9999)
          .setReconnectionDelay(1000)
          .build(),
    );

    _socket!.onConnect((_) {
      _joinRoom();
      // fetch history after join
      _socket?.emit("getMessages", {"roomId": _roomId});
    });

    _socket!.onReconnect((_) {
      _joinRoom();
      _socket?.emit("getMessages", {"roomId": _roomId});
    });

    _socket!.on("receiveMessages", (data) {
      // bulk history
      final parsed = _parseHistory(data);
      _messages
        ..clear()
        ..addAll(parsed);
      notifyListeners();
    });

    _socket!.on("receiveMessage", (data) {
      final msg = _parseOne(data);
      if (msg != null) {
        _messages.add(msg);
        notifyListeners();
        _onNewMessageController.add(msg);
      }
    });

    _socket!.onError((e) => debugPrint('socket error: $e'));
    _socket!.onConnectError((e) => debugPrint('socket connect error: $e'));

    _socket!.connect();
  }

  void _joinRoom() {
    final req = {"roomId": _roomId, "userId": _userId};
    _socket?.emit("joinRoom", req);
  }

  // Call from ChatScreen to send
  void sendMessage({
    required String text,
    required String username,
  }) {
    if (text.trim().isEmpty) return;
    final req = {
      "roomId": _roomId,
      "userId": _userId,
      "message": text,
      "username": username,
    };
    _socket?.emit('sendMessage', req);
  }

  // Helpers
  List<ChatMessage> _parseHistory(dynamic data) {
    final list = <ChatMessage>[];
    if (data is List) {
      for (var i = data.length - 1; i >= 0; i--) {
        final item = data[i];
        print(item);
        final one = _parseOne(item);
        if (one != null) list.add(one);
      }
    }
    return list;
  }

  ChatMessage? _parseOne(dynamic data) {
    if (data is! Map) return null;
    final userId = (data["userid"] ?? data["userId"])?.toString() ?? '';
    final sender = (data["name"] ?? data["username"] ?? "Unknown").toString();
    final text = (data["message"] ?? "").toString();
    final t = _safeFormatTime(data["timestamp"]);
    return ChatMessage(
      message: text,
      sender: sender,
      userId: userId,
      timestamp: t,
    );
    // note: if you want to drop empty texts, guard above
  }

  String _safeFormatTime(dynamic ts) {
    try {
      if (ts == null) return '';
      if (ts is String) {
        final trimmed = ts.trim();
        if (RegExp(r'^\d+$').hasMatch(trimmed)) {
          return _formatFromEpoch(int.parse(trimmed));
        }
        return DateFormat('hh:mm a').format(DateTime.parse(trimmed).toLocal());
      } else if (ts is int) {
        return _formatFromEpoch(ts);
      } else if (ts is double) {
        return _formatFromEpoch(ts.toInt());
      }
    } catch (_) {}
    return '';
  }

  String _formatFromEpoch(int n) {
    final isSec = n < 100000000000; // < 1e11
    final dt = DateTime.fromMillisecondsSinceEpoch(
      isSec ? n * 1000 : n,
      isUtc: true,
    ).toLocal();
    return DateFormat('hh:mm a').format(dt);
  }

  void _disposeSocket() {
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void leaveRoom() {
    try {
      _socket?.emit("leaveRoom", {"roomId": _roomId, "userId": _userId});
    } catch (_) {}
  }

  void disconnect() {
    // Keep instance but cut the wire (e.g., when leaving a specific page)
    leaveRoom();
    _disposeSocket(); // clear listeners + disconnect + dispose
    _messages.clear();
    notifyListeners();
  }

  void shutdown() {
    // Full teardown, e.g., on logout/app exit
    leaveRoom();
    _disposeSocket();
    _messages.clear();
    _userId = 0;
    _roomId = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposeSocket();
    _onNewMessageController.close();
    super.dispose();
  }
}
