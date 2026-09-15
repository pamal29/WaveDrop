import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/peer.dart';


class DiscoveryService {
  static const int discoveryPort = 45678;
  static const Duration discoveryInterval = Duration(seconds: 2);
  static const Duration peerTimeout = Duration(seconds: 6);

  RawDatagramSocket? _socket;
  Timer? _discoveryTimer;
  Timer? _cleanupTimer;

  final String myName;
  final int myTcpPort;

  final Map<String, Peer> _peers = {};
  final _peerController = StreamController<List<Peer>>.broadcast(); //send notifications when peer list changes
  Stream<List<Peer>> get peersStream => _peerController.stream; //for outside code read-only stream

  DiscoveryService({
    required this.myName, 
    required this.myTcpPort
  });

  Future<void> start() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, discoveryPort);
    _socket!.broadcastEnabled = true;

    _socket!.listen(_onEvent);

    _broadcastTimer = Timer.periodic(broadcastInterval, (_) => _sendBroadcast());
    _cleanupTimer = Timer.periodic(const Duration(seconds: 2), (_) => _removeStalePeers());

    _sendBroadcast();
  }

  void _onEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final datagram = _socket!.receive();
    if (datagram == null) return;

    try {
      final json = jsonDecode(utf8.decode(datagram.data));
      final ip = datagram.address.address;

      if (json['name'] == myName) return; // ignore our own broadcast

      final peer = Peer.fromJson(json, ip);
      _peers[ip] = peer;
      _peersController.add(_peers.values.toList());
    } catch (_) {
      // ignore malformed packets
    }
  }

} 