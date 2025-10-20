import 'package:flutter/material.dart';
import 'screens/folders_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Act10App());
}

class Act10App extends StatelessWidget {
  const Act10App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Act10 Part B',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const FoldersScreen(),
    );
  }
}
