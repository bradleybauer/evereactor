import 'package:flutter/material.dart';

import 'app_body.dart';
import '../my_theme.dart';
import 'app_header.dart';
import 'app_footer.dart';
import '../../platform.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.surfaceVariant,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: Platform.isWeb() ? const EdgeInsets.all(32) : null,
          width: theme.appWidth,
          child: ClipRRect(
            borderRadius: Platform.isWeb() ? BorderRadius.circular(10) : BorderRadius.zero,
            clipBehavior: Clip.antiAlias,
            child: Container(
              color: theme.background,
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
    );
  }
}
