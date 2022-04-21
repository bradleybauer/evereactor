import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../adapters/search.dart';
import 'flyout_controller.dart';
import 'table_search.dart';
import '../my_theme.dart';
import 'flyout.dart';
import 'search_text_field.dart';

class SearchBar extends StatefulWidget {
  // TODO sad :( not really sure how to organize stuff like this.
  static const double SEARCHBARWIDTH = 275;

  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final flyoutController = FlyoutController(MyTheme.buttonFocusDuration);
  final focusNode = FocusNode();
  final textEditController = TextEditingController();

  // Only search if the text changes.
  String previousText = '';

  @override
  void initState() {
    textEditController.addListener(() {
      final text = textEditController.text.trim();
      if (text != previousText) {
        previousText = text;
        Provider.of<SearchAdapter>(context, listen: false).setSearchText(text);
        setState(() {}); // Need to rebuild so the text field clear button updates
      }
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        flyoutController.open();
      } else {
        flyoutController.close();
      }
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
    return Flyout(
      align: FlyoutAlign.childTopLeft,
      content: const SearchBarFlyoutContent(),
      contentSize: SearchBarFlyoutContent.size,
      openMode: FlyoutOpenMode.custom,
      verticalOffset: MyTheme.appBarPadding * 2,
      windowPadding: MyTheme.appBarPadding,
      // TODO adding this MouseRegion widget made a bug appear in debug mode if I open the search flyout and hover the footer flyout group buttons.
      // do not want to go through the effort of reporting it at flutter github.
      child: MouseRegion(
          onEnter: (event) => flyoutController.open(),
          onExit: (event) => flyoutController.startCloseTimer(),
          child: SearchBarTextField(
            textEditController: textEditController,
            focusNode: focusNode,
          )),
      controller: flyoutController,
    );
  }
}