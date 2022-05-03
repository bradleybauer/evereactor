import 'package:EveIndy/gui/widgets/hover_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../my_theme.dart';
import 'flyout.dart';
import 'flyout_controller.dart';
import 'flyout_options.dart';

const int NUMBUTTONS = 4;

class FooterFlyoutGroup extends StatefulWidget {
  const FooterFlyoutGroup({Key? key}) : super(key: key);

  @override
  State<FooterFlyoutGroup> createState() => _FooterFlyoutGroupState();
}

class _FooterFlyoutGroupState extends State<FooterFlyoutGroup> {
  final FlyoutController controller = FlyoutController(MyTheme.buttonFocusDuration * 2, maxVotes: 1);
  int current = 0;

  @override
  void initState() {
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  void _open(int index) {
    if (index != current) {
      controller.forceClose();
      setState(() {
        current = index;
      });
      controller.setDidContentChange(true);
    }
    controller.open();
  }

  Widget button(int i, IconData icon, MyTheme theme) {
    bool selected = current == i && controller.isOpen;
    return MouseRegion(
      child: HoverButton(
        builder: (hovered) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: MyTheme.appBarButtonHeight * .1),
            child: Icon(icon,
                size: MyTheme.appBarButtonHeight * .8, color: hovered ? theme.onPrimary : selected ? theme.onSecondary : theme.onSecondaryContainer),
          );
        },
        onTap: () => _open(i),
        color: selected ? theme.secondary : theme.secondaryContainer,
        borderRadius: 3,
        hoveredColor: theme.primary,
        hoveredElevation: 3,
      ),
      opaque: false,
      onEnter: (_) {
        if (selected) {
          _open(i);
        }
      },
      onExit: (_) => controller.startCloseTimer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final icons = <IconData>[Icons.settings, Icons.copy, Icons.memory_sharp, Icons.question_mark];
    final buttons = <Widget>[];
    for (int i = 0; i < NUMBUTTONS; ++i) {
      if (i > 0) {
        buttons.add(const SizedBox(width: MyTheme.appBarPadding));
      }
      buttons.add(button(i, icons[i], theme));
    }
    return Flyout(
      child: Row(mainAxisSize: MainAxisSize.min, children: buttons),
      content: (ctx) {
        if (current == 0) {
          final theme = Provider.of<MyTheme>(ctx);
          final color = theme.secondaryContainer;
          final base = theme.secondary;
          final headerStyle = TextStyle(
              fontFamily: 'NotoSans', fontSize: 15, fontWeight: FontWeight.w700, color: theme.onSecondaryContainer);
          final style = TextStyle(fontFamily: 'NotoSans', fontSize: 12, color: theme.onSecondaryContainer);
          return OptionsFlyout(controller, color, base, headerStyle, style);
        }
        return PhysicalModel(
          color: Colors.transparent,
          elevation: 4,
          shadowColor: theme.shadow,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Container(
            width: 160,
            height: 160,
            color: Colors.blue,
            child: Center(child: Text(['_', 'QA', 'Copy', 'Optimizer'][current] + ' content')),
          ),
        );
      },
      sideOffset: MyTheme.appBarPadding * 2,
      align: FlyoutAlign.childTopRight,
      openMode: FlyoutOpenMode.custom,
      controller: controller,
    );

    // return Row(mainAxisSize: MainAxisSize.min, children: rowChildren);
  }
}
