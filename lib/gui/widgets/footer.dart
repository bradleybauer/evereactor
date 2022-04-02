import 'package:flutter/material.dart';

import 'package:EveIndy/gui/my_theme.dart';

class Footer extends StatelessWidget {
  const Footer({double? height, double? width, Key? key})
      : height = height,
        width = width,
        super(key: key);

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colors.secondaryContainer,
      width: width,
      height: height,
    );
  }
}
