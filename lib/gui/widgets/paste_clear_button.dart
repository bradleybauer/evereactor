import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'hover_button.dart';
import '../../strings.dart';

class PasteClearButton extends StatefulWidget {
  const PasteClearButton({Key? key}) : super(key: key);

  @override
  State<PasteClearButton> createState() => _PasteClearButtonState();
}

class _PasteClearButtonState extends State<PasteClearButton> {
  bool hi = true;
  @override
  Widget build(BuildContext context) {
    Widget pasteOrClear = hi
        ? TextField(
            // onChanged: (s) => Provider.of<BuildAdapter>(context, listen: false).setInventoryFromStr(s),
            onChanged: (s) {
              setState(() => hi = false);
            },
            maxLines: null,
            decoration: InputDecoration(
              fillColor: theme.colors.surfaceVariant,
              filled: true,
              labelText: Strings.pasteInventory,
              labelStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 12, color: theme.colors.onSurfaceVariant),
              alignLabelWithHint: true,
              contentPadding: const EdgeInsets.fromLTRB(9, 0, 0, 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            ))
        : HoverButton(
            onTap: () => setState(() => hi = true),
            builder: (hovered) {
              return Center(
                child: Text(Strings.clearInventory,
                    style: TextStyle(
                        fontFamily: 'NotoSans', fontSize: 12, color: hovered ? theme.colors.onPrimary : theme.colors.onSurfaceVariant)),
              );
            },
            borderColor: theme.colors.outline,
            borderRadius: 4,
            color: theme.colors.surfaceVariant,
            splashColor: theme.colors.onPrimary.withOpacity(.25),
            hoveredColor: theme.colors.primary);

    return ConstrainedBox(constraints: const BoxConstraints.tightForFinite(width: 122, height: 28), child: pasteOrClear);
  }
}
