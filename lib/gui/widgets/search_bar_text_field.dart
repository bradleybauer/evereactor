import 'package:flutter/material.dart';

import '../../search.dart';
import '../my_theme.dart';
import 'hover_button.dart';
import 'search_bar.dart';

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
        constraints: BoxConstraints.tight(Size(SearchBar.SEARCHBARWIDTH, MyTheme.appBarButtonHeight)),
        contentPadding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      ),
      style: TextStyle(fontSize: 14, fontFamily: 'NotoSans', color: theme.colors.onSurfaceVariant),
      focusNode: focusNode,
      controller: textEditController,
    );
  }
}
