import 'package:EveIndy/gui/widgets/flyout_controller.dart';
import 'package:EveIndy/gui/widgets/search_bar_flyout_content.dart';
import 'package:flutter/material.dart';

import '../../search.dart';
import '../my_theme.dart';
import 'flyout.dart';
import 'hover_button.dart';
import 'search_bar_text_field.dart';

// TODO sad :( not really sure how to organize stuff like this.
class SearchBar extends StatefulWidget {
  static const double SEARCHBARWIDTH = 275;

  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final flyoutController = FlyoutController(MyTheme.buttonFocusDuration);
  final focusNode = FocusNode();
  final textEditController = TextEditingController();
  late MyFilterSearch search;

  @override
  void initState() {
    search = MyFilterSearch();
    textEditController.addListener(() {
      setState(() {});
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
      contentSize: SearchBarFlyoutContent.CONTENTSIZE,
      openMode: FlyoutOpenMode.custom,
      verticalOffset: MyTheme.appBarPadding * 2,
      windowPadding: MyTheme.appBarPadding,
      // TODO adding this MouseRegion widget made a bug appear in debug mode if I open the search flyout and hover the footer flyout group buttons.
      // do not want to go through the effort of reporting it at flutter github.
      child: MouseRegion(
          onEnter: (event) => flyoutController.open(),
          onExit: (event) => flyoutController.startCloseTimer(),
          child: SearchBarTextField(search: search, textEditController: textEditController, focusNode: focusNode)),
      controller: flyoutController,
    );
  }
}
