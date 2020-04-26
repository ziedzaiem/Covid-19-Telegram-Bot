FROM node:12.16.2

LABEL maintainer="Zied ZAIEM <zaiem.zied@gmail.com>"

# Install Linux Dependencies for PDF Generation
RUN apt-get update -qq
RUN apt-get install -y -qq curl qrencode jq

# COPY files to container
RUN mkdir -p /bot
ADD . /bot
WORKDIR /bot

# Install NPM Dependencies
RUN npm install --silent


