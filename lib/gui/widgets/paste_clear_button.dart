import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../my_theme.dart';
import 'hover_button.dart';
import '../../strings.dart';

class PasteClearButton extends StatefulWidget {
  const PasteClearButton({Key? key}) : super(key: key);

  @override
  State<PasteClearButton> createState() => _PasteClearButtonState();
}

class _PasteClearButtonState extends State<PasteClearButton> {
  bool paste = true;
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    Widget pasteOrClear = paste
        ? TextField(
            // onChanged: (s) => Provider.of<BuildAdapter>(context, listen: false).setInventoryFromStr(s),
            onChanged: (s) {
              setState(() => paste = false);
            },
            maxLines: null,
            decoration: InputDecoration(
              fillColor: theme.surfaceVariant,
              filled: true,
              label: Container(
                child: Text(Strings.pasteInventory, style: TextStyle(fontFamily: 'NotoSans', fontSize: 12, color: theme.onSurfaceVariant)),
                padding: const EdgeInsets.fromLTRB(3, 3, 3, 0),
                decoration: BoxDecoration(
                  color: theme.surfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              alignLabelWithHint: true,
              contentPadding: const EdgeInsets.fromLTRB(9, 0, 0, 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            ))
        : HoverButton(
            onTap: () => setState(() => paste = true),
            builder: (hovered) {
              return Center(
                child: Text(Strings.clearInventory,
                    style: TextStyle(fontFamily: 'NotoSans', fontSize: 12, color: hovered ? theme.onPrimary : theme.onSurfaceVariant)),
              );
            },
            borderColor: theme.outline,
            borderRadius: 4,
            color: theme.surfaceVariant,
            splashColor: theme.onPrimary.withOpacity(.25),
            hoveredColor: theme.primary);

    return ConstrainedBox(constraints: const BoxConstraints.tightForFinite(width: 122, height: 28), child: pasteOrClear);
  }
}
