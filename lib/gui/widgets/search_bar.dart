import 'package:EveIndy/gui/widgets/flyout_controller.dart';
import 'package:flutter/material.dart';

import '../../search.dart';
import '../my_theme.dart';
import 'flyout.dart';
import 'hover_button.dart';

// TODO sad :( not really sure how to organize stuff like this.
const double SEARCHBARWIDTH = 275;
const Size CONTENTSIZE = Size(340, 200);

class SearchBar extends StatefulWidget {
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
      contentSize: CONTENTSIZE,
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

class SearchBarFlyoutContent extends StatelessWidget {
  const SearchBarFlyoutContent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      elevation: 4,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: CONTENTSIZE.width,
        height: CONTENTSIZE.height,
        color: const Color.fromARGB(255, 198, 221, 240),
        child: const Center(
            child: Text(
          'search results',
          style: TextStyle(fontFamily: 'NotoSans', fontSize: 32),
        )),
      ),
    );
  }
}

class SearchBarTextField extends StatelessWidget {
  const SearchBarTextField({
    Key? key,
    required this.search,
    required this.textEditController,
    required this.focusNode,
  }) : super(key: key);

  final MyFilterSearch search;
  final TextEditingController textEditController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (text) {
        if (text != '') {
          search.search(text);
        }
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        suffixIcon: Container(
          child: textEditController.text != ''
              ? ClipRRect(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                  child: HoverButton(
                    onTap: textEditController.clear,
                    color: Colors.transparent,
                    hoveredColor: theme.colors.primary,
                    hoveredElevation: 0,
                    builder: (bool hovered) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: MyTheme.appBarButtonHeight * .1),
                        child: Icon(Icons.close, size: MyTheme.appBarButtonHeight * .8, color: hovered ? theme.colors.onPrimary : null),
                      );
                    },
                  ),
                )
              : const Icon(Icons.search),
        ),
        fillColor: theme.colors.surfaceVariant,
        filled: true,
        constraints: BoxConstraints.tight(const Size(SEARCHBARWIDTH, MyTheme.appBarButtonHeight)),
        contentPadding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      ),
      style: TextStyle(fontSize: 14, fontFamily: 'NotoSans', color: theme.colors.onSurfaceVariant),
      focusNode: focusNode,
      controller: textEditController,
    );
  }
}
