MCEMS API
=========

This node.js app is a JSON API for Muhlenberg College EMS.

Development
===========

Running servers using Docker
------------

1. [Install Docker](https://docs.docker.com/engine/installation/)
2. Run `make init` to download and build docker images. This will also spin up a postgres container.
3. Run `make rebuild` to rebuild and restart the docker image for the API.
4. Run `make teardown` to stop and remove the database and web containers.

Accessing the API
-----------------

The accounts table is seeded with an `admin`:`admin` account. Use [Postman](https://chrome.google.com/webstore/detail/postman/fhbjgbiflinjbdggehcddcbncdddomop) to access the API.

To get started, make a `POST` request to `http://localhost:3000/auth/key` and in the body, send the following key-value pairs: username=admin, password=admin.

You should receive back a token. For subsequent requests, add an `Authorization: Bearer <YOUR TOKEN>` header.

