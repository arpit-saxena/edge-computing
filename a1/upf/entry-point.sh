#!/bin/bash

echo hello world

./set-dest.sh ${ROUTE_DEST}

exec tail -f /dev/null
