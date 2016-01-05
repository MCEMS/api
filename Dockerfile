FROM node:4.2
EXPOSE 3000
COPY . /app
WORKDIR /app
ENV NODE_ENV=docker
RUN npm install
CMD npm start

