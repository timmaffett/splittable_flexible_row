library splittable_flexible_row;

import 'package:flutter/material.dart';

/// Various options for what to do with the widget that the Row() is being split on.
enum SplitWidgetBehavior {
  exclude,
  includeInThisRow,
  includeInNextRow,
}

/// This class exists as a simple way to convert existing Row() widgets into
/// device size flexible rows which can split into multiple rows when the
/// device size with is below a certain threshold [splitWidth].
/// Simply replace your the `Row(` part of your widget call with
/// `...Splittable.flexibleRow(`.
/// The spread operator ('...') is required because more than a single row can
/// now be returned if the row is split.
///
/// [Splittable.splitWidth] can be set to whatever width you would like to
/// start splitting rows at, any time the screen width is <= to this
/// value the rows will be split.
///
/// The [splitOn], [splitEveryN], [splitAtIndices], [splitWidgetBehavior]
/// are defined as needed depending on how you want to split the row on
/// a narrow screen.
///
/// Example splitting on a certain widget type in the row and including that
/// widget on the next row using [SplitWidgetBehavior.includeInNextRow] :
/// ```
/// ...Splittable.flexibleRow(
///                context: context,
///                splitOn: SplitOn<Radio<FontListType>>(),
///                splitWidgetBehavior:SplitWidgetBehavior.includeInNextRow,
/// ```
/// or
/// splitting the row on every 4th widget and excluding that from the split
/// rows (for example where there is a horizontal spacer widget not needed
/// in the split rows):
/// ```
/// ...Splittable.flexibleRow(
///                context: context,
///                splitEveryN: 4,
///                splitWidgetBehavior:SplitWidgetBehavior.exclude,
/// ```
/// or
/// more complex example were the exact widget indices where the splitting
/// should take place are specified (and excluding these widgets
/// with [SplitWidgetBehavior.exclude])
/// ```
/// ...Splittable.flexibleRow(
///                context: context,
///                forceSplit: useExpandPanel || size.width<=850,
///                splitAtIndices: [ 1 ],
///                splitWidgetBehavior:SplitWidgetBehavior.exclude,
///                mainAxisAlignment: mainAxisAlignment,
/// ```
/// or
/// like that above example but with a a map of minimum screen widths to widget indices.
/// If the screen width is <= to any entry in the table then that entry will be used for
/// determining the widget split indicies and splitting will take place.  If the screen
/// with is > any of the width entries in the [splitAtIndicesByWidth] map then no
/// splitting will take place.  [splitWidgetBehavior] is set to  [SplitWidgetBehavior.includeInThisRow]
/// so that widgets at the split indices will be included in the current row.
/// ```
/// ...Splittable.flexibleRow(
///     context: context,
///     splitAtIndicesByWidth: {
///               500 : [1, 3, 5, 7],
///               600 : [2, 4],
///     },
///     splitWidgetBehavior: SplitWidgetBehavior.includeInThisRow,
///     mainAxisAlignment: mainAxisAlignment,
///     children: <Widget>[
/// ```
class Splittable {
  static int splitWidth = 500;

  static bool willSplitRows(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return size.width <= splitWidth;
  }

  /// [splitAtIndicesByWidth] supply a map of splitScreenWidth's to array of the index numbers of split widgets
  ///                           If the screenWidth is <= a entry's splitScreenWidth then THAT array of split indices is used
  ///                           and the row is split.
  /// [splitAtIndices] supply an array of the index numbers of split widgets
  /// [splitEveryN] supply if you want to split on every Nth widget.
  /// [splitWidgetBehavior] what to do with the split widget SplitWidgetBehavior.(exclude, includeInThisRow or includeInNextRow)
  /// [splitOn] SplitOn instance which holds type of widget to split on, ie. SplitOn<SizedBox>
  static List<Widget> flexibleRow({
    required BuildContext context,
    required List<Widget> children,
    Type? splitOn,
    int? splitEveryN,
    List<int>? splitAtIndices,
    Map<int, List<int>>? splitAtIndicesByWidth,
    SplitWidgetBehavior splitWidgetBehavior = SplitWidgetBehavior.exclude,
    bool? forceSplit,
    // the following are the standard Row() arguments we pass on
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
  }) {
    Size size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    assert(
        splitOn != null ||
            splitEveryN != null ||
            splitAtIndices != null ||
            splitAtIndicesByWidth != null,
        'Must supply either splitOn<T>, splitEveryN or splitAtIndices');
    assert(splitAtIndices == null || splitAtIndicesByWidth == null,
        'Cannot supply both splitAtIndices and splitAtIndicesByWidth');
    bool splitting = forceSplit ?? willSplitRows(context);

    if (splitAtIndicesByWidth != null) {
      // They have supplied a map of min screen widths to widget split indices
      splitting =
          false; // default to not split unless we find an entry that is >= screenWidth
      final keyWidths = splitAtIndicesByWidth.keys.toList();
      keyWidths.sort();
      for (int i = 0; i < keyWidths.length; i++) {
        if (screenWidth <= keyWidths[i]) {
          // we use the first one that the screenWidth is <= to
          splitAtIndices = splitAtIndicesByWidth[keyWidths[i]];
          splitting = true;
          break;
        }
      }
    }

    // if now splitting the row then just return a Row() widget with all these children
    if (!splitting) {
      return [
        Row(
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          children: children,
        ),
      ];
    }
    List<Widget> curRowWidgets = [];
    List<Widget> splitRows = [];
    for (int i = 0; i < children.length; i++) {
      final item = children[i];
      if ((splitOn != null && item.runtimeType == splitOn) ||
          (splitEveryN != null && (i + 1) % splitEveryN == 0) ||
          (splitAtIndices != null && splitAtIndices.contains(i))) {
        // splitting here
        if (splitWidgetBehavior == SplitWidgetBehavior.includeInThisRow) {
          curRowWidgets.add(item);
        }
        splitRows.add(Row(
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          children: [...curRowWidgets],
        ));
        curRowWidgets.clear();
        if (splitWidgetBehavior == SplitWidgetBehavior.includeInNextRow) {
          curRowWidgets.add(item);
        }
      } else {
        curRowWidgets.add(item);
      }
    }
    if (curRowWidgets.isNotEmpty) {
      splitRows.add(Row(
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: [...curRowWidgets],
      ));
    }
    return splitRows;
  }
}
