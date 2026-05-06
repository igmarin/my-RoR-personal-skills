The `Api::V1::ProductsController` has been created but does not have an associated Postman Collection for testing. Following the `api-rest-collection` skill, generate a Postman Collection (v2.1) that covers all the endpoints in this controller. The collection should be saved to `postman_collection.json` in the root of the project.

The controller currently supports:
- GET /api/v1/products (index)
- GET /api/v1/products/:id (show)
- POST /api/v1/products (create)
- PUT /api/v1/products/:id (update)
- DELETE /api/v1/products/:id (destroy)

Follow the `api-rest-collection` skill requirements:
1. Scan the controller for routes and their HTTP verbs
2. Generate a Postman Collection with proper folder structure
3. Include example requests with proper params and body
4. Add descriptions and test scripts where appropriate
