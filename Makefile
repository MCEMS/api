init:
	docker build -t mcems-api .
	docker run --name db -e POSTGRES_DB=mcems -e POSTGRES_USER=mcems -e POSTGRES_PASSWORD=mcems -d postgres
	docker run --name web -d -p 3000:3000 --link db:postgres mcems-api

rebuild:
	docker stop web
	docker rm web
	docker build -t mcems-api .
	docker run --name web -d -p 3000:3000 --link db:postgres mcems-api

teardown:
	docker stop web
	docker stop db
	docker rm web
	docker rm db

