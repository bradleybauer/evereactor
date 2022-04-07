import 'dart:async';

import 'package:flutter/material.dart';

import '../../strings.dart';
import '../my_theme.dart';
import 'hover_button.dart';

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

// TODO this is just temporary code
class _GetMarketDataButtonState extends State<GetMarketDataButton> {
  _ButtonState state = _ButtonState.READY;

  @override
  Widget build(BuildContext context) {
    Widget widget;
    switch (state) {
      case _ButtonState.READY:
        widget = HoverButton(
            onTap: () {
              setState(() {
                state = _ButtonState.LOADING;
                Timer(const Duration(seconds: 2), () {
                  setState(() {
                    state = _ButtonState.WAITING;
                    Timer(const Duration(seconds: 2), () {
                      setState(() {
                        state = _ButtonState.READY;
                      });
                    });
                  });
                });
              });
            },
            builder: (hovered) {
              return Center(
                child: Text(Strings.getMarketData,
                    style: TextStyle(
                        fontFamily: 'NotoSans', fontSize: 12, color: hovered ? theme.colors.onPrimary : theme.colors.onSurfaceVariant)),
              );
            },
            borderColor: theme.colors.primary,
            borderRadius: 4,
            color: theme.colors.surfaceVariant,
            hoveredColor: theme.colors.primary);
        break;

      case _ButtonState.LOADING:
        widget = Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colors.primary),
            borderRadius: BorderRadius.circular(4),
            color: theme.colors.surfaceVariant,
          ),
          child: Center(child: const Text("loading", style: TextStyle(fontFamily: 'NotoSans', fontSize: 12))),
        );
        break;
      case _ButtonState.WAITING:
        widget = Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colors.primary),
            borderRadius: BorderRadius.circular(4),
            color: theme.colors.surfaceVariant,
          ),
          child: Center(child: const Text("waiting", style: TextStyle(fontFamily: 'NotoSans', fontSize: 12))),
        );
        break;
    }

    return ConstrainedBox(
      constraints: BoxConstraints.tight(Size(150, MyTheme.appBarButtonHeight)),
      child: widget,
    );
  }
}
