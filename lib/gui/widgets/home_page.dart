import 'package:EveIndy/gui/widgets/content.dart';
import 'package:flutter/material.dart';

import 'content.dart';
import '../my_theme.dart';
import 'header.dart';
import 'footer.dart';

class HomePage extends StatelessWidget {
  const HomePage(this.maxHeight, this.width, {Key? key}) : super(key: key);

  final double maxHeight;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colors.background,
      child: Center(
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            color: theme.colors.primaryContainer,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Header(height: MyTheme.headerHeight, width: width),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: 0, maxHeight: maxHeight - MyTheme.headerHeight - MyTheme.footerHeight, maxWidth: width, minWidth: width),
                  child: SingleChildScrollView(
                    child: Content(),
                  ),
                ),
                Footer(height: MyTheme.footerHeight, width: width),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
