import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

import 'data/corporate_data.dart';
import 'data/filesystem_data.dart';
import 'data/government_data.dart';
import 'data/software_data.dart';
import 'models/card_config.dart';
import 'pages/theme_demo_page.dart';
import 'widgets/folder_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter FolderView Showcase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter FolderView Showcase'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            tooltip: 'Theme Demo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ThemeDemoPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive: 1 column on mobile, 2 columns on larger screens
            final crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
            final childAspectRatio = constraints.maxWidth > 900 ? 1.0 : 0.8;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
              children: [
                // 1. Corporate Departments (Folder Mode)
                FolderCard(
                  initialConfig: CardConfig(
                    title: '🏢 Corporate Departments',
                    mode: ViewMode.folder,
                    lineStyle: LineStyle.connector,
                    primaryColor: Colors.blue,
                    data: getCorporateData(),
                  ),
                ),

                // 2. Government Organization (Folder Mode)
                FolderCard(
                  initialConfig: CardConfig(
                    title: '🏛️ Government Organization',
                    mode: ViewMode.folder,
                    lineStyle: LineStyle.connector,
                    primaryColor: Colors.green,
                    data: getGovernmentData(),
                  ),
                ),

                // 3. File System (Tree Mode)
                FolderCard(
                  initialConfig: CardConfig(
                    title: '📁 File System',
                    mode: ViewMode.tree,
                    lineStyle: LineStyle.scope,
                    primaryColor: Colors.orange,
                    data: getFileSystemData(),
                  ),
                ),

                // 4. Software Components (Tree Mode)
                FolderCard(
                  initialConfig: CardConfig(
                    title: '⚙️ Software Architecture',
                    mode: ViewMode.tree,
                    lineStyle: LineStyle.scope,
                    primaryColor: Colors.purple,
                    data: getSoftwareComponentData(),
                    textTheme: const FolderViewTextTheme(
                      textStyle: TextStyle(fontSize: 14),
                      folderTextStyle: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.purple,
                      ),
                      parentTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                      childTextStyle: TextStyle(color: Colors.purpleAccent),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
