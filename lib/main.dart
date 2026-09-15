import 'package:flutter/material.dart';

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
  const SendTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Send screen — pick a file to share'),
    );
  }
}

class ReceiveTab extends StatelessWidget {
  const ReceiveTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Receive screen — waiting for incoming files'),
    );
  }
}