import 'package:flutter/material.dart';

//TextStyle(fontFamily: 'NotoSans', fontWeight: FontWeight.w600, color: theme.colors.onPrimary)

import 'package:EveIndy/gui/my_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage(this.bounds, {Key? key}) : super(key: key);

  final BoxConstraints bounds;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colors.background,
      child: Center(
        child: Container(
          constraints: bounds,
          color: theme.colors.secondaryContainer,
        ),
      ),
    );
  }
}
