import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';

class PathPainter extends CustomPainter {
  final BuildContext context;
  final List<Path> paths;
  final Path curPath;
  final double height;
  final double width;
  final Function(Path curPath) onPressed;
  PathPainter(
      {this.context,
      this.paths,
      this.curPath,
      this.onPressed,
      this.height,
      this.width});

  @override
  void paint(Canvas canvas, Size size) {
    // calculate the scale factor, use the min value
    final double xScale = size.width / width;
    final double yScale = size.height / height;
    final double scale = xScale < yScale ? xScale : yScale;

    // scale each path to match canvas size
    final Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(scale, scale);

    // calculate the scaled svg image width and height in order to get right offset
    double scaledSvgWidth = width * scale;
    double scaledSvgHeight = height * scale;
    // calculate offset to center the svg image
    double offsetX = (size.width - scaledSvgWidth) / 2;
    double offsetY = (size.height - scaledSvgHeight) / 2;

    final TouchyCanvas touchCanvas = TouchyCanvas(context, canvas);

    // your paint
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.green
      ..strokeWidth = 1.0;

    for (var path in paths) {
      // Here: archive our target, select one path/state, just change the paint's style to fill

      paint.style = path == curPath ? PaintingStyle.fill : PaintingStyle.stroke;

      touchCanvas.drawPath(
        path.transform(matrix4.storage).shift(Offset(offsetX, offsetY)),
        paint,
        onTapDown: (details) {
          // notify select change and redraw
          onPressed(path);
        },
      );
    }
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) => true;
}
