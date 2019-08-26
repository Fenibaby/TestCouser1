# base image
FROM node:12.8.1 AS build

# install certificates and Proxy

ENV  HTTPS_PROXY=http://gate.zrh.swissre.com:8080/
ENV  HTTP_PROXY=http://gate.zrh.swissre.com:8080/
ENV  http_proxy=http://gate.zrh.swissre.com:8080/
ENV  https_proxy=http://gate.zrh.swissre.com:8080/


RUN set -x \
    && apt-get update -qq \
    && apt-get install curl apt-transport-https ca-certificates gnupg2 software-properties-common -y \
    && curl -sSL http://pki.swissre.com/aia/SwissReRootCA1.crt > /usr/local/share/ca-certificates/swissre1.crt \
    && curl -sSL http://pki.swissre.com/aia/SwissReRootCA2.crt > /usr/local/share/ca-certificates/swissre2.crt \
    && update-ca-certificates


# set working directory
WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

# install and cache app dependencies
COPY package.json /app/package.json
#RUN npm install
#RUN npm install -g @angular/cli@8.2.2

# add app
COPY . /app

# generate build

RUN ng build --output-path=dist

# base image
FROM nginx:1.16.0-alpine

#FROM node:latest AS build
# copy artifact build from the 'build environment'
COPY --from=build /app/dist /usr/share/nginx/html

#COPY --from=angular-built /usr/src/app/dist /usr/share/nginx/html

# expose port 8080
EXPOSE 8080

# run nginx
CMD ["nginx", "-g", "daemon off;"]
