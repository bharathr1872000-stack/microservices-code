import os
import requests
from flask import Flask, jsonify
app = Flask(__name__)
USER_URL = os.getenv("USER_SERVICE_URL", "http://user-service:8001")
PRODUCT_URL = os.getenv("PRODUCT_SERVICE_URL", "http://product-service:8002")
ORDERS = [{"id": 1, "user_id": 1, "product_id": 2},
          {"id": 2, "user_id": 2, "product_id": 1}]

@app.get("/health")
def health():
    return jsonify(status="ok", service="order-service")

@app.get("/orders")
def orders():
    return jsonify(ORDERS)

@app.get("/orders/<int:oid>")
def order(oid):
    o = next((x for x in ORDERS if x["id"] == oid), None)
    if not o:
        return jsonify(error="not found"), 404
    try:
        user = requests.get(f"{USER_URL}/users/{o['user_id']}", timeout=3).json()
        product = requests.get(f"{PRODUCT_URL}/products/{o['product_id']}", timeout=3).json()
    except requests.RequestException:
        return jsonify(error="dependency unavailable"), 503
    return jsonify(order=o, user=user, product=product)
