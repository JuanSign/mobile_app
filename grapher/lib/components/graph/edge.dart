import 'package:flutter/material.dart';
import 'package:grapher/components/graph/edge_painter.dart';
import 'package:grapher/components/graph/node.dart';

class Edge {
  final Node start, end;
  EdgePainter painter;

  Edge({
    required this.start,
    required this.end,
  }) : painter = EdgePainter(start: start.position, end: end.position);

  void animateEdge(double percentage, Color mainColor, Color secondaryColor) {
    painter = EdgePainter(
        start: start.position,
        end: end.position,
        firstPart: mainColor,
        secondPart: secondaryColor,
        pct: percentage);
  }

  Widget drawEdge() {
    return Positioned(
      left: 0,
      top: 0,
      child: CustomPaint(
        painter: painter,
      ),
    );
  }
}
