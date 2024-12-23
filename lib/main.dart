import 'package:flutter/material.dart';
import 'screens/Home.dart';
import 'screens/Product.dart';
import 'screens/Contact.dart';
import 'themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '【SwiftUIアプリ開発】いろいろポートフォリオ',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: Content(),
    );
  }
}

class Content extends StatefulWidget {
  const Content({super.key});

  @override
  State<Content> createState() => ContentState();
}

class ContentState extends State<Content> with SingleTickerProviderStateMixin {
  static const List<Tab> tabs = [
    Tab(text: 'ホーム'),
    Tab(text: 'コンテンツ'),
    Tab(text: '問い合わせ'),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'いろいろポートフォリオ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Home(),
          Product(),
          Contact(),
        ],
      ),
    );
  }
}
