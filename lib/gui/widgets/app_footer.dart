import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../my_theme.dart';
import 'flyout_button_group.dart';
import 'get_market_data_button.dart';
import 'search_bar.dart';

class Footer extends StatelessWidget {
  const Footer({this.height, this.width, Key? key}) : super(key: key);

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final stackWidgets = <Widget>[
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              GetMarketDataButton(),
              SizedBox(width:10),
              FooterFlyoutGroup(),
            ],
          ),
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding),
          child: const SearchBar(),
        ),
      ),
    ];

    return Container(
      color: theme.surface,
      width: width,
      height: height,
      child: Stack(children: stackWidgets),
    );
  }
}
