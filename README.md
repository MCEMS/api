MCEMS API
=========

This node.js app is a JSON API for Muhlenberg College EMS.

Development
===========

Running servers using Docker
------------

1. [Install Docker](https://docs.docker.com/engine/installation/)
2. [Install `docker-compose`](https://docs.docker.com/compose/)

Now that you have Docker, you can create and seed the database:

```
$ docker-compose run --rm web gulp migrate
$ docker-compose run --rm web gulp seed
```

Seeding the database creates an account with username and password `admin` and assigns it to the `admin` scope.

The first time you run Docker, it will pull all the necessary images, which will likely take some time. Docker intelligently rebuilds images that it needs, though, so building changes should be much faster.

Now start the web app:

```
$ docker-compose up
```

If you make changes to the database schema using a migration and need to apply it to your container, run `docker-compose run --rm web gulp migrate` again. You may get an error if you try to re-seed the database.

Accessing the API
-----------------

Use [Postman](https://chrome.google.com/webstore/detail/postman/fhbjgbiflinjbdggehcddcbncdddomop) to access the API.

To get started, make a `POST` request to `http://localhost:3000/auth/key` and in the body, send the following key-value pairs: username=admin, password=admin.

You should receive back a token. For subsequent requests, add an `Authorization: Bearer <YOUR TOKEN>` header.

