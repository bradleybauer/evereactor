import 'package:EveIndy/gui/adapters.dart';
import 'package:EveIndy/model/build_tree.dart';
import 'package:EveIndy/model/context.dart';
import 'package:EveIndy/model/inventory.dart';
import 'package:EveIndy/model/market.dart';
import '../model/eve_static_data.dart';
import '../model/util.dart';
import 'form_fields.dart';
import 'data_table.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RowHighlightNotifier extends ChangeNotifier {
  int currentRowId = -1;
  void set(int id) {
    currentRowId = id;
    notifyListeners();
  }
}

@immutable
class ReactionTable extends StatefulWidget {
  const ReactionTable(
      {required this.data,
      required this.getColumns,
      required this.getRows,
      this.shouldFixHeight = true,
      Key? key,
      this.columnMinWidths,
      this.noStartPadding,
      this.haveMaxHeightIfNotFixed = false})
      : super(key: key);

  final List<Map<String, num>> data;
  final List<DataRow2> Function(GlobalKey<FormState>) getRows;
  final List<DataColumn> Function(void Function(int, bool) Function(String k)) getColumns;
  final List<double>? columnMinWidths;
  final bool? noStartPadding;
  final bool shouldFixHeight;
  final bool haveMaxHeightIfNotFixed;

  @override
  _ReactionTableState createState() => _ReactionTableState();

  static getHoverCallback(int id, BuildContext context) {
    return (hovered) {
      if (hovered) {
        Provider.of<RowHighlightNotifier>(context, listen: false).set(id);
      } else {
        Provider.of<RowHighlightNotifier>(context, listen: false).set(-1);
      }
    };
  }

  static Color getHoverColor(int id, int hoveredId) {
    return (id == hoveredId
        ? Colors.amber[50]
        : EveStaticData.isAncestor(id, hoveredId)
            ? Colors.purple[50]
            : EveStaticData.isDescendant(id, hoveredId)
                ? Colors.blue[50]
                : Colors.white)!;
  }
}

class _ReactionTableState extends State<ReactionTable> {
  final _formKey = GlobalKey<FormState>();

  int? _currentSortColumn;
  String? _currentSortColumnName;
  bool _sortIsAscending = true;

  List<int> perm = [];

  @override
  void initState() {
    for (int i = 0; i < widget.data.length; i++) {
      perm.add(widget.data[i]['id'] as int);
    }
    super.initState();
  }

  void Function(int, bool) _getSortFunc(String k) => (int columnIndex, bool ascending) {
        setState(() {
          _currentSortColumnName = k;
          _currentSortColumn = columnIndex;
          _sortIsAscending = ascending;
          widget.data.sort((a, b) {
            if (!ascending) {
              var tmp = a;
              a = b;
              b = tmp;
            }
            if (k == 'Name') {
              return EveStaticData.getName(b['id'] as int).compareTo(EveStaticData.getName(a['id'] as int));
            }
            return b[k]!.compareTo(a[k]!);
          });
          for (int i = 0; i < widget.data.length; i++) {
            perm[i] = widget.data[i]['id'] as int;
          }
        });
      };

  @override
  void didUpdateWidget(covariant ReactionTable oldWidget) {
    // When items have the same position in the order given the current sort column,
    // then they will not be rearranged by sorting that column when the widget is rebuilt.
    // This means if the items have some permutation P given by sorting by some column
    // other than column C, then when they are sorted by column C and the widget is rebuilt
    // they will be put into the default order as set by the data model (alphabetical). This
    // happens because in the order defined by column C, any permutation of the items has
    // the same order (all equal). I know this is not very clear. But good luck future Bradley.
    if (_currentSortColumn != null) {
      String k = _currentSortColumnName!;
      widget.data.sort((a, b) {
        int compare;
        if (!_sortIsAscending) {
          var temp = a;
          a = b;
          b = temp;
        }
        if (k == 'Name') {
          compare = EveStaticData.getName(b['id'] as int).compareTo(EveStaticData.getName(a['id'] as int));
        } else {
          compare = b[k]!.compareTo(a[k]!);
        }
        if (compare == 0) {
          compare = perm.indexOf(a['id'] as int).compareTo(perm.indexOf(b['id'] as int));
        }
        return compare;
      });
    }
    perm.clear();
    for (int i = 0; i < widget.data.length; i++) {
      perm.add(widget.data[i]['id'] as int);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Widget ret = SingleChildScrollView(
      child: Material(
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: DataTable2(
            // headingRowColor: MaterialStateProperty.resolveWith((states) {
            //   if (states.contains(MaterialState.hovered) || states.contains(MaterialState.focused)) {
            //     return Colors.red;
            //   }
            //   return Colors.grey[50];
            // }),
            headingRowHeight: 38,
            columnSpacing: 8,
            noStartPadding: widget.noStartPadding,
            sortAscending: _sortIsAscending,
            sortColumnIndex: _currentSortColumn,
            dataRowHeight: 32,
            showCheckboxColumn: false,
            columns: widget.getColumns(_getSortFunc),
            rows: widget.getRows(_formKey),
            columnMinWidths: widget.columnMinWidths,
          ),
        ),
      ),
    );
    if (widget.shouldFixHeight) {
      ret = SizedBox(height: 280, child: ret);
    } else if (widget.haveMaxHeightIfNotFixed) {
      ret = ConstrainedBox(constraints: BoxConstraints.loose(Size(double.infinity, 280)), child: ret);
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300] as Color, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ret,
        // clipBehavior: Clip.antiAlias,
      ),
    );
  }
}

