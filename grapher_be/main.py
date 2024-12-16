import os
import json  # To parse the "graph" string into a dictionary
from dotenv import load_dotenv
from flask import Flask, request, jsonify
from flask_cors import CORS
from waitress import serve
import psycopg2

# Load environment variables
load_dotenv()

# Connect to PostgreSQL
conn = psycopg2.connect(
    dbname=os.getenv('PGDATABASE'),
    host=os.getenv('PGHOST'),
    password=os.getenv('PGPASSWORD'),
    port=os.getenv('PGPORT'),
    user=os.getenv('PGUSER'),
)
cursor = conn.cursor()

app = Flask(__name__)
CORS(app)

# Validation function
def validate_graph(graph):
    if not isinstance(graph, dict):
        return "`graph` must be a JSON object."

    if 'nodes' not in graph or not isinstance(graph['nodes'], list):
        return "`nodes` must be a list of tuples (double, double)."
    for node in graph['nodes']:
        if not (isinstance(node, list) or isinstance(node, tuple)) or len(node) != 2:
            return "Each node must be a tuple (double, double)."
        if not all(isinstance(coord, float) for coord in node):
            return "Node coordinates must be doubles."

    if 'edges' not in graph or not isinstance(graph['edges'], list):
        return "`edges` must be a list of tuples (int, int)."
    for edge in graph['edges']:
        if not (isinstance(edge, list) or isinstance(edge, tuple)) or len(edge) != 2:
            return "Each edge must be a tuple (int, int)."
        if not all(isinstance(index, int) for index in edge):
            return "Edge indices must be integers."

    return None

@app.route('/save_graph', methods=['POST'])
def save_graph():
    try:
        data = request.get_json()

        # Validate 'id'
        if 'id' not in data or not isinstance(data['id'], str):
            return jsonify({"error": "`id` is required and must be a string."}), 400

        # Validate 'graph' as a string and parse it
        if 'graph' not in data or not isinstance(data['graph'], str):
            return jsonify({"error": "`graph` is required and must be a string."}), 400

        try:
            graph = json.loads(data['graph'])  # Parse the string into a dictionary
        except json.JSONDecodeError:
            return jsonify({"error": "`graph` must be a valid JSON string."}), 400

        # Validate the parsed graph structure
        error = validate_graph(graph)
        if error:
            return jsonify({"error": error}), 400

        # Start the transaction
        cursor.execute("BEGIN")

        # Insert into the database
        query = "INSERT INTO graphs (id, graph) VALUES (%s, %s)"
        cursor.execute(query, (data['id'], json.dumps(graph)))  # Store graph as a JSON string

        # Commit the transaction
        conn.commit()

        return jsonify({"message": "Graph saved successfully."}), 201

    except Exception as e:
        # Rollback the transaction if there is an error
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    
@app.route('/load_graph', methods=['POST'])
def load_graph():
    try:
        # Get the JSON data from the request body
        data = request.get_json()

        # Validate that 'id' is present in the request body
        if 'id' not in data or not isinstance(data['id'], str):
            return jsonify({"error": "`id` is required and must be a string."}), 400

        graph_id = data['id']

        # Query the database to fetch the graph by its ID
        query = "SELECT id, graph FROM graphs WHERE id = %s"
        cursor.execute(query, (graph_id,))

        # Fetch the result
        result = cursor.fetchone()

        # If no graph was found for the given ID, return a 404 error
        if result is None:
            return jsonify({"error": "Graph not found."}), 404

        # Parse the graph from the database (it's stored as a JSON string)
        graph = json.loads(result[1])  # result[1] is the 'graph' column

        # Return the graph as a JSON response
        return jsonify({
            "id": result[0],  # Return the graph's ID
            "graph": graph     # Return the graph data
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    serve(app, host='0.0.0.0', port=5000)
