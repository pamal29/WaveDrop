import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/peer.dart';

class DiscoveryService {
  static const int discoveryPort = 45678;
  static const Duration broadcastInterval = Duration(seconds: 2);
  static const Duration peerTimeout = Duration(seconds: 6);

  RawDatagramSocket? _socket;
  Timer? _broadcastTimer;
  Timer? _cleanupTimer;

  final String myName;
  final int myTcpPort;

  final Map<String, Peer> _peers = {};
  final _peersController = StreamController<List<Peer>>.broadcast();
  Stream<List<Peer>> get peersStream => _peersController.stream;

  DiscoveryService({required this.myName, required this.myTcpPort});

  Future<void> start() async {
    _socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4, 
      discoveryPort,
      reuseAddress: true,
      reusePort: true, 
    );
    _socket!.broadcastEnabled = true;

    _socket!.listen(_onEvent);

    _broadcastTimer = Timer.periodic(broadcastInterval, (_) => _sendBroadcast());
    _cleanupTimer = Timer.periodic(const Duration(seconds: 2), (_) => _removeStalePeers());

    _sendBroadcast();
  }

  void _onEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return; //not a read event
    final datagram = _socket!.receive();
    if (datagram == null) return;

    try {
      final json = jsonDecode(utf8.decode(datagram.data));
      final ip = datagram.address.address;

      //if (json['name'] == myName) return; // ignore our own broadcast

      final peer = Peer.fromJson(json, ip);
      _peers[ip] = peer;
      _peersController.add(_peers.values.toList());
    } catch (_) {
      // ignore malformed packets
    }
  }

  void _sendBroadcast() {
    final payload = jsonEncode({'name': myName, 'port': myTcpPort});
    final data = utf8.encode(payload);
    _socket?.send(data, InternetAddress('255.255.255.255'), discoveryPort);
  }

  void _removeStalePeers() {
    final now = DateTime.now();
    final before = _peers.length;
    _peers.removeWhere((_, peer) => now.difference(peer.lastSeen) > peerTimeout);
    if (_peers.length != before) {
      _peersController.add(_peers.values.toList());
    }
  }

  void stop() {
    _broadcastTimer?.cancel();
    _cleanupTimer?.cancel();
    _socket?.close();
    _peersController.close();
  }
}