import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
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
  DiscoveryService? _discovery;
  String? _myName;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();

    String? myName = prefs.getString('device_name');

    if (myName == null || myName.trim().isEmpty) {
      myName = await _promptForName(context);

      // If the user doesn't enter anything, use the system hostname
      if (myName == null || myName.trim().isEmpty) {
        myName = Platform.localHostname;
      }

      await prefs.setString('device_name', myName);
    }

    if (!mounted) return;

    setState(() {
      _myName = myName;
    });

    _discovery = DiscoveryService(
      myName: myName!,
      myTcpPort: 45679,
    );

    _discovery!.start();

    setState(() {});
  }

  Future<String?> _promptForName(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Name your device'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Device name',
              hintText: 'e.g. Pamal Phone',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isNotEmpty) {
                  Navigator.pop(context, name);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _discovery?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_discovery == null || _myName == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WavaShare'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.upload),
                text: 'Send',
              ),
              Tab(
                icon: Icon(Icons.download),
                text: 'Receive',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SendTab(discovery: _discovery!),
            ReceiveTab(
              discovery: _discovery!,
              myName: _myName!,
            ),
          ],
        ),
      ),
    );
  }
}

class SendTab extends StatelessWidget {
  final DiscoveryService discovery;

  const SendTab({
    super.key,
    required this.discovery,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Peer>>(
      stream: discovery.peersStream,
      initialData: const [],
      builder: (context, snapshot) {
        final peers = snapshot.data ?? [];

        if (peers.isEmpty) {
          return const Center(
            child: Text('Searching for nearby devices...'),
          );
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
  final String myName;

  const ReceiveTab({
    super.key,
    required this.discovery,
    required this.myName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Visible as "$myName"\nWaiting for incoming files...',
        textAlign: TextAlign.center,
      ),
    );
  }
}