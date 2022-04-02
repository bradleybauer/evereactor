import 'package:flutter/material.dart';

class Content extends StatelessWidget {
  const Content({this.width, Key? key}) : super(key: key);

  final double? width;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: width! * .25, height: 500, color: Colors.red),
        Container(width: width! * .25, height: 500, color: Colors.green),
      ],
    );
  }
}
