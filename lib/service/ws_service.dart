import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsService {
  WebSocketChannel? _channel;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  // Default: local test server. Change to your remote WS if needed.
  // NOTE: For Android emulator use 10.0.2.2 if your node server runs on host machine.
  String url = 'ws://10.0.2.2:8080'; // change to ws://localhost:8080 on some setups (desktop)
  bool get connected => _channel != null;

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void connect() {
    if (_channel != null) return;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.listen((msg) {
        try {
          final data = jsonDecode(msg as String) as Map<String, dynamic>;
          _controller.add(data);
        } catch (e) {
          // ignore parse errors
        }
      }, onError: (e) {
        _controller.addError(e);
        disconnect();
      }, onDone: () {
        disconnect();
      });
    } catch (e) {
      _controller.addError(e);
      disconnect();
    }
  }

  void disconnect() {
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }
}