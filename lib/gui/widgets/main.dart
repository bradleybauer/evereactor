import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../platform.dart';
import '../my_theme.dart';
import 'app_body.dart';
import 'app_footer.dart';
import 'app_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return Material(
      color: theme.surfaceVariant,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: Platform.isWeb() ? const EdgeInsets.all(32) : null,
          width: MyTheme.appWidth,
          child: PhysicalModel(
            clipBehavior: Clip.antiAlias,
            borderRadius: Platform.isWeb() ? BorderRadius.circular(10) : BorderRadius.zero,
            color: Colors.transparent,
            elevation: Platform.isWeb() ? 32 : 0,
            child: Container(
              color: theme.background,
              child: Stack(
                children: const [
                  Body(width: MyTheme.appWidth, verticalPadding: MyTheme.appBarHeight),
                  Header(height: MyTheme.appBarHeight, width: MyTheme.appWidth),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Footer(height: MyTheme.appBarHeight, width: MyTheme.appWidth)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
