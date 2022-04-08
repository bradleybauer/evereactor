import 'package:EveIndy/gui/widgets/hover_button.dart';
import 'package:flutter/material.dart';

import '../my_theme.dart';

// TODO the issue with ListView.builder is that it is not cacheing the items.

class SearchBarFlyoutContent extends StatelessWidget {
  static const Size CONTENTSIZE = Size(400, 500);

  const SearchBarFlyoutContent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 400, maxWidth: 400, minHeight: 60, maxHeight: 400),
      child: PhysicalModel(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
            color: theme.colors.tertiaryContainer,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PhysicalModel(
                  color: Colors.transparent,
                  elevation: 1,
                  child: Container(
                    color: theme.colors.tertiaryContainer,
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Item",
                          style: TextStyle(
                              fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.w700, color: theme.colors.onTertiaryContainer),
                        ),
                      ),
                      Expanded(child: Container()),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Profit %",
                          style: TextStyle(
                              fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.w700, color: theme.colors.onTertiaryContainer),
                        ),
                      ),
                    ]),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemExtent: 23, // vertical height of the items
                      itemCount: 200,
                      itemBuilder: (_, index) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: HoverButton(
                                builder: (hovered) {
                                  return Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Icon(Icons.add, size: 11, color: hovered ? theme.colors.onTertiary : theme.colors.onBackground));
                                },
                                borderRadius: 4,
                                hoveredElevation: 0,
                                color: theme.colors.background,
                                hoveredColor: theme.colors.tertiary,
                                splashColor: theme.colors.onTertiary.withOpacity(.5),
                                onTap: () {
                                  print('Adding $index');
                                },
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: Text(
                                'Reaction-Orienting Neurolink Stabilizer',
                                style: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.colors.onTertiaryContainer),
                              ),
                            ),
                            const SizedBox(width: MyTheme.appBarPadding),
                            Text(
                              '32%',
                              style: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.colors.onTertiaryContainer),
                            )
                          ],
                        );
                      }),
                ),
              ],
            )),
      ),
    );
  }
}