class AdvancedMaterialsTable extends StatelessWidget {
  final BuildAdapter buildAdapter;
  final List<Map<String, num>> data;

  const AdvancedMaterialsTable({Key? key, required this.buildAdapter, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    const negativeIskColor = Colors.red;
    const positiveIskColor = Colors.green;
    return ReactionTable(
      shouldFixHeight: false,
      noStartPadding: true,
      data: data,
      getColumns: (getSortFunc) => [
        DataColumn(
            label: const Center(child: Text('Advanced', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            onSort: getSortFunc('Name')),
        ...List<DataColumn>.generate(
            BuildAdapter.AdvancedMaterialsDisplayColumns.length,
            (i) => DataColumn(
                numeric: true,
                label: Text(BuildAdapter.AdvancedMaterialsDisplayColumns[i]),
                onSort: getSortFunc(BuildAdapter.AdvancedMaterialsDisplayColumns[i]))),
      ],
      getRows: (_formKey) => List<DataRow2>.generate(data.length, (i) {
        final id = data[i]['id'] as int;
        final profit = data[i]['Profit']!;
        final profitRatio = data[i]['Profit %'] as double;
        var iskColor = profit >= 0 ? positiveIskColor : negativeIskColor;

        // TODO setting #runs smaller than num built children causes issues with line allocator
        // assert(false);

        var cells = <Widget>[
          Row(
            children: [
              Focus(
                  canRequestFocus: false,
                  descendantsAreFocusable: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                    child: IconButton(
                        onPressed: () {
                          buildAdapter.removeTree(id);
                        },
                        icon: const Icon(Icons.close),
                        color: Colors.grey[700],
                        iconSize: 14,
                        splashRadius: 14),
                  )),
              Text(EveStaticData.getName(id)),
            ],
          ),
          TableIntegerInputFormField(
            formKey: _formKey,
            initialValue: data[i]['Runs'].toString(),
            maxNumDigits: 4,
            validator: (String? s) {
              if (s == null || s.isEmpty || int.parse(s) < 1) {
                return '';
              }
              var newVal = int.parse(s);
              if (newVal == data[i]['Runs']) return null;
              buildAdapter.setNumRuns(id, newVal);
            },
          ),
          TableIntegerInputFormField(
            formKey: _formKey,
            initialValue: data[i]['Lines'].toString(),
            maxNumDigits: 3,
            validator: (String? s) {
              if (s == null || s.isEmpty || int.parse(s) < 1) {
                return '';
              }
              var newVal = int.parse(s);
              if (newVal == data[i]['Lines']) return null;
              buildAdapter.setNumLines(id, newVal);
            },
          ),
          Text(currencyFormatNumber(profit), style: TextStyle(color: iskColor)),
          Text(currencyFormatNumber(data[i]['Cost']!)),
          Text(percentFormat(profitRatio), style: TextStyle(color: iskColor)),
          Text(currencyFormatNumber(data[i]['PPU']!, roundBigIskToMillions: false)),
          Text(currencyFormatNumber(data[i]['Sale PPU']!, roundBigIskToMillions: false)),
          Text(prettyPrintSecondsToDH(data[i]['Time']!)),
          Text(volumeNumberFormat(data[i]['Out m3']!)),
        ];
        return DataRow2(
            getColor: (ctx) {
              // Computing color here uses the BuildContext of the ReactionTable
              // which causes a rebuild of AdvancedMaterialsTable when onHover
              // is called. This causes getRows() to be called again which is slow.
              // Instead I use the BuildContext of DataTable2 which is cheap.
              int hoveredId = Provider.of<RowHighlightNotifier>(ctx).currentRowId;
              Color color = ReactionTable.getHoverColor(id, hoveredId);
              return color;
            },
            onHover: ReactionTable.getHoverCallback(id, context),
            key: ValueKey(data[i]['id'].toString()),
            cells: cells.map((c) => DataCell(c)).toList());
      }),
      columnMinWidths: const [183, 70, 50, 60, 75, 69, 50, 50, 60, 50],
    );
  }
}

class ProcessedMaterialTable extends StatelessWidget {
  final BuildAdapter buildAdapter;
  final List<Map<String, num>> data;

  const ProcessedMaterialTable({Key? key, required this.buildAdapter, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReactionTable(
      data: data,
      getColumns: (getSortFunc) => [
        DataColumn(label: const Center(child: Text('Processed', style: TextStyle(fontWeight: FontWeight.bold))), onSort: getSortFunc('Name')),
        DataColumn(
            numeric: true,
            // label: Tooltip(message: 'Tool Tip', child: Text(BuildAdapter.ProcessedMaterialsDisplayColumns[0])),
            label: Tooltip(message: 'Difference in profit', child: Text(BuildAdapter.ProcessedMaterialsDisplayColumns[0])),
            onSort: getSortFunc(BuildAdapter.ProcessedMaterialsDisplayColumns[0])),
        const DataColumn(label: SizedBox(width: 0)),
      ],
      getRows: (_formKey) => List<DataRow2>.generate(data.length, (i) {
        var buildButtonSelectedColor = Colors.grey[200];
        int id = data[i]['id'] as int;
        double value = data[i]['Value'] as double;
        var negativeIskColor = Colors.red;
        var positiveIskColor = Colors.green;
        var iskColor = value >= 0.0 ? positiveIskColor : negativeIskColor;
        const double buttonMaxHeight = 20;
        const double buttonMaxWidth = 42;

        return DataRow2(
            getColor: (ctx) {
              int hoveredId = Provider.of<RowHighlightNotifier>(ctx).currentRowId;
              Color color = ReactionTable.getHoverColor(id, hoveredId);
              return color;
            },
            onHover: ReactionTable.getHoverCallback(id, context),
            key: ValueKey(data[i]['id'].toString()),
            cells: [
              DataCell(Text(EveStaticData.getName(id))),
              DataCell(Text(currencyFormatNumber(value), style: TextStyle(color: iskColor))),
              DataCell(Row(
                children: [
                  SizedBox(
                    height: buttonMaxHeight,
                    width: buttonMaxWidth,
                    child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(buildAdapter.getShouldBuildForID(id) ? buildButtonSelectedColor : Colors.transparent),
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () {
                          buildAdapter.setShouldBuildForID(id, true);
                        },
                        child: const Text('Build')),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: buttonMaxHeight,
                    width: buttonMaxWidth,
                    child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(!buildAdapter.getShouldBuildForID(id) ? buildButtonSelectedColor : Colors.transparent),
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () {
                          buildAdapter.setShouldBuildForID(id, false);
                        },
                        child: const Text('Buy')),
                  ),
                ],
              )),
            ]);
      }),
      columnMinWidths: const [145, 70, 90],
    );
  }
}

class HeuristicTable extends StatelessWidget {
  final Market market;
  final EveBuildContext buildCtx;
  final BuildAdapter buildAdapter;

