import 'package:flutter/material.dart';
import 'package:grapher/components/graph/edge_painter.dart';
import 'package:grapher/components/graph/node.dart';

class Edge {
  Node start, end;
  Color mainColor;
  Color secondaryColor;
  double pct;

  Edge({
    required this.start,
    required this.end,
    this.mainColor = Colors.black,
    this.secondaryColor = Colors.black,
    this.pct = 100,
  });

  void animateEdge(double percentage, Color mainColor, Color secondaryColor) {
    pct = percentage;
    this.mainColor = mainColor;
    this.secondaryColor = secondaryColor;
  }

  Widget drawEdge() {
    return Positioned(
      left: 0,
      top: 0,
      child: CustomPaint(
        painter: EdgePainter(
          start: start.position,
          end: end.position,
          firstPart: mainColor,
          secondPart: secondaryColor,
          pct: pct,
        ),
      ),
    );
  }
}
