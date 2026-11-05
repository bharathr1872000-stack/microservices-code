from flask import Flask, jsonify
app = Flask(__name__)
PRODUCTS = [{"id": 1, "name": "Laptop", "price": 55000},
            {"id": 2, "name": "Phone", "price": 20000}]

@app.get("/health")
def health():
    return jsonify(status="ok", service="product-service")

@app.get("/products")
def products():
    return jsonify(PRODUCTS)

@app.get("/products/<int:pid>")
def product(pid):
    for p in PRODUCTS:
        if p["id"] == pid:
            return jsonify(p)
    return jsonify(error="not found"), 404
