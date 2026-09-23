import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:window_manager/window_manager.dart';

import 'app/destinations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    await windowManager.setSize(const Size(1200, 600));
    await windowManager.center();
  }

  runApp(const MyApp());
}

/// The example app: the shell over [FolderViewDestinations].
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _themeController = ExampleThemeController(ThemeMode.light);

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExampleThemeScope(
      controller: _themeController,
      child: ListenableBuilder(
        listenable: _themeController,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FlutterFolderView Examples',
          theme: exampleTheme(Brightness.light),
          darkTheme: exampleTheme(Brightness.dark),
          themeMode: _themeController.mode,
          home: const ShellPage(
            title: 'FlutterFolderView Examples',
            createDestinations: FolderViewDestinations.new,
          ),
        ),
      ),
    );
  }
}
