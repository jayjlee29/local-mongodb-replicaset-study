#!/bin/sh

# init replica-set
mongo mongodb://mongo1:27017 /docker-entrypoint-initdb.d/js/replicaSet.js
sleep 10 | echo Sleeping
mongo mongodb://mongo2:27017 /docker-entrypoint-initdb.d/js/replicaSet.js
sleep 10 | echo Sleeping
mongo mongodb://mongo3:27017 /docker-entrypoint-initdb.d/js/replicaSet.js
sleep 10 | echo Sleeping


# create user in replica-set
mongo mongodb://mongo1:27017 /docker-entrypoint-initdb.d/js/createUser.js
sleep 10 | echo Sleeping
mongo mongodb://mongo2:27017 /docker-entrypoint-initdb.d/js/createUser.js
sleep 10 | echo Sleeping
mongo mongodb://mongo3:27017 /docker-entrypoint-initdb.d/js/createUser.js