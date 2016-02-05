FROM node:4.2
MAINTAINER Ben Burwell <ben@benburwell.com>

# set our environment (used for db connection)
ENV NODE_ENV=docker
ENV REDIS_URL="redis://redis:6379"
ENV ACTIVE911_REFRESH_TOKEN="Dummy Token"

# install some stuff we need no matter what
RUN npm install -g strongloop

# cache our dependencies, these will only be updated if package.json changes
COPY package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /app && cp -a /tmp/node_modules /app

# load application code ontop of cached layers
WORKDIR /app
COPY . /app

EXPOSE 3000

CMD slc run

