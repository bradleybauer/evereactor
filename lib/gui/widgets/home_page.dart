import 'package:flutter/material.dart';

import 'content.dart';
import '../my_theme.dart';
import 'header.dart';
import 'footer.dart';
import '../../platform.dart';

class HomePage extends StatelessWidget {
  const HomePage(this.maxHeight, this.width, {Key? key}) : super(key: key);

  final double maxHeight;
  final double width;

  static const double headerHeight = 60;
  static const double footerHeight = 60;

  @override
  Widget build(BuildContext context) {
    var platformSpecificPadding = const EdgeInsets.all(0);
    if (Platform.isWeb()) {
      platformSpecificPadding = const EdgeInsets.all(32);
    }
    return Material(
      color: theme.colors.background,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: platformSpecificPadding,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            clipBehavior: Clip.antiAlias,
            child: Container(
              color: theme.colors.primaryContainer,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Header(height: headerHeight, width: width),
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: 0, maxHeight: maxHeight - headerHeight - footerHeight, maxWidth: width, minWidth: width),
                    child: SingleChildScrollView(
                      child: Content(width: width),
                    ),
                  ),
                  Footer(height: footerHeight, width: width),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