  const HeuristicTable({Key? key, required this.buildAdapter, required this.market, required this.buildCtx}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ids = <int>{}..addAll(EveStaticData.advancedMoonGooIds);
    for (var tree in buildAdapter.buildForest.getTrees()) {
      ids.remove(tree.id);
    }
    int numRuns = 51;
    int numLines = 4;
    var data = <Map<String, num>>[];
    for (var id in ids.toList()) {
      var tree = BuildTree(id, numRuns, numLines, Inventory.empty(), () => buildCtx);
      double ratio = tree.getProfit(market) / tree.getTotalCost(market);
      data.add(<String, num>{'id': id, 'ratio': ratio});
    }
    data.sort((a, b) => b['ratio']!.compareTo(a['ratio']!));
    return ReactionTable(
      data: data,
      getColumns: (getSortFunc) => [
        DataColumn(label: const Center(child: Text('Reactions', style: TextStyle(fontWeight: FontWeight.bold))), onSort: getSortFunc('Name')),
        DataColumn(numeric: true, label: const Text('Profit %'), onSort: getSortFunc('ratio')),
        const DataColumn(label: SizedBox(width: 0)),
      ],
      getRows: (_) => List<DataRow2>.generate(data.length, (i) {
        int id = data[i]['id'] as int;
        double ratio = data[i]['ratio'] as double;

        return DataRow2(
            getColor: (ctx) {
              int hoveredId = Provider.of<RowHighlightNotifier>(ctx).currentRowId;
              Color color = ReactionTable.getHoverColor(id, hoveredId);
              return color;
            },
            onHover: ReactionTable.getHoverCallback(id, context),
            key: ValueKey(id.toString()),
            cells: [
              DataCell(Text(EveStaticData.getName(id))),
              DataCell(Center(child: Text(percentFormat(ratio)))),
              DataCell(
                SizedBox(
                  height: 20,
                  width: 42,
                  child: OutlinedButton(
                      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
                      onPressed: () {
                        buildAdapter.addTree(id, numRuns, numLines);
                      },
                      child: const Text('Add')),
                ),
              ),
            ]);
      }),
      columnMinWidths: const [173, 69, 43],
    );
  }
}

class InventoryTable extends StatelessWidget {
  final BuildAdapter buildAdapter;
  final MarketAdapter marketAdapter;

