import 'package:flutter/material.dart';
import 'package:grapher/components/graph/edge.dart';
import 'package:grapher/components/graph/edge_painter.dart';
import 'package:grapher/components/graph/node.dart';

class GraphCanvas extends StatefulWidget {
  final List<Node> nodes;
  final List<Edge> edges;
  final double nodeRadius;
  final String mode;
  final ValueChanged<List<Node>> onNodesChanged;
  final ValueChanged<List<Edge>> onEdgesChanged;

  const GraphCanvas({
    super.key,
    required this.nodes,
    required this.edges,
    required this.nodeRadius,
    required this.mode,
    required this.onNodesChanged,
    required this.onEdgesChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _GraphCanvasState createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> {
  late List<Node> _nodes;
  late List<Edge> _edges;

  late double _nodeRadius;
  late String _mode;

  int? selectedNode;
  Node? newEdgeStart;
  Offset? newEdgeEnd;

  @override
  void initState() {
    super.initState();
    _nodes = widget.nodes;
    _edges = widget.edges;
    _nodeRadius = widget.nodeRadius;
    _mode = widget.mode;
  }

  @override
  void didUpdateWidget(covariant GraphCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.nodes != oldWidget.nodes) {
      _nodes = widget.nodes;
    }
    if (widget.edges != oldWidget.edges) {
      _edges = widget.edges;
    }
    if (widget.nodeRadius != oldWidget.nodeRadius) {
      _nodeRadius = widget.nodeRadius;
    }
    if (widget.mode != oldWidget.mode) {
      _mode = widget.mode;
    }
  }

  void _handleOnTapDown(TapDownDetails details) {
    if (_mode == 'Add Node') {
      setState(() {
        _nodes.add(Node(
            id: _nodes.length,
            radius: _nodeRadius,
            position: details.localPosition));
      });
    }
    if (_mode == 'DFS Traversal') {
      for (int i = 0; i < _nodes.length; i++) {
        if ((details.localPosition - _nodes[i].position).distance <=
            _nodeRadius) {
          _DFSTraversal(_nodes[i]);
          return;
        }
      }
    }
  }

  void _handleOnPanStart(DragStartDetails details) {
    if (_mode == 'Move Node' && selectedNode == null) {
      for (int i = 0; i < _nodes.length; i++) {
        if ((details.localPosition - _nodes[i].position).distance <=
            _nodeRadius) {
          selectedNode = i;
          return;
        }
      }
      return;
    }
    if (_mode == 'Add Edge' && newEdgeStart == null) {
      for (int i = 0; i < _nodes.length; i++) {
        if ((details.localPosition - _nodes[i].position).distance <=
            _nodeRadius) {
          newEdgeStart = _nodes[i];
          return;
        }
      }
    }
  }

  void _handleOnPanUpdate(DragUpdateDetails details) {
    if (_mode == 'Move Node' && selectedNode != null) {
      setState(() {
        _nodes[selectedNode!].position = details.localPosition;
      });
    }
    if (_mode == 'Add Edge' && newEdgeStart != null) {
      setState(() {
        newEdgeEnd = details.localPosition;
      });
    }
  }

  void _handleOnPanEnd(DragEndDetails details) {
    if (_mode == 'Move Node' && selectedNode != null) {
      selectedNode = null;
    }

    if (_mode == 'Add Edge' && newEdgeStart != null && newEdgeEnd != null) {
      for (int i = 0; i < _nodes.length; i++) {
        if ((newEdgeEnd! - _nodes[i].position).distance <= _nodeRadius) {
          final newEdge = Edge(start: newEdgeStart!, end: _nodes[i]);
          _edges.add(newEdge);
          newEdgeStart!.neighbors.add(newEdge);
          _nodes[i].neighbors.add(newEdge);
          break;
        }
      }
      setState(() {
        newEdgeStart = null;
        newEdgeEnd = null;
      });
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> _DFSTraversal(Node source) async {
    Future<void> queueEdge(Edge e) async {
      if (_mode != "DFS Traversal") return;
      for (int i = 1; i <= 100; i++) {
        setState(() {
          e.animateEdge(i.toDouble(), Colors.yellow, Colors.black);
        });
        await Future.delayed(Duration(milliseconds: 15));
      }
    }

    Future<void> traverseEdge(Edge e) async {
      for (int i = 1; i <= 100; i++) {
        if (_mode != "DFS Traversal") return;
        setState(() {
          e.animateEdge(i.toDouble(), Colors.green, Colors.yellow);
        });
        await Future.delayed(Duration(milliseconds: 15));
      }
    }

    if (source.neighbors.isEmpty) return;

    final List<Edge> edgeStack = [];
    final List<bool> visited = List<bool>.filled(_nodes.length, false);

    setState(() {
      source.color = Colors.red;
    });
    await Future.delayed(Duration(seconds: 1));
    visited[source.id] = true;

    Edge firstEdge = source.neighbors[0];
    if (firstEdge.start != source) {
      final temp = firstEdge.start;
      firstEdge.start = firstEdge.end;
      firstEdge.end = temp;
    }
    await queueEdge(firstEdge);
    edgeStack.add(firstEdge);

    while (edgeStack.isNotEmpty) {
      if (_mode != "DFS Traversal") break;

      Edge currentEdge = edgeStack.removeLast();

      if (visited[currentEdge.end.id]) continue;
      visited[currentEdge.end.id] = true;
      await traverseEdge(currentEdge);

      Node currentNode = currentEdge.end;
      setState(() {
        currentNode.color = Colors.red;
      });
      Future.delayed(Duration(seconds: 1));

      for (Edge e in currentNode.neighbors) {
        if (e.start != currentNode) {
          final temp = e.start;
          e.start = e.end;
          e.end = temp;
        }
        if (visited[e.end.id]) continue;
        await queueEdge(e);
        edgeStack.add(e);
      }
    }

    setState(() {
      for (Node n in _nodes) {
        n.color = Colors.blue;
      }
      for (Edge e in _edges) {
        e.mainColor = Colors.black;
        e.secondaryColor = Colors.black;
        e.pct = 100;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleOnTapDown,
      onPanStart: _handleOnPanStart,
      onPanUpdate: _handleOnPanUpdate,
      onPanEnd: _handleOnPanEnd,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            color: Colors.white,
            child: Stack(
              children: [
                if (_mode == 'Add Edge' &&
                    newEdgeStart != null &&
                    newEdgeEnd != null)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: CustomPaint(
                      painter: EdgePainter(
                        start: newEdgeStart!.position,
                        end: newEdgeEnd!,
                      ),
                    ),
                  ),
                ..._edges.asMap().entries.map(
                  (entry) {
                    return entry.value.drawEdge();
                  },
                ),
                ..._nodes.asMap().entries.map(
                  (entry) {
                    return entry.value.drawNode();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
