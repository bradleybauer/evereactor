import 'package:eve_reactor/gui/widgets/summary_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../platform.dart';
import '../my_theme.dart';
import 'hover_button.dart';

class Header extends StatelessWidget {
  const Header({this.height, this.width, Key? key}) : super(key: key);

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    var rowButtons = <Widget>[
      // const GetMarketDataButton(),
      // SizedBox(width: MyTheme.appBarPadding),
      // const PasteClearButton(),
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

    final summaryAlign = Platform.isWeb() ? Alignment.center: Alignment.centerLeft;
    var stackWidgets = <Widget>[
      Align(
        alignment: summaryAlign,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding),
          child:SummaryBar(),
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
