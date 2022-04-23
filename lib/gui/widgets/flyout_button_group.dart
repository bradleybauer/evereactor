import 'package:EveIndy/gui/widgets/flyout_options.dart';
import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'flyout.dart';
import 'flyout_controller.dart';
import 'my_animated_container.dart';

const int NUMBUTTONS = 4;

class FooterFlyoutGroup extends StatefulWidget {
  const FooterFlyoutGroup({Key? key}) : super(key: key);

  @override
  State<FooterFlyoutGroup> createState() => _FooterFlyoutGroupState();
}

class _FooterFlyoutGroupState extends State<FooterFlyoutGroup> {
  final List<FlyoutController> controllers = [];

  @override
  void initState() {
    for (int i = 0; i < NUMBUTTONS; ++i) {
      final controller = FlyoutController(MyTheme.buttonFocusDuration, maxVotes: 1);
      controllers.add(controller);
      controller.addListener(() {
        setState(() {});
      });
    }

    super.initState();
  }

  void _closeOthers(int index) {
    for (int i = 0; i < NUMBUTTONS; ++i) {
      if (i != index) {
        if (controllers[i].isOpen) {
          controllers[i].close();
        }
      }
    }
  }

  Widget button(int i, IconData icon) {
    return MouseRegion(
      child: MyAnimatedContainer(
        color: controllers[i].isOpen ? theme.primary : theme.secondaryContainer,
        elevation: controllers[i].isOpen ? 3 : 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: MyTheme.appBarButtonHeight * .1),
          child: Icon(icon,
              size: MyTheme.appBarButtonHeight * .8,
              color: controllers[i].isOpen ? theme.onPrimary : theme.onSecondaryContainer),
        ),
        borderRadius: 4,
      ),
      onEnter: (e) => _closeOthers(i),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icons = <IconData>[Icons.question_mark, Icons.copy, Icons.memory_sharp, Icons.settings];
    final buttons = <Widget>[];
    for (int i = 0; i < NUMBUTTONS; ++i) {
      buttons.add(button(i, icons[i]));
    }
    final content = <Widget>[];
    final sizes = <Size>[];
    // Add QA
    content.add(PhysicalModel(
      color: Colors.transparent,
      elevation: 4,
      shadowColor: theme.shadow,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: 160,
        height: 160,
        color: Colors.blue,
        child: Center(child: Text('QA content')),
      ),
    ));
    sizes.add(Size(160, 160));
    // Add Copy
    content.add(PhysicalModel(
      color: Colors.transparent,
      elevation: 4,
      shadowColor: theme.shadow,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: 160,
        height: 160,
        color: Colors.blue,
        child: Center(child: Text('Copy content')),
      ),
    ));
    sizes.add(Size(160, 160));
    // Add Optimizer
    content.add(PhysicalModel(
      color: Colors.transparent,
      elevation: 4,
      shadowColor: theme.shadow,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: 160,
        height: 160,
        color: Colors.blue,
        child: Center(child: Text('Optimizer content')),
      ),
    ));
    sizes.add(Size(160, 160));
    // Add Options
    content.add(OptionsFlyout());
    sizes.add(OptionsFlyout.size);

    for (int i = 0; i < NUMBUTTONS; ++i) {
      buttons.add(MouseRegion(
        child: MyAnimatedContainer(
          color: controllers[i].isOpen ? theme.primary : theme.secondaryContainer,
          elevation: controllers[i].isOpen ? 3 : 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: MyTheme.appBarButtonHeight * .1),
            child: Icon(icons[i],
                size: MyTheme.appBarButtonHeight * .8,
                color: controllers[i].isOpen ? theme.onPrimary : theme.onSecondaryContainer),
          ),
          borderRadius: 4,
        ),
        onEnter: (e) => _closeOthers(i),
      ));
    }

    final rowChildren = <Widget>[];
    for (int i = 0; i < NUMBUTTONS; ++i) {
      if (i > 0) {
        rowChildren.add(const SizedBox(width: MyTheme.appBarPadding));
      }
      rowChildren.add(Flyout(
        child: buttons[i],
        content: content[i],
        contentSize: sizes[i],
        verticalOffset: MyTheme.appBarPadding * 2,
        windowPadding: MyTheme.appBarPadding,
        align: FlyoutAlign.appRight,
        openMode: FlyoutOpenMode.hover,
        controller: controllers[i],
      ));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: rowChildren);
  }
}
