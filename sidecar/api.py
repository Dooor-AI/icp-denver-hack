from flask import Flask, jsonify
import json

app = Flask(__name__)

@app.route('/verify', methods=['GET'])
def verify():
    try:
        with open('/certs/status.json', 'r') as f:
            status = json.load(f)
        return jsonify(status)
    except Exception as e:
        return jsonify({"error": str(e), "status": "error"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)