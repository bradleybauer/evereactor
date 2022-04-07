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

  final Color tmp = theme.colors.primary;

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
          color: theme.colors.surface,
          hoveredColor: theme.colors.primary,
          borderRadius: 4,
          builder: (bool hovered) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: MyTheme.appBarButtonHeight * .1),
              child: Icon(Icons.close, size: MyTheme.appBarButtonHeight * .8, color: hovered ? theme.colors.onPrimary : theme.colors.onSurface),
            );
          },
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
      elevation: 1.5,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(children: stackWidgets),
      ),
    );
  }
}
