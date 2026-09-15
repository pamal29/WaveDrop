import 'package:flutter/material.dart';

void main(){
  runApp(const WavedropApp());
}

class WavedropApp extends StatelessWidget {
  const WavedropApp({super.key});

  @override
  Widget build(BuildContext context){
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
      length: 2, // number of tabs
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