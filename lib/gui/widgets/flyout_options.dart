import 'package:EveIndy/gui/widgets/flyout.dart';
import 'package:circular_color_picker/circular_color_picker.dart';
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

const size = Size(510, 700);
const padding = MyTheme.appBarPadding;
const itemPadding = 8.0;

class OptionsFlyout extends StatelessWidget {
  OptionsFlyout(this.controller, this.color, this.base, this.headerStyle, this.style, {Key? key}) : super(key: key);

  final Color color;
  final Color base;

  final TextStyle headerStyle;
  final TextStyle style;

  final FlyoutController controller;

  @override
  Widget build(BuildContext context) {
    final adapter = Provider.of<OptionsAdapter>(context);
    final theme = Provider.of<MyTheme>(context);
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
                SkillSection(
                    style: style,
                    color: color,
                    headerStyle: headerStyle,
                    base: base,
                    adapter: adapter),
                Flexible(child: Container()),
                JobsSection(headerStyle: headerStyle, style: style, color: color, adapter: adapter),
                Flexible(child: Container()),
                BlueprintsSection(
                    headerStyle: headerStyle, style: style, color: color, adapter: adapter),
                Flexible(child: Container()),
                StructuresSection(
                    style: style,
                    controller: controller,
                    headerStyle: headerStyle,
                    adapter: adapter),
                Flexible(child: Container()),
                CostsSection(
                    headerStyle: headerStyle,
                    style: style,
                    adapter: adapter),
                Flexible(child: Container()),
                MarketsSection(base: base, headerStyle: headerStyle, style: style),
                Flexible(child: Container()),
                AppSection(
                    headerStyle: headerStyle,
                    style: style,
                    controller: controller,
                    color: color,
                    adapter: adapter,
                    context: context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppSection extends StatelessWidget {
  const AppSection({
    Key? key,
    required this.headerStyle,
    required this.style,
    required this.controller,
    required this.color,
    required this.adapter,
    required this.context,
  }) : super(key: key);

  final TextStyle headerStyle;
  final TextStyle style;
  final FlyoutController controller;
  final Color color;
  final OptionsAdapter adapter;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return Row(
      children: [
        Text('App', style: headerStyle),
        const SizedBox(width: padding),
        Text('Language', style: style),
        const SizedBox(width: itemPadding),
        DropdownMenuFlyout(
          items: adapter.getLangs().map((e) => e.name).toList(),
          style: style,
          parentController: controller,
          ids: adapter.getLangs().map((e) => e.label).toList(),
          onSelect: (lang) => Provider.of<Strings>(context, listen: false).setLang(lang),
          current: adapter.getLangName(),
          up: true,
        ),
        const SizedBox(width: itemPadding),
        HoverButton(
            builder: (b) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('1', style: style.copyWith(color: !b ? theme.on(color) : Colors.black)),
                ),
            onTap: () {},
            color: Colors.transparent,
            hoveredColor: Colors.blue),
        const SizedBox(width: itemPadding),
        HoverButton(
            builder: (b) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('2', style: style.copyWith(color: !b ? theme.on(color) : Colors.black)),
                ),
            onTap: () {},
            color: Colors.transparent,
            hoveredColor: Colors.blue),
        const SizedBox(width: itemPadding),
        HoverButton(
            builder: (b) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('3', style: style.copyWith(color: !b ? theme.on(color) : Colors.black)),
                ),
            onTap: () => theme.setColor(Colors.red),
            color: Colors.transparent,
            hoveredColor: Colors.blue),
        ASDF(controller),
      ],
    );
  }
}

class MarketsSection extends StatelessWidget {
  const MarketsSection({
    Key? key,
    required this.base,
    required this.headerStyle,
    required this.style,
  }) : super(key: key);

  final Color base;
  final TextStyle headerStyle;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
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
}

class StructuresSection extends StatelessWidget {
  const StructuresSection({
    Key? key,
    required this.style,
    required this.controller,
    required this.headerStyle,
    required this.adapter,
  }) : super(key: key);

  final TextStyle style;
  final FlyoutController controller;
  final TextStyle headerStyle;
  final OptionsAdapter adapter;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
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
}

