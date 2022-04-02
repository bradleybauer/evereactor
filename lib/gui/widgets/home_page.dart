import 'package:flutter/material.dart';

import 'body.dart';
import '../my_theme.dart';
import 'header.dart';
import 'footer.dart';
import '../../platform.dart';

class HomePage extends StatelessWidget {
  const HomePage(this.minHeight, this.width, {Key? key}) : super(key: key);

  final double minHeight;
  final double width;

  static const double headerHeight = 60;
  static const double footerHeight = 60;

  @override
  Widget build(BuildContext context) {
    var platformSpecificPadding = const EdgeInsets.all(0);
    var clipRadius = const BorderRadius.all(Radius.circular(0));
    if (Platform.isWeb()) {
      platformSpecificPadding = const EdgeInsets.all(32);
      clipRadius = const BorderRadius.all(Radius.circular(10));
    }
    return Material(
      color: theme.colors.background,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: platformSpecificPadding,
          child: ConstrainedBox(
            constraints: BoxConstraints.tightForFinite(width: width),
            child: ClipRRect(
              borderRadius: clipRadius,
              clipBehavior: Clip.antiAlias,
              child: Container(
                color: theme.colors.primaryContainer,
                child: Stack(
                  children: [
                    Body(width: width, verticalPadding: headerHeight),
                    Header(height: headerHeight, width: width),
                    Align(alignment: Alignment.bottomCenter, child: Footer(height: footerHeight, width: width)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
