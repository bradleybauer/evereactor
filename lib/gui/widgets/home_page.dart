import 'package:flutter/material.dart';

import 'body.dart';
import '../my_theme.dart';
import 'header.dart';
import 'footer.dart';
import '../../platform.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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
            constraints: const BoxConstraints.tightForFinite(width: MyTheme.appWidth),
            child: ClipRRect(
              borderRadius: clipRadius,
              clipBehavior: Clip.antiAlias,
              child: Container(
                color: theme.colors.background,
                child: Stack(
                  children: [
                    const Body(width: MyTheme.appWidth, verticalPadding: MyTheme.appBarHeight),
                    Header(height: MyTheme.appBarHeight, width: MyTheme.appWidth),
                    const Align(alignment: Alignment.bottomCenter, child: Footer(height: MyTheme.appBarHeight, width: MyTheme.appWidth)),
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
