EMS API
=========

This node.js app is a JSON API for Muhlenberg College EMS.

Development
===========

Running servers using Docker
------------

1. [Install Docker](https://docs.docker.com/engine/installation/)
2. [Install `docker-compose`](https://docs.docker.com/compose/)


The first time you run Docker, it will pull all the necessary images, which will likely take some time. Docker intelligently rebuilds images that it needs, though, so building changes should be much faster.

Now start the web app:

```
$ docker-compose up
```

Accessing the API
-----------------

Use [Postman](https://chrome.google.com/webstore/detail/postman/fhbjgbiflinjbdggehcddcbncdddomop) to access the API.

To get started, make a `POST` request to `http://localhost:3000/api/accounts/login` and in the body, send the following JSON:

```javascript
{ "username": "admin", "password": "admin" }
```

You should receive back a token. For subsequent requests, add an `Authorization: <YOUR TOKEN>` header.

