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


} 