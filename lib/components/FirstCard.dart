import 'package:flutter/material.dart';

class FirstCard extends StatelessWidget {
  final Text title;
  final List<Widget> children;

  const FirstCard({
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
          Row(
            children: [
              Container(
                height: 15,
                width: 6,
                color: Colors.red,
              ),
              title,
            ],
          ),
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
