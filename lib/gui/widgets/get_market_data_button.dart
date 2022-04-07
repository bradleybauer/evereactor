import 'package:flutter/material.dart';

import '../my_theme.dart';

class GetMarketDataButton extends StatefulWidget {
  const GetMarketDataButton({Key? key}) : super(key: key);

  @override
  State<GetMarketDataButton> createState() => _GetMarketDataButtonState();
}

enum _ButtonState {
  READY,
  LOADING,
  WAITING,
}

class _GetMarketDataButtonState extends State<GetMarketDataButton> {
  _ButtonState state = _ButtonState.READY;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: theme.colors.primary),
      width: 120,
      height: MyTheme.appBarButtonHeight,
    );
  }
}
