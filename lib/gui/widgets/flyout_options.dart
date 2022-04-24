import 'package:EveIndy/gui/widgets/hover_button.dart';
import 'package:flutter/material.dart';

import '../../sde.dart';
import '../../strings.dart';
import '../my_theme.dart';
import 'labeled_checkbox.dart';
import 'table_text_field.dart';

class OptionsFlyout extends StatelessWidget {
  OptionsFlyout({Key? key}) : super(key: key);

  static const size = Size(510, 700);
  static const padding = theme.appBarPadding;
  static const itemPadding = 8.0;

  static Color color = theme.secondaryContainer;
  static Color base = theme.secondary;

  final headerStyle =
      TextStyle(fontFamily: 'NotoSans', fontSize: 15, fontWeight: FontWeight.w700, color: theme.on(color));
  final style = TextStyle(fontFamily: 'NotoSans', fontSize: 12, color: theme.on(color));

  Widget getSkills() {
    final skills = SDE.skills.entries.toList(growable: false)
      ..sort((a, b) => a.value.marketGroupID < b.value.marketGroupID
          ? -1
          : a.value.marketGroupID == b.value.marketGroupID
              ? 0
              : 1);
    final skillIDs = skills.map((e) => e.key).toList(growable: false);
    final numSkills = skillIDs.length;
    final cols = <List<Widget>>[[], [], [], []];
    for (int i = 0; i < 2; ++i) {
      final start = numSkills ~/ 2;
      for (int j = start * i; j < numSkills - (start * (1 - i)); ++j) {
        final tid = skillIDs[j];
        final name = SDE.skills[tid]!.nameLocalizations;
        cols[i * 2].add(
          Padding(
            padding: EdgeInsets.fromLTRB(itemPadding / 2 * i, itemPadding / 2, 10, itemPadding / 2),
            child: Text(Strings.get(name), style: style),
          ),
        );
        cols[i * 2 + 1].add(
          Padding(
            padding: const EdgeInsets.fromLTRB(0, itemPadding / 2, 6, 0),
            child: TableTextField(
              textColor: theme.on(color),
              borderColor: theme.primary,
              height: 20,
              onChanged: (t) {},
              width: 20,
              maxNumDigits: 1,
            ),
          ),
        );
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[Text('Skills', style: headerStyle)] +
              List<Widget>.generate(
                  3,
                  (i) => Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                        child: HoverButton(
                          builder: (hovered) => Container(
                              alignment: Alignment.center,
                              width: 20,
                              height: 20,
                              child: Text(
                                  i == 0
                                      ? 'III'
                                      : i == 1
                                          ? 'IV'
                                          : 'V',
                                  style: style.copyWith(color: hovered ? theme.on(base) : theme.onSurface))),
                          splashColor: theme.on(base).withOpacity(.5),
                          shadowColor: theme.shadow,
                          borderRadius: 2,
                          onTap: () => print('Setting all skills to ' + (i + 3).toString()),
                          hoveredColor: base,
                          hoveredElevation: 0,
                          color: theme.surface,
                        ),
                      )),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(theme.appBarPadding, 0, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: List<Widget>.generate(
                4, (i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: cols[i])),
          ),
        ),
      ],
    );
  }

  Widget getJobs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jobs', style: headerStyle),
        Row(
          children: [
            const SizedBox(width: padding),
            Text('Number of reaction jobs', style: style),
            const SizedBox(width: padding),
            TableTextField(
              textColor: theme.on(color),
              borderColor: theme.primary,
              onChanged: (t) {},
            ),
            const SizedBox(width: padding),
            Text('Number of manufacturing jobs', style: style),
            const SizedBox(width: padding),
            TableTextField(
              textColor: theme.on(color),
              borderColor: theme.primary,
              onChanged: (t) {},
            ),
          ],
        ),
      ],
    );
  }

  Widget getBlueprints() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Blueprints', style: headerStyle),
            const SizedBox(width: theme.appBarPadding),
            TableTextField(
              hintText: 'ME',
              textColor: theme.on(color),
              borderColor: theme.primary,
              onChanged: (t) {},
            ),
            const SizedBox(width: theme.appBarPadding),
            TableTextField(
              hintText: 'TE',
              textColor: theme.on(color),
              borderColor: theme.primary,
              onChanged: (t) {},
            ),
            const SizedBox(width: theme.appBarPadding),
            TableTextField(
              hintText: 'BPs',
              textColor: theme.on(base),
              borderColor: theme.primary,
              onChanged: (t) {},
            ),
          ],
        ),
      ],
    );
  }

  Widget getCosts() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Costs', style: headerStyle),
        const SizedBox(height: itemPadding / 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: padding),
            Text('Reaction system cost index', style: style),
            const SizedBox(width: padding),
            TableTextField(
              textColor: theme.onTertiaryContainer,
              borderColor: theme.primary,
              onChanged: (t) {},
            ),
            const SizedBox(width: padding),
            Text('Manufacturing system cost index', style: style),
            const SizedBox(width: padding),
            TableTextField(
              textColor: theme.onTertiaryContainer,
              borderColor: theme.primary,
              onChanged: (t) {},
            ),
          ],
        ),
        const SizedBox(height: itemPadding),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: padding),
            Text('Sales tax', style: style),
            const SizedBox(width: padding),
            TableTextField(
              textColor: theme.onTertiaryContainer,
              borderColor: theme.primary,
              onChanged: (t) {},
            ),
          ],
        ),
      ],
    );
  }

  Widget getStructures() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Structures', style: headerStyle),
        Text(
          '----',
          style: style,
        ),
      ],
    );
  }

  Widget getMarkets() {
    final color = theme.surface;
    final hover = theme.tertiary;
    final active = base;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text('Markets', style: headerStyle), const SizedBox(height: 4)] +
              SDE.system2name.entries
                  .map((i) => Padding(
                        padding: const EdgeInsets.fromLTRB(padding, 0, 0, 0),
                        child: LabeledCheckbox(
                          onTap: () => print('Name of system:' + i.key.toString() + ' is ' + Strings.get(i.value)),
                          getLabel: (hovered, value) => Text(Strings.get(i.value),
                              style: style.copyWith(
                                  color: value
                                      ? (hovered ? theme.on(hover) : theme.on(active))
                                      : hovered
                                          ? theme.on(hover)
                                          : theme.on(color))),
                          value: false,
                          color: color,
                          hoverColor: hover,
                          activeColor: active,
                        ),
                      ))
                  .toList(),
        )
      ],
    );
  }

  Widget getApp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('App', style: headerStyle),
        Text('Language [ v ]', style: style),
        Text('[ theme ]', style: style),
      ],
    );
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
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: FocusTraversalGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getSkills(),
                Flexible(child: Container()),
                getJobs(),
                Flexible(child: Container()),
                getBlueprints(),
                Flexible(child: Container()),
                getCosts(),
                Flexible(child: Container()),
                getStructures(),
                Flexible(child: Container()),
                getMarkets(),
                Flexible(child: Container()),
                getApp(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
