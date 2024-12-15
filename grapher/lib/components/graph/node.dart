import 'package:flutter/material.dart';
import 'package:grapher/components/graph/edge.dart';

class Node {
  final double radius;
  final int id;
  Color color;
  Offset position;

  final List<Edge> neighbors = [];

  Node({
    required this.id,
    required this.radius,
    required this.position,
    this.color = Colors.blue,
  });

  void setColor(Color color) {
    this.color = color;
  }

  Widget drawNode() {
    return Positioned(
      left: position.dx - radius,
      top: position.dy - radius,
      child: SizedBox(
        width: 2 * radius,
        height: 2 * radius,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              (id + 1).toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: radius / 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
