import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// IntrinsicWidth・IntrinsicHeight の代わりに使うレイアウト
//
// Flutter Web（CanvasKit）では、フォールバックフォントで描く日本語の文字の
// 固有サイズ（intrinsic size）が実際より小さく見積もられ、折り返しや高さがずれる。
// そのため、子を実際にレイアウトした結果の大きさから幅・高さを揃える。

/// 子を縦に並べ、一番幅の広い子に全体の幅を合わせる（CSS の width: fit-content）
///
/// 幅の狭い子（下線など）も、一番幅の広い子と同じ幅に引き伸ばす。
class FitContentColumn extends MultiChildRenderObjectWidget {
  const FitContentColumn({super.key, required super.children});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFitContentColumn();
}

class _FitContentParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderFitContentColumn extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _FitContentParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _FitContentParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _FitContentParentData) {
      child.parentData = _FitContentParentData();
    }
  }

  @override
  void performLayout() {
    // 1回目：幅の上限だけを与えて、それぞれの子の幅を求める
    var width = 0.0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      child.layout(
        BoxConstraints(maxWidth: constraints.maxWidth),
        parentUsesSize: true,
      );
      width = math.max(width, child.size.width);
    }
    width = constraints.constrainWidth(width);

    // 2回目：すべての子を同じ幅にして縦に並べる
    var height = 0.0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      child.layout(BoxConstraints.tightFor(width: width), parentUsesSize: true);
      (child.parentData! as _FitContentParentData).offset = Offset(0, height);
      height += child.size.height;
    }
    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// 同じ幅の子を横に並べ、一番背の高い子に全員の高さを揃える（CSS Grid の1行）
///
/// 子は高さの制約がない状態でも、高さを指定された状態でもレイアウトできる必要がある。
class EqualHeightRow extends MultiChildRenderObjectWidget {
  final double spacing;

  /// 列の数（子の数より多い場合は、右側を空ける）
  final int columns;

  const EqualHeightRow({
    super.key,
    required this.columns,
    this.spacing = 0,
    required super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderEqualHeightRow(columns: columns, spacing: spacing);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderEqualHeightRow renderObject,
  ) {
    renderObject
      ..columns = columns
      ..spacing = spacing;
  }
}

class _EqualHeightParentData extends ContainerBoxParentData<RenderBox> {}

class RenderEqualHeightRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _EqualHeightParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _EqualHeightParentData> {
  RenderEqualHeightRow({required int columns, required double spacing})
    : _columns = columns,
      _spacing = spacing;

  int _columns;
  set columns(int value) {
    if (value == _columns) return;
    _columns = value;
    markNeedsLayout();
  }

  double _spacing;
  set spacing(double value) {
    if (value == _spacing) return;
    _spacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _EqualHeightParentData) {
      child.parentData = _EqualHeightParentData();
    }
  }

  @override
  void performLayout() {
    final width = constraints.maxWidth;
    final columns = math.max(_columns, childCount).clamp(1, 1 << 20);
    final columnWidth = math.max(
      0.0,
      (width - _spacing * (columns - 1)) / columns,
    );

    // 1回目：幅だけを決めて、一番背の高い子を探す
    var height = 0.0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      child.layout(
        BoxConstraints.tightFor(width: columnWidth),
        parentUsesSize: true,
      );
      height = math.max(height, child.size.height);
    }

    // 2回目：すべての子を同じ高さにする
    // 高さは「最低限の高さ」として渡す。固定の高さにすると子がレイアウトの境界になり、
    // 中身（非同期に組み立てるHTMLなど）が後から伸びても、この行の高さが追従しなくなる。
    var x = 0.0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      child.layout(
        BoxConstraints(
          minWidth: columnWidth,
          maxWidth: columnWidth,
          minHeight: height,
        ),
        parentUsesSize: true,
      );
      height = math.max(height, child.size.height);
      (child.parentData! as _EqualHeightParentData).offset = Offset(x, 0);
      x += columnWidth + _spacing;
    }
    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// 表（列の幅は、その列で一番幅の広いセルに合わせる。CSS の table の自動レイアウト）
///
/// [children] はセルを行ごとに左から順に並べたもの。行の数は children の数 ÷ [columns]。
class CellTable extends MultiChildRenderObjectWidget {
  final int columns;

  /// 行ごとの背景色（null は背景なし）
  final List<Color?> rowColors;

  /// 行の区切り線の色（最後の行には引かない）
  final Color dividerColor;

  const CellTable({
    super.key,
    required this.columns,
    required this.rowColors,
    required this.dividerColor,
    required super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => RenderCellTable(
    columns: columns,
    rowColors: rowColors,
    dividerColor: dividerColor,
  );

  @override
  void updateRenderObject(BuildContext context, RenderCellTable renderObject) {
    renderObject
      ..columns = columns
      ..rowColors = rowColors
      ..dividerColor = dividerColor;
  }
}

class _CellParentData extends ContainerBoxParentData<RenderBox> {}

class RenderCellTable extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _CellParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _CellParentData> {
  RenderCellTable({
    required int columns,
    required List<Color?> rowColors,
    required Color dividerColor,
  }) : _columns = columns,
       _rowColors = rowColors,
       _dividerColor = dividerColor;

  int _columns;
  set columns(int value) {
    if (value == _columns) return;
    _columns = value;
    markNeedsLayout();
  }

  List<Color?> _rowColors;
  set rowColors(List<Color?> value) {
    _rowColors = value;
    markNeedsPaint();
  }

  Color _dividerColor;
  set dividerColor(Color value) {
    if (value == _dividerColor) return;
    _dividerColor = value;
    markNeedsPaint();
  }

  List<double> _rowTops = const [];
  List<double> _rowHeights = const [];

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _CellParentData) {
      child.parentData = _CellParentData();
    }
  }

