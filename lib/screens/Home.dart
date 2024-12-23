import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final orientation = MediaQuery.of(context).orientation;
        final width = constraints.maxWidth;

        String getBackgroundImage() {
          if (width < 1080) {
            if (orientation == Orientation.portrait) {
              return 'assets/images/出雲大社607P.jpg';
            } else {
              return 'assets/images/出雲大社1080.jpg';
            }
          } else if (width < 1620) {
            if (orientation == Orientation.portrait) {
              return 'assets/images/出雲大社1080P.jpg';
            } else {
              return 'assets/images/出雲大社1920.jpg';
            }
          } else if (width < 3456) {
            return 'assets/images/出雲大社3456.jpg';
          } else {
            return 'assets/images/出雲大社5120.jpg';
          }
        }

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(getBackgroundImage()),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Text(
                    'より効率的に。',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '私の欲しいものを\n私自身の手で作り出します',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
