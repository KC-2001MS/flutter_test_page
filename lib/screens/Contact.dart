import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class Contact extends StatefulWidget {
  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  late Future<String> _markdownData;

  @override
  void initState() {
    super.initState();
    _markdownData = loadMarkdownData();
  }

  Future<String> loadMarkdownData() async {
    return await rootBundle.loadString('markdown/contact.md');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _markdownData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading content'));
        } else {
          return Markdown(data: snapshot.data ?? '');
        }
      },
    );
  }
}
