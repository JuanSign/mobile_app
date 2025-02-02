import 'package:flutter/material.dart';
import 'package:grapher/components/graph/edge.dart';
import 'package:grapher/components/graph/node.dart';
import 'package:grapher/components/graph_canvas.dart';

class SandboxPage extends StatefulWidget {
  const SandboxPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SandboxPageState createState() => _SandboxPageState();
}

class _SandboxPageState extends State<SandboxPage> {
  final List<Node> _nodes = [];
  final List<Edge> _edges = [];
  String _mode = 'Move Node';

  void _switchMode(String mode) {
    setState(() {
      _mode = mode;
    });
  }

  void _updateMode(String mode) {
    setState(() {
      _mode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph Canvas'),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              title: Text(
                'Move Node',
                style: TextStyle(
                  fontWeight: _mode == 'Move Node'
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              selected: _mode == 'Move Node',
              selectedTileColor: Colors.blueAccent,
              onTap: () {
                _switchMode('Move Node');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'Add Node',
                style: TextStyle(
                  fontWeight:
                      _mode == 'Add Node' ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              selected: _mode == 'Add Node',
              selectedTileColor: Colors.blueAccent,
              onTap: () {
                _switchMode('Add Node');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'Add Edge',
                style: TextStyle(
                  fontWeight:
                      _mode == 'Add Edge' ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              selected: _mode == 'Add Edge',
              selectedTileColor: Colors.blueAccent,
              onTap: () {
                _switchMode('Add Edge');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'DFS Traversal',
                style: TextStyle(
                  fontWeight: _mode == 'DFS Traversal'
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              selected: _mode == 'DFS Traversal',
              selectedTileColor: Colors.blueAccent,
              onTap: () {
                _switchMode('DFS Traversal');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'BFS Traversal',
                style: TextStyle(
                  fontWeight: _mode == 'BFS Traversal'
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              selected: _mode == 'BFS Traversal',
              selectedTileColor: Colors.blueAccent,
              onTap: () {
                _switchMode('BFS Traversal');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'Save',
                style: TextStyle(
                  fontWeight:
                      _mode == 'Save' ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              selected: _mode == 'Save',
              selectedTileColor: Colors.blueAccent,
              onTap: () {
                _switchMode('Save');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'Load',
                style: TextStyle(
                  fontWeight:
                      _mode == 'Load' ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              selected: _mode == 'Load',
              selectedTileColor: Colors.blueAccent,
              onTap: () {
                _switchMode('Load');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'Clear',
                style: TextStyle(
                  fontWeight:
                      _mode == 'Clear' ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              selected: _mode == 'Clear',
              selectedTileColor: Colors.blueAccent,
              onTap: () {
                _switchMode('Clear');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: GraphCanvas(
        nodes: _nodes,
        edges: _edges,
        nodeRadius: 25,
        mode: _mode,
        onModeChange: _updateMode,
      ),
    );
  }
}
