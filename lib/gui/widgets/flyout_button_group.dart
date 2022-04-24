import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'flyout.dart';
import 'flyout_controller.dart';
import 'flyout_options.dart';
import 'my_animated_container.dart';

const int NUMBUTTONS = 4;

class FooterFlyoutGroup extends StatefulWidget {
  const FooterFlyoutGroup({Key? key}) : super(key: key);

  @override
  State<FooterFlyoutGroup> createState() => _FooterFlyoutGroupState();
}

class _FooterFlyoutGroupState extends State<FooterFlyoutGroup> {
  final FlyoutController controller = FlyoutController(MyTheme.buttonFocusDuration, maxVotes: 1);
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

  Widget button(int i, IconData icon) {
    bool selected = current == i && controller.isOpen;
    return MouseRegion(
      child: MyAnimatedContainer(
        color: selected ? theme.primary : theme.secondaryContainer,
        elevation: selected ? 3 : 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: MyTheme.appBarButtonHeight * .1),
          child: Icon(icon,
              size: MyTheme.appBarButtonHeight * .8, color: selected ? theme.onPrimary : theme.onSecondaryContainer),
        ),
        borderRadius: 4,
      ),
      onEnter: (e) => _open(i),
      onExit: (e) => controller.startCloseTimer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icons = <IconData>[Icons.question_mark, Icons.copy, Icons.memory_sharp, Icons.settings];
    final buttons = <Widget>[];
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
      if (i > 0) {
        buttons.add(const SizedBox(width: theme.appBarPadding));
      }
      buttons.add(button(i, icons[i]));
    }

    return Flyout(
      child: Row(mainAxisSize: MainAxisSize.min, children: buttons),
      content: ()=>content[current],
      sideOffset: MyTheme.appBarPadding * 2,
      align: FlyoutAlign.childTopRight,
      openMode: FlyoutOpenMode.custom,
      controller: controller,
    );

    // return Row(mainAxisSize: MainAxisSize.min, children: rowChildren);
  }
}
