import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  final BuildContext context;
  final List<Path> paths;
  final List<Path> selectedPath;
  // final Function(Path curPath) onPressed;
  PathPainter({
    this.context,
    this.paths,
    // this.onPressed,
    this.selectedPath = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    // calculate the scale factor, use the min value
    final double xScale = size.width / MediaQuery.of(context).size.width;
    final double yScale = size.height / MediaQuery.of(context).size.height;
    final double scale = xScale < yScale ? xScale : yScale;

    // scale each path to match canvas size
    final Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(scale, scale);

    // calculate the scaled svg image width and height in order to get right offset
    double scaledSvgWidth = MediaQuery.of(context).size.width * scale;
    double scaledSvgHeight = MediaQuery.of(context).size.height * scale;
    // calculate offset to center the svg image
    double offsetX = (size.width - scaledSvgWidth) / 2;
    double offsetY = (size.height - scaledSvgHeight) / 2;

    // your paint
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.green
      ..strokeWidth = 1.0;

    for (var path in paths) {
      // Here: archive our target, select one province, just change the paint's style to fill
      paint.style = selectedPath.contains(path)
          ? PaintingStyle.fill
          : PaintingStyle.stroke;

      canvas.drawPath(
          // scale and offset each path to match the canvas
          path.transform(matrix4.storage).shift(Offset(offsetX, offsetY)),
          paint);
    }
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) => true;
}