class CostsSection extends StatelessWidget {
  const CostsSection({
    Key? key,
    required this.headerStyle,
    required this.style,
    required this.adapter,
  }) : super(key: key);

  final TextStyle headerStyle;
  final TextStyle style;
  final OptionsAdapter adapter;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
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
}

class BlueprintsSection extends StatelessWidget {
  const BlueprintsSection({
    Key? key,
    required this.headerStyle,
    required this.style,
    required this.color,
    required this.adapter,
  }) : super(key: key);

  final TextStyle headerStyle;
  final TextStyle style;
  final Color color;
  final OptionsAdapter adapter;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Blueprints', style: headerStyle),
            const SizedBox(width: MyTheme.appBarPadding),
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
            const SizedBox(width: MyTheme.appBarPadding),
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
            const SizedBox(width: MyTheme.appBarPadding),
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
}

class JobsSection extends StatelessWidget {
  const JobsSection({
    Key? key,
    required this.headerStyle,
    required this.style,
    required this.color,
    required this.adapter,
  }) : super(key: key);

  final TextStyle headerStyle;
  final TextStyle style;
  final Color color;
  final OptionsAdapter adapter;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
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
}

class SkillSection extends StatelessWidget {
  const SkillSection({
    Key? key,
    required this.style,
    required this.color,
    required this.headerStyle,
    required this.base,
    required this.adapter,
  }) : super(key: key);

  final TextStyle style;
  final Color color;
  final TextStyle headerStyle;
  final Color base;
  final OptionsAdapter adapter;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final skills = adapter.getSkills();
    final numSkills = skills.length;
    final cols = <List<Widget>>[[], [], [], []];
    for (int j = 0; j < numSkills; ++j) {
      int i = j > numSkills ~/ 2 ? 1 : 0;
      cols[i * 2].add(
        Container(
          alignment: Alignment.center,
          height: 26,
          child: Padding(
              padding: EdgeInsets.fromLTRB(itemPadding / 2 * i, itemPadding / 2, 10, itemPadding / 2),
              child: Text(skills[j].name, style: style)),
        ),
      );
      cols[i * 2 + 1].add(
        Container(
          alignment: Alignment.center,
          height: 26,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, itemPadding / 3, 6, itemPadding / 3),
            child: TableTextField(
              initialText: skills[j].level.toString(),
              textColor: theme.on(color),
              borderColor: theme.primary,
              allowEmptyString: false,
              onChanged: (t) => adapter.setSkillLevel(skills[j].tid, t == '' ? 3 : int.parse(t)),
              width: 20,
              maxNumDigits: 1,
              // overwrite: true,
            ),
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
          padding: const EdgeInsets.fromLTRB(MyTheme.appBarPadding, 0, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(
                4, (i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: cols[i])),
          ),
        ),
      ],
    );
  }
}

class ASDF extends StatefulWidget {
  ASDF(this.controller, {Key? key}) : super(key: key);
  FlyoutController controller;

  @override
  State<ASDF> createState() => _ASDFState();
}

class _ASDFState extends State<ASDF> {
  final FlyoutController controller = FlyoutController(theme.buttonFocusDuration, maxVotes: 1);

  @override
  void initState() {
    widget.controller.connect(controller);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.disconnect(controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flyout(
        content: (ctx) => ASD((c) => Provider.of<MyTheme>(ctx,listen: false).setColor(c)),
        child: Container(width: 10, height: 10, color: Colors.black),
        openMode: FlyoutOpenMode.hover,
        align: FlyoutAlign.dropup,
        controller: controller);
  }
}

class ASD extends StatefulWidget {
  const ASD(this.onChange, {Key? key}) : super(key: key);

  final Function onChange;

  @override
  State<ASD> createState() => _ASDState();
}

class _ASDState extends State<ASD> {
  Color color = Colors.black;

  @override
  Widget build(BuildContext context) {
    return CircularColorPicker(
      onColorChange: (value) {
        setState(() {
          color = value;
          widget.onChange(value);
        });
      },
    );
  }
}
