import 'dart:io';
import 'package:flutter/material.dart';
import 'services/discovery_service.dart';
import 'models/peer.dart';

void main() {
  runApp(const WavaShareApp());
}

class WavaShareApp extends StatelessWidget {
  const WavaShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WavaShare',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        body: const TabBarView(
          children: [
            SendTab(),
            ReceiveTab(),
          ],
        ),
      ),
    );
  }
}

class SendTab extends StatelessWidget {
  final DiscoveryService discovery;
  const SendTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Peer>>(
      stream: discovery.peersStream,
      initialData: const [],
      builder: (context, snapshot) {
        final peers = snapshot.data ?? [];
        if (peers.isEmpty) {
          return const Center(child: Text('search for nearby devices'));
        }

        return ListView.builder(
          itemCount: peers.length,
          itemBuilder: (context, index) {
            final peer = peers[index];
            return ListTile(
              leading: const Icon(Icons.devices),
              title: Text(peer.name),
              subtitle: Text(peer.ip),
              onTap: (){
                // Handle peer selection
              },
            );
          }
        );
      }
    );
  }
}

class ReceiveTab extends StatelessWidget {
  final DiscoveryService discovery;
  const ReceiveTab({super.key, required this.discovery});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Visible as "${Platform.localHostname}"\nWaiting for incoming files...',
            textAlign: TextAlign.center),
    );
  }
}