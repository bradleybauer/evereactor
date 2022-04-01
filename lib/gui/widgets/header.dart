import 'package:flutter/material.dart';

import 'package:EveIndy/gui/my_theme.dart';

class Header extends StatelessWidget {
  const Header({double? height, double? width, Key? key})
      : height = height,
        width = width,
        super(key: key);

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.secondaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      width: width,
      height: height,
    );
  }
}