  const InventoryTable({Key? key, required this.buildAdapter, required this.marketAdapter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = <Map<String, num>>[];
    var remainingInventory = buildAdapter.buildForest.getMutatedInventoryClone().getQuantities();
    var originalInventory = buildAdapter.buildForest.getOriginalInventoryClone().getQuantities();
    var costs = marketAdapter.market.getAvgMinSellForShoppingList(originalInventory);
    for (var id in originalInventory.keys) {
      data.add(<String, num>{
        'id': id,
        'remaining': remainingInventory[id]!,
        // 'original': originalInventory[id]!,
        'estCost': costs[id]! * remainingInventory[id]!,
        // 'origCost': costs[id]! * originalInventory[id]!
      });
    }
    data.sort((a, b) => b['estCost']!.compareTo(a['estCost']!));
    return ReactionTable(
      shouldFixHeight: false,
      haveMaxHeightIfNotFixed: true,
      data: data,
      getColumns: (getSortFunc) => [
        DataColumn(label: const Center(child: Text('Inventory', style: TextStyle(fontWeight: FontWeight.bold))), onSort: getSortFunc('Name')),
        DataColumn(numeric: true, label: const Text('Remaining'), onSort: getSortFunc('remaining')),
        // DataColumn(numeric: true, label: const Text('Total'), onSort: getSortFunc('original')),
        // DataColumn(numeric: true, label: const Text('Remaining Value'), onSort: getSortFunc('estCost')),
        DataColumn(numeric: true, label: const Text('Value'), onSort: getSortFunc('estCost')),
        // DataColumn(numeric: true, label: const Text('Total\nValue'), onSort: getSortFunc('origCost')),
      ],
      getRows: (_) => List<DataRow2>.generate(data.length, (i) {
        int id = data[i]['id'] as int;
        int remaining = data[i]['remaining'] as int;
        // int original = data[i]['original'] as int;
        double remainCost = data[i]['estCost'] as double;
        // double origCost = data[i]['origCost'] as double;
        return DataRow2(
            getColor: (ctx) {
              int hoveredId = Provider.of<RowHighlightNotifier>(ctx).currentRowId;
              Color color = ReactionTable.getHoverColor(id, hoveredId);
              return color;
            },
            onHover: ReactionTable.getHoverCallback(id, context),
            key: ValueKey(id.toString()),
            cells: [
              DataCell(Text(EveStaticData.getName(id))),
              DataCell(Text(remaining.toString())),
              // DataCell(Text(original.toString())),
              DataCell(Text(currencyFormatNumber(remainCost))),
              // DataCell(
              //     Text(currencyFormatNumber(origCost))),
            ]);
      }),
      columnMinWidths: const [145, 85, 55],
    );
  }
}

class RawMaterialsTable extends StatelessWidget {
  final BuildAdapter buildAdapter;
  final MarketAdapter marketAdapter;

