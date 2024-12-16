import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grapher/components/graph/edge.dart';
import 'package:grapher/components/graph/edge_painter.dart';
import 'package:grapher/components/graph/node.dart';
import 'package:grapher/components/graph/traversal_edge.dart';

import 'package:http/http.dart' as http;

class GraphCanvas extends StatefulWidget {
  final List<Node> nodes;
  final List<Edge> edges;
  final double nodeRadius;
  final String mode;
  final Function(String) onModeChange;

  const GraphCanvas({
    super.key,
    required this.nodes,
    required this.edges,
    required this.nodeRadius,
    required this.mode,
    required this.onModeChange,
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

  bool _isLoading = false;

  late List<TraversalEdge> _traversalList;
  @override
  void initState() {
    super.initState();
    _nodes = widget.nodes;
    _edges = widget.edges;
    _nodeRadius = widget.nodeRadius;
    _mode = widget.mode;
    _traversalList = [];
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
      if (_mode == 'Save') Future.microtask(() => _SaveGraph());
      if (_mode == 'Load') Future.microtask(() => _LoadGraph());
      if (_mode == 'Clear') _ClearCanvas();
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
    if (_mode == 'BFS Traversal') {
      for (int i = 0; i < _nodes.length; i++) {
        if ((details.localPosition - _nodes[i].position).distance <=
            _nodeRadius) {
          _BFSTraversal(_nodes[i]);
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

  Future<void> queueEdge(Edge e) async {
    if (_mode != "DFS Traversal" && _mode != "BFS Traversal") return;
    for (int i = 1; i <= 100; i++) {
      setState(() {
        e.animateEdge(i.toDouble(), Colors.yellow, Colors.black);
      });
      await Future.delayed(Duration(milliseconds: 15));
    }
  }

  Future<void> dequeuEdge(Edge e) async {
    if (_mode != "DFS Traversal" && _mode != "BFS Traversal") return;
    Color secondaryColor = e.mainColor;
    for (int i = 100; i >= 0; i--) {
      setState(() {
        e.animateEdge(i.toDouble(), secondaryColor, Colors.black);
      });
      await Future.delayed(Duration(milliseconds: 15));
    }
  }

  Future<void> traverseEdge(Edge e) async {
    Color secondaryColor = e.mainColor;
    for (int i = 1; i <= 100; i++) {
      if (_mode != "DFS Traversal" && _mode != "BFS Traversal") return;
      setState(() {
        e.animateEdge(i.toDouble(), Colors.green, secondaryColor);
      });
      await Future.delayed(Duration(milliseconds: 15));
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> _DFSTraversal(Node source) async {
    if (source.neighbors.isEmpty) return;

    final List<Edge> edgeStack = [];
    final List<bool> visited = List<bool>.filled(_nodes.length, false);

    setState(() {
      source.color = Colors.red;
    });
    await Future.delayed(Duration(seconds: 1));
    visited[source.id] = true;

    for (Edge e in source.neighbors) {
      if (_mode != "DFS Traversal") break;
      if (e.start.id != source.id) {
        final temp = e.start;
        e.start = e.end;
        e.end = temp;
      }
      setState(() {
        _traversalList.add(TraversalEdge(e, Colors.yellow));
      });
      await queueEdge(e);
      edgeStack.add(e);
    }

    while (edgeStack.isNotEmpty) {
      if (_mode != "DFS Traversal") break;

      Edge currentEdge = edgeStack.removeLast();
      setState(() {
        _traversalList.last.color = Colors.lightBlueAccent;
      });
      await Future.delayed(Duration(seconds: 1));
      if (_mode != "DFS Traversal") break;
      if (visited[currentEdge.end.id]) {
        setState(() {
          _traversalList.last.color = Colors.redAccent;
        });
        await dequeuEdge(currentEdge);
        setState(() {
          _traversalList.removeLast();
        });
        await Future.delayed(Duration(seconds: 1));
        continue;
      } else {
        visited[currentEdge.end.id] = true;
        setState(() {
          _traversalList.last.color = Colors.greenAccent;
        });
        await traverseEdge(currentEdge);
        setState(() {
          _traversalList.removeLast();
        });
        await Future.delayed(Duration(seconds: 1));
      }
      if (_mode != "DFS Traversal") break;
      Node currentNode = currentEdge.end;
      setState(() {
        currentNode.color = Colors.red;
      });
      Future.delayed(Duration(seconds: 1));

      for (Edge e in currentNode.neighbors) {
        if (_mode != "DFS Traversal") break;
        if (e.start.id != currentNode.id) {
          final temp = e.start;
          e.start = e.end;
          e.end = temp;
        }
        if (visited[e.end.id]) {
          final temp = e.start;
          e.start = e.end;
          e.end = temp;
          continue;
        }
        setState(() {
          _traversalList.add(TraversalEdge(e, Colors.yellow));
        });
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
    setState(() {
      _traversalList.clear();
    });
  }

  // ignore: non_constant_identifier_names
  Future<void> _BFSTraversal(Node source) async {
    if (source.neighbors.isEmpty) return;

    final List<Edge> edgeStack = [];
    final List<bool> visited = List<bool>.filled(_nodes.length, false);

    setState(() {
      source.color = Colors.red;
    });
    await Future.delayed(Duration(seconds: 1));
    visited[source.id] = true;

    for (Edge e in source.neighbors) {
      if (e.start.id != source.id) {
        final temp = e.start;
        e.start = e.end;
        e.end = temp;
      }
      setState(() {
        _traversalList.add(TraversalEdge(e, Colors.yellow));
      });
      await queueEdge(e);
      edgeStack.add(e);
    }

    while (edgeStack.isNotEmpty) {
      if (_mode != "BFS Traversal") break;

      Edge currentEdge = edgeStack.removeAt(0);
      setState(() {
        _traversalList.first.color = Colors.lightBlueAccent;
      });
      await Future.delayed(Duration(seconds: 1));
      if (_mode != "BFS Traversal") break;
      if (visited[currentEdge.end.id]) {
        setState(() {
          _traversalList.first.color = Colors.redAccent;
        });
        await dequeuEdge(currentEdge);
        setState(() {
          _traversalList.removeAt(0);
        });
        await Future.delayed(Duration(seconds: 1));
        continue;
      } else {
        visited[currentEdge.end.id] = true;
        setState(() {
          _traversalList.first.color = Colors.greenAccent;
        });
        await traverseEdge(currentEdge);
        setState(() {
          _traversalList.removeAt(0);
        });
        await Future.delayed(Duration(seconds: 1));
      }
      if (_mode != "BFS Traversal") break;
      Node currentNode = currentEdge.end;
      setState(() {
        currentNode.color = Colors.red;
      });
      Future.delayed(Duration(seconds: 1));

      for (Edge e in currentNode.neighbors) {
        if (_mode != "BFS Traversal") break;
        if (e.start.id != currentNode.id) {
          final temp = e.start;
          e.start = e.end;
          e.end = temp;
        }
        if (visited[e.end.id]) {
          final temp = e.start;
          e.start = e.end;
          e.end = temp;
          continue;
        }
        setState(() {
          _traversalList.add(TraversalEdge(e, Colors.yellow));
        });
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
    setState(() {
      _traversalList.clear();
    });
  }

// ignore: non_constant_identifier_names
  Future<void> _SaveGraph() async {
    if (_nodes.isEmpty) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Warning'),
            content: Text('No graph detected. Please add nodes to the graph.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      TextEditingController idController = TextEditingController();
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Enter an ID for the graph:'),
                SizedBox(height: 16.0),
                TextField(
                  controller: idController,
                  decoration: InputDecoration(
                    labelText: 'Graph ID',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Save'),
                onPressed: () async {
                  Navigator.of(context).pop();

                  String graphId = idController.text.trim();
                  if (graphId.isEmpty) {
                    _showSnackBar('Graph ID cannot be empty!');
                  } else {
                    List<List<double>> nodesList = [];
                    List<List<int>> edgesList = [];

                    for (Node node in _nodes) {
                      nodesList.add([node.position.dx, node.position.dy]);
                    }
                    for (Edge edge in _edges) {
                      edgesList.add([edge.start.id, edge.end.id]);
                    }

                    String graph = jsonEncode({
                      "nodes": nodesList,
                      "edges": edgesList,
                    });

                    Map<String, dynamic> request = {
                      "id": graphId,
                      "graph": graph
                    };

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      final response = await http.post(
                        Uri.parse(
                            'https://grapher-aiyc.onrender.com/save_graph'),
                        headers: {
                          "Content-Type": "application/json",
                        },
                        body: jsonEncode(request),
                      );

                      if (response.statusCode == 201) {
                        _showSnackBar('Graph Saved.');
                      } else {
                        _showSnackBar(
                            'Failed to Save Graph. Error: ${response.body}');
                      }
                    } catch (error) {
                      _showSnackBar('Failed to Save Graph.');
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  }
                },
              ),
            ],
          );
        },
      );
    }

    widget.onModeChange('Move Node');
  }

  // ignore: non_constant_identifier_names
  Future<void> _LoadGraph() async {
    TextEditingController idController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter graph ID:'),
              SizedBox(height: 16.0),
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: 'Graph ID',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Load'),
              onPressed: () async {
                Navigator.of(context).pop();

                String graphId = idController.text.trim();
                if (graphId.isEmpty) {
                  _showSnackBar('Graph ID cannot be empty!');
                } else {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    final response = await http.post(
                      Uri.parse('https://grapher-aiyc.onrender.com/load_graph'),
                      headers: {
                        "Content-Type": "application/json",
                      },
                      body: jsonEncode({"id": graphId}),
                    );

                    if (response.statusCode == 404) {
                      _showSnackBar('Graph Not Found.');
                    } else if (response.statusCode != 200) {
                      _showSnackBar(
                          'Failed to Load Graph. Error: ${response.body}');
                    } else {
                      // Parse the response body
                      final data = jsonDecode(response.body);

                      final graphData = data['graph'];

                      final List<List<double>> nodes =
                          (graphData['nodes'] as List<dynamic>)
                              .map((node) => List<double>.from(node))
                              .toList();

                      final List<List<int>> edges =
                          (graphData['edges'] as List<dynamic>)
                              .map((edge) => List<int>.from(edge))
                              .toList();

                      _nodes.clear();
                      _edges.clear();
                      for (int i = 0; i < nodes.length; i++) {
                        setState(() {
                          _nodes.add(Node(
                              id: i,
                              radius: _nodeRadius,
                              position: Offset(nodes[i][0], nodes[i][1])));
                        });
                      }
                      for (int i = 0; i < edges.length; i++) {
                        setState(() {
                          Edge newEdge = Edge(
                              start: _nodes[edges[i][0]],
                              end: _nodes[edges[i][1]]);
                          _edges.add(newEdge);
                          _nodes[edges[i][0]].neighbors.add(newEdge);
                          _nodes[edges[i][1]].neighbors.add(newEdge);
                        });
                      }
                    }
                  } catch (error) {
                    _showSnackBar('Failed to Load Graph.');
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );

    widget.onModeChange('Move Node');
  }

  // ignore: non_constant_identifier_names
  void _ClearCanvas() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _nodes = [];
          _edges = [];
        });
      }
    });
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
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
          return Stack(
            children: [
              Container(
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
              ),
              if (_mode == 'DFS Traversal' || _mode == 'BFS Traversal')
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 150,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mode,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ..._traversalList.map((tEdge) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tEdge.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Edge: ${tEdge.edge.start.id + 1} -> ${tEdge.edge.end.id + 1}',
                              style: TextStyle(fontSize: 14),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_isLoading,
                  child: _isLoading
                      ? Container(
                          color: Colors.grey.withValues(),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
