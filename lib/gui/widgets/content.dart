import 'package:flutter/material.dart';

class Content extends StatelessWidget {
  const Content({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 100, height: 500, color: Colors.red),
        Container(width: 100, height: 500, color: Colors.green),
      ],
    );
  }
}
