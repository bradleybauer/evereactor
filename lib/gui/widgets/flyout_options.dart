import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../adapters/options.dart';
import '../../sde.dart';
import '../../strings.dart';
import '../my_theme.dart';
import 'flyout_controller.dart';
import 'flyout_dropdown.dart';
import 'hover_button.dart';
import 'labeled_checkbox.dart';
import 'table_text_field.dart';

class OptionsFlyout extends StatelessWidget {
  OptionsFlyout(this.controller, {Key? key}) : super(key: key);

  static const size = Size(510, 700);
  static const padding = theme.appBarPadding;
  static const itemPadding = 8.0;

  static Color color = theme.secondaryContainer;
  static Color base = theme.secondary;
  final headerStyle =
      TextStyle(fontFamily: 'NotoSans', fontSize: 15, fontWeight: FontWeight.w700, color: theme.on(color));
  final style = TextStyle(fontFamily: 'NotoSans', fontSize: 12, color: theme.on(color));

  final FlyoutController controller;

  Widget getSkills(OptionsAdapter adapter) {
    final skills = adapter.getSkills();
    final numSkills = skills.length;
    final cols = <List<Widget>>[[], [], [], []];
    for (int j = 0; j < numSkills; ++j) {
      int i = j > numSkills ~/ 2 ? 1 : 0;
      cols[i * 2].add(
        Padding(
            padding: EdgeInsets.fromLTRB(itemPadding / 2 * i, itemPadding / 2, 10, itemPadding / 2),
            child: Text(skills[j].name, style: style)),
      );
      cols[i * 2 + 1].add(
        Padding(
          padding: const EdgeInsets.fromLTRB(0, itemPadding / 2, 6, 0),
          child: TableTextField(
            initialText: skills[j].level.toString(),
            textColor: theme.on(color),
            borderColor: theme.primary,
            height: 20,
            allowEmptyString: false,
            onChanged: (t) => adapter.setSkillLevel(skills[j].tid, t == '' ? 3 : int.parse(t)),
            width: 20,
            maxNumDigits: 1,
            // overwrite: true,
          ),
        ),
      );
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
                          onTap: () => adapter.setAllSkillLevels(i + 3),
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

  Widget getJobs(OptionsAdapter adapter) {
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
              initialText: adapter.getReactionSlots().toString(),
              textColor: theme.on(color),
              borderColor: theme.primary,
              maxNumDigits: 4,
              onChanged: (t) => adapter.setReactionSlots(t == '' ? 60 : int.parse(t)),
            ),
            const SizedBox(width: padding),
            Text('Number of manufacturing jobs', style: style),
            const SizedBox(width: padding),
            TableTextField(
              initialText: adapter.getManufacturingSlots().toString(),
              textColor: theme.on(color),
              borderColor: theme.primary,
              maxNumDigits: 4,
              onChanged: (t) => adapter.setManufacturingSlots(t == '' ? 60 : int.parse(t)),
            ),
          ],
        ),
      ],
    );
  }

  Widget getBlueprints(OptionsAdapter adapter) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Blueprints', style: headerStyle),
            const SizedBox(width: theme.appBarPadding),
            Text('ME', style: style),
            const SizedBox(width: itemPadding),
            TableTextField(
              initialText: adapter.getME().toString(),
              textColor: theme.on(color),
              borderColor: theme.primary,
              maxNumDigits: 2,
              width: 25,
              onChanged: (t) => adapter.setME(t == '' ? 0 : int.parse(t)),
            ),
            const SizedBox(width: theme.appBarPadding),
            Text('TE', style: style),
            const SizedBox(width: itemPadding),
            TableTextField(
              initialText: adapter.getTE().toString(),
              textColor: theme.on(color),
              borderColor: theme.primary,
              maxNumDigits: 2,
              width: 25,
              onChanged: (t) => adapter.setTE(t == '' ? 0 : int.parse(t)),
            ),
            const SizedBox(width: theme.appBarPadding),
            Text('Max number of blueprints', style: style),
            const SizedBox(width: itemPadding),
            TableTextField(
              initialText: adapter.getMaxNumBlueprints().toString(),
              textColor: theme.on(color),
              borderColor: theme.primary,
              maxNumDigits: 3,
              width: 30,
              onChanged: (t) => adapter.setMaxNumBlueprints(t == '' ? 20 : int.parse(t)),
            ),
          ],
        ),
      ],
    );
  }

  Widget getCosts(OptionsAdapter adapter) {
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
              initialText: adapter.getReactionSystemCostIndex().toString(),
              textColor: theme.onTertiaryContainer,
              borderColor: theme.primary,
              floatingPoint: true,
              maxNumDigits: 4,
              width: 32,
              onChanged: (t) => adapter.setReactionSystemCostIndex(t == '' ? .1 : double.parse(t)),
            ),
            const SizedBox(width: padding),
            Text('Manufacturing system cost index', style: style),
            const SizedBox(width: padding),
            TableTextField(
              initialText: adapter.getManufacturingSystemCostIndex().toString(),
              textColor: theme.onTertiaryContainer,
              borderColor: theme.primary,
              floatingPoint: true,
              maxNumDigits: 4,
              width: 32,
              onChanged: (t) => adapter.setManufacturingSystemCostIndex(t == '' ? .1 : double.parse(t)),
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
              initialText: adapter.getSalesTax().toString(),
              textColor: theme.onTertiaryContainer,
              borderColor: theme.primary,
              floatingPoint: true,
              maxNumDigits: 4,
              width: 32,
              onChanged: (t) => adapter.setSalesTax(t == '' ? 0 : double.parse(t)),
            ),
          ],
        ),
      ],
    );
  }

  Widget getStructures(OptionsAdapter adapter) {
    List<Widget> addManufacturingRigButton = [];
    List<Widget> addReactionRigButton = [];
    if (adapter.getNumSelectedManufacturingRigs() < 6) {
      addManufacturingRigButton = [
        Padding(
            padding: const EdgeInsets.fromLTRB(itemPadding, 0, 0, 0),
            child: DropdownMenuFlyout(
              current: 'Rigs',
              items: adapter.getManufacturingRigs().map((e) => e.name).toList(),
              style: style,
              parentController: controller,
              ids: adapter.getManufacturingRigs().map((e) => e.tid).toList(),
              onSelect: (tid) => adapter.addManufacturingRig(tid),
              up: true,
              maxHeight: 300,
            )),
      ];
    }
    if (adapter.getNumSelectedReactionRigs() < 6) {
      addReactionRigButton = [
        Padding(
            padding: const EdgeInsets.fromLTRB(itemPadding, 0, 0, 0),
            child: DropdownMenuFlyout(
              current: 'Rigs',
              items: adapter.getReactionRigs().map((e) => e.name).toList(),
              style: style,
              parentController: controller,
              ids: adapter.getReactionRigs().map((e) => e.tid).toList(),
              onSelect: (tid) => adapter.addReactionRig(tid),
              up: true,
              maxHeight: 350,
            )),
      ];
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Structures', style: headerStyle),
        const SizedBox(height: itemPadding),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
                const SizedBox(width: padding),
                DropdownMenuFlyout(
                  current: adapter.getManufacturingStructure().name,
                  items: adapter.getManufacturingStructures().map((e) => e.name).toList(),
                  ids: adapter.getManufacturingStructures().map((e) => e.tid).toList(),
                  width: 55,
                  style: style,
                  parentController: controller,
                  onSelect: (x) => adapter.setManufacturingStructure(x),
                ),
              ] +
              List<Widget>.generate(
                adapter.getSelectedManufacturingRigs().length,
                (i) => Padding(
                  padding: const EdgeInsets.fromLTRB(itemPadding, 0, 0, 0),
                  child: Tooltip(
                    preferBelow: false,
                    verticalOffset: 17,
                    message: adapter.getSelectedManufacturingRigs()[i].name,
                    child: HoverButton(
                      color: theme.surface,
                      hoveredColor: theme.secondary,
                      onTap: () => adapter.removeManufacturingRig(i),
                      hoveredElevation: 0,
                      borderRadius: 4,
                      builder: (hovered) {
                        return Container(
                            padding: const EdgeInsets.all(3),
                            child: Icon(Icons.close, size: 16, color: hovered ? theme.onSecondary : theme.onSurface));
                      },
                    ),
                  ),
                ),
              ) +
              addManufacturingRigButton,
        ),
        const SizedBox(height: itemPadding),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
                const SizedBox(width: padding),
                DropdownMenuFlyout(
                  current: adapter.getReactionStructure().name,
                  items: adapter.getReactionStructures().map((e) => e.name).toList(),
                  ids: adapter.getReactionStructures().map((e) => e.tid).toList(),
                  width: 55,
                  style: style,
                  parentController: controller,
                  onSelect: (x) => adapter.setReactionStructure(x),
                ),
              ] +
              List<Widget>.generate(
                adapter.getSelectedReactionRigs().length,
                (i) => Padding(
                  padding: const EdgeInsets.fromLTRB(itemPadding, 0, 0, 0),
                  child: Tooltip(
                    preferBelow: false,
                    verticalOffset: 17,
                    message: adapter.getSelectedReactionRigs()[i].name,
                    child: HoverButton(
                      color: theme.surface,
                      hoveredColor: theme.secondary,
                      onTap: () => adapter.removeReactionRig(i),
                      hoveredElevation: 0,
                      borderRadius: 4,
                      builder: (hovered) {
                        return Container(
                            padding: const EdgeInsets.all(3),
                            child: Icon(Icons.close, size: 16, color: hovered ? theme.onSecondary : theme.onSurface));
                      },
                    ),
                  ),
                ),
              ) +
              addReactionRigButton,
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

  Widget getApp(OptionsAdapter adapter, BuildContext context) {
    return Row(
      children: [
        Text('App', style: headerStyle),
        const SizedBox(width: padding),
        Text('Language',style: style),
        const SizedBox(width: itemPadding),
        DropdownMenuFlyout(
            items: adapter.getLangs().map((e) => e.name).toList(),
            style: style,
            parentController: controller,
            ids: adapter.getLangs().map((e) => e.label).toList(),
            onSelect: (lang) => Provider.of<Strings>(context,listen: false).setLang(lang),
            current: adapter.getLangName())
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final adapter = Provider.of<OptionsAdapter>(context);
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
                getSkills(adapter),
                Flexible(child: Container()),
                getJobs(adapter),
                Flexible(child: Container()),
                getBlueprints(adapter),
                Flexible(child: Container()),
                getStructures(adapter),
                Flexible(child: Container()),
                getCosts(adapter),
                Flexible(child: Container()),
                getMarkets(),
                Flexible(child: Container()),
                getApp(adapter,context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
