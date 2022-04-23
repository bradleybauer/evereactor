import 'package:EveIndy/gui/widgets/table_text_field.dart';
import 'package:flutter/material.dart';

import '../my_theme.dart';

class OptionsFlyout extends StatelessWidget {
  OptionsFlyout({Key? key}) : super(key: key);

  static const size = Size(300, 400);
  static const padding = theme.appBarPadding;

  final headerStyle =
      TextStyle(fontFamily: 'NotoSans', fontSize: 14, fontWeight: FontWeight.w700, color: theme.onTertiaryContainer);
  final style = TextStyle(fontFamily: 'NotoSans', fontSize: 12, color: theme.onTertiaryContainer);

  Widget getSkillsColumn() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(padding, 0, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 100, maxWidth: 150),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Industry', style: style),
                Text('Science', style: style),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 100, maxWidth: 150),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Advanced Industry', style: style),
                  SizedBox(width: padding),
                  TableTextField(onChanged: (text) {}),
                ]),
                Text('Reactions', style: style),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getBlueprints() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      shadowColor: theme.shadow,
      elevation: 2,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: size.width,
        height: size.height,
        color: theme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Skills', style: headerStyle),
              getSkillsColumn(),
              const SizedBox(height: padding),
              Text('Jobs', style: headerStyle),
              getBlueprints(),
            ],
          ),
        ),
      ),
    );
  }
}
