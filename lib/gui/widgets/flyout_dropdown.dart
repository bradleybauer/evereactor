import 'package:flutter/material.dart';

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
