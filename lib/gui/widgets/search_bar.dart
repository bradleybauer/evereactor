import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/search.dart';
import '../my_theme.dart';
import 'flyout.dart';
import 'flyout_controller.dart';
import 'search_text_field.dart';
import 'table_search.dart';

class MySearchBar extends StatefulWidget {
  // TODO sad :( not really sure how to organize stuff like this.
  static const double SEARCHBARWIDTH = 275;

  const MySearchBar({Key? key}) : super(key: key);

  @override
  State<MySearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<MySearchBar> {
  late final flyoutController;
  final focusNode = FocusNode();
  final textEditController = TextEditingController();

  // Only search if the text changes.
  String previousText = '';

  @override
  void initState() {
    flyoutController = FlyoutController(MyTheme.buttonFocusDuration);
    textEditController.addListener(() {
      final text = textEditController.text.trim();
      if (text != previousText) {
        Provider.of<MySearchController>(context, listen: false).setSearchText(text);
        setState(() {
          previousText = text;
        });
      }
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        flyoutController.open();
      } else {
        flyoutController.close();
      }
      // set state so that 'text clear' button changes color to primary with the text field border if it is focused while hovered
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    textEditController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return Flyout(
      align: FlyoutAlign.childTopLeft,
      content: (ctx) => const SearchBarFlyoutContent(),
      openMode: FlyoutOpenMode.custom,
      sideOffset: MyTheme.appBarPadding * 2,
      controller: flyoutController,
      // TODO adding this MouseRegion widget made a bug appear in debug mode if I open the search flyout and hover the footer flyout group buttons.
      // do not want to go through the effort of reporting it at flutter github.
      child: MouseRegion(
          onEnter: (event) => flyoutController.open(),
          onExit: (event) => flyoutController.startCloseTimer(),
          child: SearchBarTextField(
            textEditController: textEditController,
            focusNode: focusNode,
          )),
    );
  }
}
