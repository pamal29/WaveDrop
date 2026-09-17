import 'dart:io';
import 'package:flutter/material.dart';
import 'services/discovery_service.dart';
import 'models/peer.dart';

void main() {
  runApp(const WavaDropApp());
}

class WavaDropApp extends StatelessWidget {
  const WavaDropApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WavaDrop',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DiscoveryService _discovery;

  @override
  void initState() {
    super.initState();
    _discovery = DiscoveryService(
      myName: Platform.localHostname,
      myTcpPort: 45679,
    );
    _discovery.start();
  }

  @override
  void dispose() {
    _discovery.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WavaShare'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.upload), text: 'Send'),
              Tab(icon: Icon(Icons.download), text: 'Receive'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SendTab(discovery: _discovery),
            ReceiveTab(discovery: _discovery),
          ],
        ),
      ),
    );
  }
}

class SendTab extends StatelessWidget {
  final DiscoveryService discovery;
  const SendTab({super.key, required this.discovery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Peer>>(
      stream: discovery.peersStream,
      initialData: const [],
      builder: (context, snapshot) {
        final peers = snapshot.data ?? [];
        if (peers.isEmpty) {
          return const Center(child: Text('Searching for nearby devices...'));
        }
        return ListView.builder(
          itemCount: peers.length,
          itemBuilder: (context, index) {
            final peer = peers[index];
            return ListTile(
              leading: const Icon(Icons.devices),
              title: Text(peer.name),
              subtitle: Text(peer.ip),
              onTap: () {
                // TODO: pick a file and send to this peer
              },
            );
          },
        );
      },
    );
  }
}

class ReceiveTab extends StatelessWidget {
  final DiscoveryService discovery;
  const ReceiveTab({super.key, required this.discovery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Visible as "${Platform.localHostname}"\nWaiting for incoming files...',
          textAlign: TextAlign.center),
    );
  }
}