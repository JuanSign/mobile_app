import os

from dotenv import load_dotenv
from flask import Flask, request, jsonify
from flask_cors import CORS
from waitress import serve
import psycopg2

app = Flask(__name__)
CORS(app)

load_dotenv()

conn = psycopg2.connect(
    dbname=os.getenv('PGDATABASE'),
    host=os.getenv('PGHOST'),
    password=os.getenv('PGPASSWORD'),
    port=os.getenv('PGPORT'),
    user=os.getenv('PGUSER'),
)
cursor = conn.cursor()

@app.route('/save_graph', methods=['POST'])
def save_graph():
    try:
        data = request.json
        name = data['id']
        value = data['graph']
        query = "INSERT INTO graphs (id, graph) VALUES (%s, %s)"
        cursor.execute(query, (name, value))
        conn.commit()
        return jsonify({"MESSAGE": "SUCCESS"}), 201
    except Exception as e:
        return jsonify({"ERROR": str(e)}), 400

if __name__ == '__main__':
    serve(app, host='0.0.0.0', port=5000)
