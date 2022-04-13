import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_parsing/path_parsing.dart';
import 'package:xml/xml.dart' as xml;
//SVG parsing

/// Parses a minimal subset of a SVG file and extracts all paths segments.
class SvgParser {
  /// Each [PathSegment] represents a continuous Path element of the parent Path
  final List<PathSegment> _pathSegments = <PathSegment>[];
  List<Path> _paths = <Path>[];

  Color parseColor(String cStr) {
    if (cStr == null || cStr.isEmpty) {
      throw UnsupportedError("Empty color field found.");
    }
    if (cStr[0] == '#') {
      return Color(int.parse(cStr.substring(1), radix: 16)).withOpacity(
          1.0); // Hex to int: from https://stackoverflow.com/a/51290420/9452450
    } else if (cStr == 'none') {
      return Colors.transparent;
    } else {
      throw UnsupportedError(
          "Only hex color format currently supported. String:  $cStr");
    }
  }

  //Extract segments of each path and create [PathSegment] representation
  void addPathSegments(Path path, int index, double strokeWidth, Color color) {
    int firstPathSegmentIndex = _pathSegments.length;
    int relativeIndex = 0;
    path.computeMetrics().forEach((pp) {
      PathSegment segment = PathSegment()
        ..path = pp.extractPath(0, pp.length)
        ..length = pp.length
        ..firstSegmentOfPathIndex = firstPathSegmentIndex
        ..pathIndex = index
        ..relativeIndex = relativeIndex;

      if (color != null) segment.color = color;

      if (strokeWidth != null) segment.strokeWidth = strokeWidth;

      _pathSegments.add(segment);
      relativeIndex++;
    });
  }

  void loadFromString(String svgString) {
    _pathSegments.clear();
    int index = 0; //number of parsed path elements
    var doc = xml.XmlDocument.parse(svgString);
    doc
        .findAllElements("path")
        .map((node) => node.attributes)
        .forEach((attributes) {
      var dPath = attributes.firstWhere((attr) => attr.name.local == "d",
          orElse: () => null);
      if (dPath != null) {
        Path path = Path();
        writeSvgPathDataToPath(dPath.value, PathModifier(path));

        Color color;
        double strokeWidth;

        //Attributes - [1] css-styling
        var style = attributes.firstWhere((attr) => attr.name.local == "style",
            orElse: () => null);
        if (style != null) {
          //Parse color of stroke
          RegExp exp = RegExp(r"stroke:([^;]+);");
          Match match = exp.firstMatch(style.value);
          if (match != null) {
            String cStr = match.group(1);
            color = parseColor(cStr);
          }
          //Parse stroke-width
          exp = RegExp(r"stroke-width:([0-9.]+)");
          match = exp.firstMatch(style.value);
          if (match != null) {
            String cStr = match.group(1);
            strokeWidth = double.tryParse(cStr);
          }
        }

        //Attributes - [2] svg-attributes
        var strokeElement = attributes.firstWhere(
            (attr) => attr.name.local == "stroke",
            orElse: () => null);
        if (strokeElement != null) {
          color = parseColor(strokeElement.value);
        }

        var strokeWidthElement = attributes.firstWhere(
            (attr) => attr.name.local == "stroke-width",
            orElse: () => null);
        if (strokeWidthElement != null) {
          strokeWidth = double.tryParse(strokeWidthElement.value);
        }

        _paths.add(path);
        addPathSegments(path, index, strokeWidth, color);
        index++;
      }
    });
  }

  void loadFromPaths(List<Path> paths) {
    _pathSegments.clear();
    _paths = paths;

    int index = 0;
    for (var p in paths) {
      assert(p != null, "Path element in `paths` must not be null.");
      addPathSegments(p, index, null, null);
      index++;
    }
  }

  /// Parses Svg from provided asset path
  Future<void> loadFromFile(String file) async {
    _pathSegments.clear();
    String svgString = await rootBundle.loadString(file);
    loadFromString(svgString);
  }

  /// Returns extracted [PathSegment] elements of parsed Svg
  List<PathSegment> getPathSegments() {
    return _pathSegments;
  }

  /// Returns extracted [Path] elements of parsed Svg
  List<Path> getPaths() {
    return _paths;
  }
}

/// Represents a segment of path, as returned by path.computeMetrics() and the associated painting parameters for each Path
class PathSegment {
  PathSegment()
      : strokeWidth = 0.0,
        color = Colors.black,
        firstSegmentOfPathIndex = 0,
        relativeIndex = 0,
        pathIndex = 0 {
    //That is fun.
    // List colors = [Colors.red, Colors.green, Colors.yellow];
    // Random random = new Random();
    // color = colors[random.nextInt(3)];
  }

  /// A continuous path/segment
  Path path;
  double strokeWidth;
  Color color;

  /// Length of the segment path
  double length;

  /// Denotes the index of the first segment of the containing path when PathOrder.original
  int firstSegmentOfPathIndex;

  /// Corresponding containing path index
  int pathIndex;

  /// Denotes relative index to  firstSegmentOfPathIndex
  int relativeIndex;
}

/// A [PathProxy] that saves Path command in path
class PathModifier extends PathProxy {
  PathModifier(this.path);

  Path path;

  @override
  void close() {
    path.close();
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  void lineTo(double x, double y) {
    path.lineTo(x, y);
  }

  @override
  void moveTo(double x, double y) {
    path.moveTo(x, y);
  }
}
