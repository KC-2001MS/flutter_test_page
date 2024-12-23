import 'package:flutter/material.dart';

class SecondCard extends StatelessWidget {
  final Text title;
  final List<Widget> children;

  const SecondCard({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const Divider(color: Colors.grey),
          const SizedBox(height: 4),
          ...children.map((widget) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: widget,
              )),
        ],
      ),
    );
  }
}
