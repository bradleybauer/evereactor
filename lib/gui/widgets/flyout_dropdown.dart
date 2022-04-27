import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../my_theme.dart';
import 'flyout.dart';
import 'flyout_controller.dart';
import 'hover_button.dart';

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
    this.width,
  }) : super(key: key);

  final bool up;
  final double? width;
  final double? maxHeight;
  final String current;
  final List<String> items;
  final List<dynamic> ids;
  final void Function(dynamic) onSelect;
  final TextStyle style;
  final FlyoutController parentController;

  @override
  State<DropdownMenuFlyout> createState() => _DropdownMenuFlyoutState();
}

class _DropdownMenuFlyoutState extends State<DropdownMenuFlyout> {
  final FlyoutController controller = FlyoutController(MyTheme.buttonFocusDuration, maxVotes: 1);
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
    final theme = Provider.of<MyTheme>(context);
    return Flyout(
      sideOffset: 8,
      content: (ctx) {
        return Container(
          padding: const EdgeInsets.all(4),
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
                        controller.forceClose();
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
          builder: (hovered) {
            final text = Text(widget.current,
                style: widget.style.copyWith(color: hovered ? theme.onSecondary : theme.onSurface));
            if (widget.width != null) {
              return Container(
                  padding: const EdgeInsets.all(3), width: widget.width, alignment: Alignment.center, child: text);
            }
            return Container(padding: const EdgeInsets.all(3), child: text);
          },
        ),
      ),
      openMode: FlyoutOpenMode.custom,
      align: widget.up ? FlyoutAlign.dropup : FlyoutAlign.dropdown,
      // closeTimeout: theme.buttonFocusDuration,
      controller: controller,
    );
  }
}
