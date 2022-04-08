// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:EveIndy/gui/widgets/hover_button.dart';
import 'package:flutter/material.dart';

import '../my_theme.dart';

class SearchBarFlyoutContent extends StatelessWidget {
  static const Size CONTENTSIZE = Size(400, 500);

  const SearchBarFlyoutContent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 400, maxWidth: 400, minHeight: 75, maxHeight: 400),
      child: PhysicalModel(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          color: theme.colors.tertiaryContainer,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
              child: DataTable(
                dataTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.colors.onBackground),
                headingTextStyle:
                    TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.w700, color: theme.colors.onBackground),
                showCheckboxColumn: false,
                dividerThickness: .000001,
                dataRowHeight: 24,
                columnSpacing: 8,
                horizontalMargin: 8,
                headingRowHeight: 38,

                ///(add, icon, name, profit %)
                columns: [
                  DataColumn(label: Row(children: [SizedBox(width: 32), Text('Item')]), onSort: (i, b) {}),
                  DataColumn(label: const Text('Profit %'), onSort: (i, b) {}),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Row(
                      children: [
                        HoverButton(
                          builder: (hovered) {
                            return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(Icons.add, size: 11, color: hovered ? theme.colors.onTertiary : theme.colors.onBackground));
                          },
                          borderRadius: 4,
                          hoveredElevation: 0,
                          color: theme.colors.background,
                          hoveredColor: theme.colors.tertiary,
                          splashColor: theme.colors.onTertiary.withOpacity(.5),
                          onTap: () {},
                        ),
                        SizedBox(width: MyTheme.appBarPadding),
                        Text(
                          'Reaction-Orienting Neurolink Stabilizer',
                          style: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.colors.onTertiaryContainer),
                        ),
                      ],
                    )),
                    DataCell(Text('32%')),
                  ]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                  DataRow(cells: [DataCell(Text('11')), DataCell(Text('hai'))]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
