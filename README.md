# microservices-code (sample app)

Three small Flask services used for the DevOps assignment.

| Service | Port | Endpoints |
|---|---|---|
| user-service | 8001 | /health, /users, /users/<id> |
| product-service | 8002 | /health, /products, /products/<id> |
| order-service | 8003 | /health, /orders, /orders/<id> (calls the other two) |

Run tests (per service): `pip install -r requirements.txt && pytest`
Build: `docker build -t user-service:1.0.0 ./user-service`
