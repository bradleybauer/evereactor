import 'package:flutter/material.dart';

import '../../search.dart';
import '../my_theme.dart';
import 'hover_button.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
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
        // show flyout
      } else {
        // hide flyout
      }
    });
    super.initState();
  }

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
        constraints: BoxConstraints.tight(const Size(275, MyTheme.appBarButtonHeight)),
        contentPadding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      ),
      style: TextStyle(fontSize: 14, fontFamily: 'NotoSans', color: theme.colors.onSurfaceVariant),
      focusNode: focusNode,
      controller: textEditController,
    );
  }
}
