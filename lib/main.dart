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

