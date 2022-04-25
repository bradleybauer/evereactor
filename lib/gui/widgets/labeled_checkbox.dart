import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../my_theme.dart';
import 'hover_button.dart';

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    Key? key,
    required this.value,
    required this.color,
    required this.hoverColor,
    required this.activeColor,
    required this.getLabel,
    required this.onTap,
  }) : super(key: key);

  final bool value;
  final Color color;
  final Color hoverColor;
  final Color activeColor;
  final Widget Function(bool, bool) getLabel;
  final Function() onTap;

  static const double height = 23;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return HoverButton(
      splashColor: theme.on(hoverColor).withOpacity(.5),
      borderRadius: 3,
      elevation: 0,
      hoveredElevation: 0,
      onTap: onTap,
      color: value ? activeColor : color,
      hoveredColor: hoverColor,
      builder: (hovered) => FocusTraversalGroup(
        descendantsAreFocusable: false,
        child: IgnorePointer(
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightForFinite(height: height),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Transform(
                  transform: Matrix4.diagonal3Values(.8, .8, .8),
                  alignment: Alignment.center,
                  child: Checkbox(
                    fillColor: MaterialStateProperty.all(value
                        ? (hovered ? theme.on(hoverColor) : theme.on(activeColor))
                        : hovered
                            ? theme.on(hoverColor)
                            : theme.on(color)),
                    checkColor: hovered
                        ? hoverColor
                        : value
                            ? activeColor
                            : Colors.transparent,
                    // activeColor: value ? theme.on(activeColor) : Colors.transparent,
                    value: value,
                    onChanged: (bool? _) {},
                    hoverColor: Colors.transparent,
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, MyTheme.appBarPadding, 0), child: getLabel(hovered, value)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
