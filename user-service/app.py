from flask import Flask, jsonify
app = Flask(__name__)
USERS = [{"id": 1, "name": "Asha"}, {"id": 2, "name": "Ravi"}]

@app.get("/health")
def health():
    return jsonify(status="ok", service="user-service")

@app.get("/users")
def users():
    return jsonify(USERS)

@app.get("/users/<int:uid>")
def user(uid):
    for u in USERS:
        if u["id"] == uid:
            return jsonify(u)
    return jsonify(error="not found"), 404
