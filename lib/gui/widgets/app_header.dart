import 'package:flutter/material.dart';

import 'paste_clear_button.dart';
import 'get_market_data_button.dart';
import 'hover_button.dart';
import '../my_theme.dart';
import '../../platform.dart';

class Header extends StatelessWidget {
  Header({this.height, this.width, Key? key}) : super(key: key);

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    var rowButtons = [
      const GetMarketDataButton(),
      const SizedBox(width: MyTheme.appBarPadding),
      const PasteClearButton(),
    ];

    // Add a close button on windows.
    if (!Platform.isWeb()) {
      rowButtons += [
        const SizedBox(width: MyTheme.appBarPadding),
        HoverButton(
          onTap: Platform.closeWindow,
          builder: (bool hovered) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: MyTheme.appBarButtonHeight * .1),
              child: Icon(Icons.close, size: MyTheme.appBarButtonHeight * .8, color: hovered ? theme.onPrimary : theme.onSecondaryContainer),
            );
          },
          color: theme.secondaryContainer,
          splashColor: theme.onPrimary.withOpacity(.25),
          hoveredColor: theme.primary,
          borderRadius: 4,
        ),
      ];
    }

    var stackWidgets = <Widget>[
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: theme.primary),
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
      color: theme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(0)),
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      shadowColor: theme.shadow,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(children: stackWidgets),
      ),
    );
  }
}
