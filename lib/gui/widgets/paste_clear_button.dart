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
                  constraints: BoxConstraints.tight(Size(150, MyTheme.appBarButtonHeight)),
                  fillColor: theme.colors.surfaceVariant,
                  filled: true,
                  labelText: Strings.pasteInventory,
                  labelStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 12, color: theme.colors.onSurfaceVariant),
                  contentPadding: const EdgeInsets.all(9),
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
                hoveredColor: theme.colors.primary)
        // OutlinedButton(
        //     style: ButtonStyle(
        //       backgroundColor: MaterialStateProperty.all(theme.colors.surfaceVariant),
        //       // border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        //     ),
        //     // onPressed: () => Provider.of<BuildAdapter>(context, listen: false).clearInventory(),
        //     onPressed: () => {},
        //     child: Text(Strings.clearInventory, style: TextStyle(fontFamily: 'NotoSans', fontSize: 12, color: theme.colors.onSurfaceVariant)))
        ;

    return ConstrainedBox(constraints: const BoxConstraints.tightForFinite(width: 148, height: 28), child: pasteOrClear);
  }
}