  @override
  void performLayout() {
    final cells = getChildrenAsList();
    final columns = math.max(1, _columns);
    final rows = (cells.length / columns).ceil();

    // 1回目：幅の制約なしでレイアウトして、列ごとの幅を求める
    final columnWidths = List<double>.filled(columns, 0);
    for (final (index, cell) in cells.indexed) {
      cell.layout(const BoxConstraints(), parentUsesSize: true);
      final column = index % columns;
      columnWidths[column] = math.max(columnWidths[column], cell.size.width);
    }

    // 2回目：列の幅に揃えてレイアウトし、行ごとの高さを求める
    final rowHeights = List<double>.filled(rows, 0);
    for (final (index, cell) in cells.indexed) {
      cell.layout(
        BoxConstraints.tightFor(width: columnWidths[index % columns]),
        parentUsesSize: true,
      );
      final row = index ~/ columns;
      rowHeights[row] = math.max(rowHeights[row], cell.size.height);
    }

    // セルを配置する（行の中では上下中央に揃える）
    final rowTops = <double>[];
    var y = 0.0;
    for (final height in rowHeights) {
      rowTops.add(y);
      y += height;
    }
    for (final (index, cell) in cells.indexed) {
      final row = index ~/ columns;
      final column = index % columns;
      final x = columnWidths.take(column).fold(0.0, (a, b) => a + b);
      (cell.parentData! as _CellParentData).offset = Offset(
        x,
        rowTops[row] + (rowHeights[row] - cell.size.height) / 2,
      );
    }

    _rowTops = rowTops;
    _rowHeights = rowHeights;
    size = constraints.constrain(
      Size(columnWidths.fold(0.0, (a, b) => a + b), y),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    for (var row = 0; row < _rowHeights.length; row++) {
      final rect = Rect.fromLTWH(
        offset.dx,
        offset.dy + _rowTops[row],
        size.width,
        _rowHeights[row],
      );
      final color = row < _rowColors.length ? _rowColors[row] : null;
      if (color != null) canvas.drawRect(rect, Paint()..color = color);
      if (row < _rowHeights.length - 1) {
        canvas.drawRect(
          Rect.fromLTWH(rect.left, rect.bottom - 1, rect.width, 1),
          Paint()..color = _dividerColor,
        );
      }
    }
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// 2つの子を左右に並べ、収まらない場合は2つ目の子を次の行の右端に送る
///
/// CSS の display: flex; flex-wrap: wrap; と、2つ目の子の margin-left: auto に相当する。
class SpaceBetweenWrap extends MultiChildRenderObjectWidget {
  /// 横に並べたときの最小の間隔
  final double spacing;

  /// 折り返したときの行の間隔
  final double runSpacing;

  SpaceBetweenWrap({
    super.key,
    required Widget leading,
    required Widget trailing,
    this.spacing = 0,
    this.runSpacing = 0,
  }) : super(children: [leading, trailing]);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderSpaceBetweenWrap(spacing: spacing, runSpacing: runSpacing);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSpaceBetweenWrap renderObject,
  ) {
    renderObject
      ..spacing = spacing
      ..runSpacing = runSpacing;
  }
}

class _WrapParentData extends ContainerBoxParentData<RenderBox> {}

class RenderSpaceBetweenWrap extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _WrapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _WrapParentData> {
  RenderSpaceBetweenWrap({required double spacing, required double runSpacing})
    : _spacing = spacing,
      _runSpacing = runSpacing;

  double _spacing;
  set spacing(double value) {
    if (value == _spacing) return;
    _spacing = value;
    markNeedsLayout();
  }

  double _runSpacing;
  set runSpacing(double value) {
    if (value == _runSpacing) return;
    _runSpacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _WrapParentData) {
      child.parentData = _WrapParentData();
    }
  }

  @override
  void performLayout() {
    final width = constraints.maxWidth;
    final leading = firstChild!;
    final trailing = childAfter(leading)!;
    final loose = BoxConstraints(maxWidth: width);
    leading.layout(loose, parentUsesSize: true);
    trailing.layout(loose, parentUsesSize: true);

    final leadingData = leading.parentData! as _WrapParentData;
    final trailingData = trailing.parentData! as _WrapParentData;
    final fits = leading.size.width + _spacing + trailing.size.width <= width;

    if (fits) {
      // 1行に並べ、上下中央に揃える
      final height = math.max(leading.size.height, trailing.size.height);
      leadingData.offset = Offset(0, (height - leading.size.height) / 2);
      trailingData.offset = Offset(
        width - trailing.size.width,
        (height - trailing.size.height) / 2,
      );
      size = constraints.constrain(Size(width, height));
    } else {
      // 2つ目の子を次の行の右端に置く
      leadingData.offset = Offset.zero;
      final top = leading.size.height + _runSpacing;
      trailingData.offset = Offset(
        math.max(0, width - trailing.size.width),
        top,
      );
      size = constraints.constrain(Size(width, top + trailing.size.height));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
