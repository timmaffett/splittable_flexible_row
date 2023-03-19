# Splittable Flexible Row class for easily building flexible layouts

## _splittable - Adjective. Capable of being split._

This package allows the definition of Row() widgets with additional information on how they can be split into multiple rows when the screen width does not allow the full row to be displayed.  This allows for the easy defintition of screen size flexible flutter layouts using Row's.

A live example of the package in use can be found  [here](https://timmaffett.github.io/material_symbols_icons).

I created this package because I often created layouts using Column/Row for the web or desktop platforms, only to encounter the dreaded caution overflow boxes when testing the layouts on mobile, or when resizing the windows down to smaller widths.
This package allows for the direct replacement of `Row()` widgets with `...Splittable.flexibleRow()` calls.
The spread operator (`...`) is used so that this package can return 1 *or more* Row() widgets depending on the current screen width.
This allows for the author to easily specify how they would like the `Row()`'s `children` array of widgets to be split.
This can be specified several different ways, depending on the row contents, by different screen widths, etc.

The Row's array of children widget can told to split on specific widget types [splitOn], split every N widgets [splitEveryN],
split at specific indices [splitAtIndices], or the most versitile [splitAtIndicesByWidth], which allows for specifying a map of how you would like the Row to be split depending on a map of screen widths.

## Features

Easy and support simple drop in replacment for using Row() with very little other required code changes to accomplish a flexible layout.

## Getting started

Include the dependency in pubspec.yaml, add the import, and replace your `Row()` widgets with `...splittable.flexibleRow()` calls.  The only additional information is how you would like to have the row split.

## Usage

Add depends to `pubspec.yaml`

```yaml
  splittablle_flexible_row
```

```dart
import 'package:splittable_flexible_row/splittable_flexible_row.dart';




```
