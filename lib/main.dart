import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/selection_provider.dart';
import 'screens/team_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => SelectionProvider(),
      child: MaterialApp(
        title: 'IPL 2025 Team Selector',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Roboto',
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        home: const TeamSelectionScreen(),
      ),
    );
  }
}