#!/bin/bash

docker-compose down && git pull origin master && docker-compose build && docker-compose up -d

exit 0