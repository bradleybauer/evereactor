import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../adapters/options.dart';
import '../../models/industry_type.dart';
import '../../sde.dart';
import '../../strings.dart';
import '../my_theme.dart';
import 'flyout.dart';
import 'flyout_controller.dart';
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
      int i = j >= numSkills ~/ 2 ? 1 : 0;
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
            onChanged: (t) {
              if (t == '') {
                t = '3';
              }
              adapter.setSkillLevel(skills[j].tid, int.parse(t));
            },
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
              onChanged: (t) {
                if (t == '') {
                  t = '60';
                }
                adapter.setReactionSlots(int.parse(t));
              },
            ),
            const SizedBox(width: padding),
            Text('Number of manufacturing jobs', style: style),
            const SizedBox(width: padding),
            TableTextField(
              initialText: adapter.getManufacturingSlots().toString(),
              textColor: theme.on(color),
              borderColor: theme.primary,
              maxNumDigits: 4,
              onChanged: (t) {
                if (t == '') {
                  t = '60';
                }
                adapter.setManufacturingSlots(int.parse(t));
              },
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
              onChanged: (t) {
                if (t == '') t = '0';
                adapter.setME(int.parse(t));
              },
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
              onChanged: (t) {
                if (t == '') t = '0';
                adapter.setTE(int.parse(t));
              },
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
              onChanged: (t) {
                if (t == '') t = '20';
                adapter.setMaxNumBlueprints(int.parse(t));
              },
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

  Widget getStructures() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Structures', style: headerStyle),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: padding),
            Text('Manufacturing structure', style: style),
            const SizedBox(width: padding),
            DropdownMenuFlyout(
              current: Strings.get(SDE.structures.entries.first.value.nameLocalizations),
              items: SDE.structures.entries
                  .where((e) => e.value.industryType == IndustryType.MANUFACTURING)
                  .map((e) => Strings.get(e.value.nameLocalizations))
                  .toList(),
              ids: SDE.structures.entries
                  .where((e) => e.value.industryType == IndustryType.MANUFACTURING)
                  .map((e) => e.key)
                  .toList(),
              style: style,
              parentController: controller,
              onSelect: (x) => print('selected ' + Strings.get(SDE.structures[x]!.nameLocalizations)),
            ),
            const SizedBox(width: padding),
            Text('Reaction structure', style: style),
            const SizedBox(width: padding),
            DropdownMenuFlyout(
              current: Strings.get(SDE.structures.entries.first.value.nameLocalizations),
              items: SDE.structures.entries
                  .where((e) => e.value.industryType == IndustryType.REACTION)
                  .map((e) => Strings.get(e.value.nameLocalizations))
                  .toList(),
              ids: SDE.structures.entries
                  .where((e) => e.value.industryType == IndustryType.REACTION)
                  .map((e) => e.key)
                  .toList(),
              style: style,
              parentController: controller,
              onSelect: (x) => print('selected ' + Strings.get(SDE.structures[x]!.nameLocalizations)),
            ),
          ],
        ),
        Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: padding),
          Text('Manufacturing rigs', style: style),
        ]),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: padding),
            DropdownMenuFlyout(
              current: Strings.get(SDE.rigs.entries.first.value.nameLocalizations).replaceAll('Standup ', ''),
              items: SDE.rigs.entries
                  .where((e) => e.value.industryType == IndustryType.MANUFACTURING)
                  .map((e) => Strings.get(e.value.nameLocalizations).replaceAll('Standup ', ''))
                  .toList()
                ..sort((a, b) => a.compareTo(b)),
              ids: SDE.rigs.entries
                  .where((e) => e.value.industryType == IndustryType.MANUFACTURING)
                  .map((e) => e.key)
                  .toList(),
              style: style,
              parentController: controller,
              onSelect: (x) => print('selected ' + Strings.get(SDE.structures[x]!.nameLocalizations)),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: padding),
            DropdownMenuFlyout(
              up: true,
              maxHeight: 300,
              current: Strings.get(SDE.rigs.entries.first.value.nameLocalizations).replaceAll('Standup ', ''),
              items: SDE.rigs.entries
                  .where((e) => e.value.industryType == IndustryType.MANUFACTURING)
                  .map((e) => Strings.get(e.value.nameLocalizations).replaceAll('Standup ', ''))
                  .toList()
                ..sort((a, b) => a.compareTo(b)),
              ids: SDE.rigs.entries
                  .where((e) => e.value.industryType == IndustryType.MANUFACTURING)
                  .map((e) => e.key)
                  .toList(),
              style: style,
              parentController: controller,
              onSelect: (x) => print('selected ' + Strings.get(SDE.structures[x]!.nameLocalizations)),
            ),
          ],
        )
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
                getStructures(),
                Flexible(child: Container()),
                getCosts(adapter),
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

class DropdownMenuFlyout extends StatefulWidget {
  const DropdownMenuFlyout({
    Key? key,
    required this.items,
    required this.style,
    required this.parentController,
    required this.ids,
    required this.onSelect,
    required this.current,
    this.up = false,
    this.maxHeight,
  }) : super(key: key);

  final bool up;
  final double? maxHeight;
  final String current;
  final List<String> items;
  final List<int> ids;
  final void Function(int) onSelect;
  final TextStyle style;
  final FlyoutController parentController;

  @override
  State<DropdownMenuFlyout> createState() => _DropdownMenuFlyoutState();
}

class _DropdownMenuFlyoutState extends State<DropdownMenuFlyout> {
  final FlyoutController controller = FlyoutController(theme.buttonFocusDuration, maxVotes: 1);
  final _scrollController = ScrollController();

  @override
  void initState() {
    widget.parentController.connect(controller);
    super.initState();
  }

  @override
  void dispose() {
    widget.parentController.disconnect(controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flyout(
      sideOffset: 4,
      content: () {
        return Container(
          padding: const EdgeInsets.all(8),
          constraints: widget.maxHeight != null ? BoxConstraints(maxHeight: widget.maxHeight!) : null,
          decoration: BoxDecoration(
            border: Border.all(color: theme.outline),
            borderRadius: BorderRadius.circular(4),
            color: theme.surface,
          ),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List<Widget>.generate(
                  widget.items.length,
                  (i) => HoverButton(
                      builder: (hovered) => Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            widget.items[i],
                            style: widget.style.copyWith(color: hovered ? theme.onSecondary : theme.onSurface),
                          )),
                      borderRadius: 3,
                      onTap: () {
                        controller.startCloseTimer();
                        widget.onSelect(widget.ids[i]);
                      },
                      splashColor: theme.onPrimary.withOpacity(.5),
                      hoveredElevation: 0,
                      color: Colors.transparent,
                      hoveredColor: theme.secondary),
                ),
              ),
            ),
          ),
        );
      },
      child: MouseRegion(
        cursor: MouseCursor.defer,
        onExit: (_) {
          controller.startCloseTimer();
        },
        child: HoverButton(
          color: theme.surface,
          hoveredColor: theme.secondary,
          onTap: () => controller.open(),
          hoveredElevation: 0,
          borderRadius: 4,
          builder: (hovered) => Container(
            padding: const EdgeInsets.all(3),
            child: Text(widget.current,
                style: widget.style.copyWith(color: hovered ? theme.onSecondary : theme.onSurface)),
          ),
        ),
      ),
      openMode: FlyoutOpenMode.custom,
      align: widget.up ? FlyoutAlign.dropup : FlyoutAlign.dropdown,
      // closeTimeout: theme.buttonFocusDuration,
      controller: controller,
    );
  }
}
