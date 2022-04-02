import 'package:flutter/material.dart';

import '../my_theme.dart';

class Content extends StatelessWidget {
  const Content({this.width, Key? key}) : super(key: key);

  final double? width;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: width, height: 2000, color: theme.colors.background),
      ],
    );
  }
}
