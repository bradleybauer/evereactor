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

  static const double padding = 20;
  static const double buttonHeight = 27;

  final Color tmp = theme.colors.primary;

  @override
  Widget build(BuildContext context) {
    final boxDecor = BoxDecoration(
      color: theme.colors.secondaryContainer,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 1,
        ),
      ],
    );

    var rowButtons = [
      Container(
        width: 150,
        height: buttonHeight,
        color: tmp,
      ),
      const SizedBox(width: padding),
      Container(
        width: 120,
        height: buttonHeight,
        color: tmp,
      ),
    ];

    // Add a close button on windows.
    if (!Platform.isWeb()) {
      rowButtons += [
        const SizedBox(width: padding),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 45),
          child: MaterialButton(
            onPressed: Platform.closeWindow,
            child: Icon(Icons.close, color: theme.colors.onSecondaryContainer),
            hoverColor: tmp,
          ),
        ),
      ];
    }

    final stackWidgets = <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: padding),
              child: Container(
                width: 180,
                height: 34,
                color: tmp,
              ),
            ),
          )
        ] +
        [Platform.getWindowMoveWidget()] +
        [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: padding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: rowButtons,
              ),
            ),
          )
        ];

    return Container(
      decoration: boxDecor,
      width: width,
      height: height,
      child: Stack(children: stackWidgets),
    );
  }
}
