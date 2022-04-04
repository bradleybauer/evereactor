import 'package:EveIndy/gui/widgets/my_animated_container.dart';
import 'package:flutter/material.dart';

import '../my_theme.dart';

class FooterFlyoutGroup extends StatefulWidget {
  const FooterFlyoutGroup({Key? key}) : super(key: key);

  @override
  State<FooterFlyoutGroup> createState() => _FooterFlyoutGroupState();
}

class _FooterFlyoutGroupState extends State<FooterFlyoutGroup> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // MyAnimatedContainer(
        //     focused: false,
        //     icon: Icons.question_mark,
        //     iconHeight: iconHeight,
        //     iconVerticalPadding: iconVerticalPadding,
        //     iconHorizontalPadding: 12), // Q/A
        // const SizedBox(width: MyTheme.appBarPadding),
        // MyAnimatedContainer(
        //     focused: false,
        //     icon: Icons.copy,
        //     iconHeight: iconHeight,
        //     iconVerticalPadding: iconVerticalPadding,
        //     iconHorizontalPadding: 12), // Copy
        // const SizedBox(width: MyTheme.appBarPadding),
        // MyAnimatedContainer(
        //     focused: false,
        //     icon: Icons.memory,
        //     iconHeight: iconHeight,
        //     iconVerticalPadding: iconVerticalPadding,
        //     iconHorizontalPadding: 12), // Optimize
        // const SizedBox(width: MyTheme.appBarPadding),
        // MyAnimatedContainer(
        //     focused: false,
        //     icon: Icons.settings,
        //     iconHeight: iconHeight,
        //     iconVerticalPadding: iconVerticalPadding,
        //     iconHorizontalPadding: 12), // Settings
      ],
    );
  }
}