  const RawMaterialsTable({Key? key, required this.buildAdapter, required this.marketAdapter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = <Map<String, num>>[];
    var bill = buildAdapter.buildForest.getBillOfMaterials();
    var costs = marketAdapter.market.getAvgMinSellForShoppingList(bill);
    for (var id in bill.keys) {
      if (!EveStaticData.isBuildable(id) && !EveStaticData.isFuelBlock(id)) {
        data.add(<String, num>{
          'id': id,
          'avgCost': costs[id]!,
          'ttlCost': costs[id]! * bill[id]!,
        });
      }
    }
    data.sort((a, b) => EveStaticData.getName(a['id'] as int).compareTo(EveStaticData.getName(b['id'] as int)));

    return ReactionTable(
      data: data,
      getColumns: (getSortFunc) => [
        DataColumn(label: const Center(child: Text('Raw', style: TextStyle(fontWeight: FontWeight.bold))), onSort: getSortFunc('Name')),
        DataColumn(numeric: true, label: const Text('PPU'), onSort: getSortFunc('avgCost')),
        DataColumn(numeric: true, label: const Text('Total Cost'), onSort: getSortFunc('ttlCost')),
      ],
      getRows: (_) => List<DataRow2>.generate(data.length, (i) {
        int id = data[i]['id'] as int;
        double cost = data[i]['avgCost'] as double;
        double ttlcost = data[i]['ttlCost'] as double;
        return DataRow2(
            getColor: (ctx) {
              int hoveredId = Provider.of<RowHighlightNotifier>(ctx).currentRowId;
              Color color = ReactionTable.getHoverColor(id, hoveredId);
              return color;
            },
            onHover: ReactionTable.getHoverCallback(id, context),
            key: ValueKey(id.toString()),
            cells: [
              DataCell(Text(EveStaticData.getName(id))),
              DataCell(Text(currencyFormatNumber(cost))),
              DataCell(Text(currencyFormatNumber(ttlcost))),
            ]);
      }),
      columnMinWidths: const [120, 60, 85],
    );
  }
}

class FuelBlocksTable extends StatelessWidget {
  final BuildAdapter buildAdapter;
  final MarketAdapter marketAdapter;

  const FuelBlocksTable({Key? key, required this.buildAdapter, required this.marketAdapter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = <Map<String, num>>[];
    var bill = buildAdapter.buildForest.getBillOfMaterials();
    var costs = marketAdapter.market.getAvgMinSellForShoppingList(bill);
    for (var id in bill.keys) {
      if (EveStaticData.isFuelBlock(id)) {
        data.add(<String, num>{
          'id': id,
          'avgCost': costs[id]!,
          'ttlCost': costs[id]! * bill[id]!,
        });
      }
    }
    return ReactionTable(
      data: data,
      getColumns: (getSortFunc) => [
        DataColumn(label: const Center(child: Text('Fuel', style: TextStyle(fontWeight: FontWeight.bold))), onSort: getSortFunc('Name')),
        DataColumn(numeric: true, label: const Text('PPU'), onSort: getSortFunc('avgCost')),
        DataColumn(numeric: true, label: const Text('Total Cost'), onSort: getSortFunc('ttlCost')),
      ],
      getRows: (_) => List<DataRow2>.generate(data.length, (i) {
        int id = data[i]['id'] as int;
        double cost = data[i]['avgCost'] as double;
        double ttlcost = data[i]['ttlCost'] as double;
        return DataRow2(
            getColor: (ctx) {
              int hoveredId = Provider.of<RowHighlightNotifier>(ctx).currentRowId;
              Color color = ReactionTable.getHoverColor(id, hoveredId);
              return color;
            },
            onHover: ReactionTable.getHoverCallback(id, context),
            key: ValueKey(id.toString()),
            cells: [
              DataCell(Text(EveStaticData.getName(id))),
              DataCell(Text(currencyFormatNumber(cost))),
              DataCell(Text(currencyFormatNumber(ttlcost))),
            ]);
      }),
      columnMinWidths: const [130, 60, 85],
    );
  }
}
