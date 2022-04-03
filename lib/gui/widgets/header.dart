import 'package:flutter/material.dart';

import '../my_theme.dart';
import '../../platform.dart';

class Header extends StatelessWidget {
  Header({this.height, this.width, Key? key}) : super(key: key);

  final double? height;
  final double? width;

  final Color tmp = theme.colors.primary;

  @override
  Widget build(BuildContext context) {
    var rowButtons = [
      Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: tmp),
        width: 150,
        height: MyTheme.appBarButtonHeight,
      ),
      const SizedBox(width: MyTheme.appBarPadding),
      Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: tmp),
        width: 120,
        height: MyTheme.appBarButtonHeight,
      ),
    ];

    // TODO would like the color of the icon to change on hover to onPrimary
    // Add a close button on windows.
    if (!Platform.isWeb()) {
      rowButtons += [
        const SizedBox(width: MyTheme.appBarPadding),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 45),
          child: GestureDetector(
            onTap: Platform.closeWindow,
            child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: theme.colors.primary),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: MyTheme.appBarButtonHeight * .1),
                  child: Icon(Icons.close, size: MyTheme.appBarButtonHeight * .8, color: theme.colors.onPrimary),
                )),
          ),
        ),
      ];
    }

    var stackWidgets = <Widget>[
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: tmp),
            width: 180,
            height: MyTheme.appBarButtonHeight,
          ),
        ),
      )
    ];
    if (!Platform.isWeb()) {
      stackWidgets += [Platform.getWindowMoveWidget()];
    }
    stackWidgets += [
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: rowButtons,
          ),
        ),
      )
    ];

    return PhysicalModel(
      color: theme.colors.secondaryContainer,
      borderRadius: const BorderRadius.all(Radius.circular(0)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(children: stackWidgets),
      ),
    );
  }
}
