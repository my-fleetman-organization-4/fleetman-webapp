# Etapa 1: build Angular
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build 


FROM nginx:1.14.0-alpine

MAINTAINER Richard Chesterwood "richard@inceptiontraining.co.uk"

RUN apk add --update bash && rm -rf /var/cache/apk/*

RUN rm -rf /usr/share/nginx/html/*

COPY /dist /usr/share/nginx/html

#COPY nginx.conf /etc/nginx/nginx.conf
COPY dist/fleetman-webapp /usr/share/nginx/html


CMD ["nginx", "-g", "daemon off;"]
