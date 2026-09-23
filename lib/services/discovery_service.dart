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
      reuseAddress: false,
      reusePort: false,
    );
    _socket!.broadcastEnabled = true;
    _socket!.listen(_onEvent);

    _broadcastTimer = Timer.periodic(broadcastInterval, (_) => _sendBroadcast());
    _cleanupTimer = Timer.periodic(const Duration(seconds: 2), (_) => _removeStalePeers());

    _sendBroadcast();
  }

  Set<String>? _localIps;

  Future<Set<String>> _getLocalIps() async {
    if (_localIps != null) return _localIps!;
    final ips = <String>{};
    for (final iface in await NetworkInterface.list()) {
      for (final addr in iface.addresses) {
        ips.add(addr.address);
      }
    }
    _localIps = ips;
    return ips;
  }

  void _onEvent(RawSocketEvent event) async {
    if (event != RawSocketEvent.read) return;
    final datagram = _socket!.receive();
    if (datagram == null) return;

    final ip = datagram.address.address;
    final localIps = await _getLocalIps();
    if (localIps.contains(ip)) return; // ignore own broadcast

    try {
      final json = jsonDecode(utf8.decode(datagram.data));
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