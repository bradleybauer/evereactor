import 'package:flutter/material.dart';

import '../my_theme.dart';
import '../../platform.dart';

class Header extends StatelessWidget {
  Header({double? height, double? width, Key? key})
      : height = height,
        width = width,
        super(key: key);

  final double? height;
  final double? width;

  final Color tmp = theme.colors.primary;

  @override
  Widget build(BuildContext context) {
    var rowButtons = [
      Container(
        width: 150,
        height: MyTheme.appBarTextButtonHeight,
        color: tmp,
      ),
      const SizedBox(width: MyTheme.appBarPadding),
      Container(
        width: 120,
        height: MyTheme.appBarTextButtonHeight,
        color: tmp,
      ),
    ];

    // TODO would like the color of the icon to change on hover to onPrimary
    // Add a close button on windows.
    if (!Platform.isWeb()) {
      rowButtons += [
        const SizedBox(width: MyTheme.appBarPadding),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 45),
          child: MaterialButton(
            onPressed: Platform.closeWindow,
            child: Icon(Icons.close, color: theme.colors.onSecondaryContainer),
            color: theme.colors.secondaryContainer,
            hoverColor: theme.colors.primary,
            elevation: 0,
            hoverElevation: 0,
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
            width: 180,
            height: 34,
            color: tmp,
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
