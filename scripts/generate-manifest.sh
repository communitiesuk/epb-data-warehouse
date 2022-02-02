#!/usr/bin/env bash

#define parameters which are passed in.
APPLICATION_NAME=$1  # e.g. dluhc-epb-something-api-integration
STAGE=$2 # i.e. [integration, staging, production]

case "$STAGE" in
 production) MEMORY="2G" ;;
 *) MEMORY="1G" ;;
esac

cat << EOF
---
applications:
  - name: $APPLICATION_NAME
    command: make run
    memory: $MEMORY
    buildpacks:
      - node_buildpack
      - ruby_buildpack
    no-route: true
    health-check-type: process
    services:
      - dluhc-epb-data-warehouse-db-$STAGE
      - dluhc-epb-redis-data-warehouse-$STAGE
EOF
