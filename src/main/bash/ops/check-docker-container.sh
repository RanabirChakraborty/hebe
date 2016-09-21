#!/bin/bash
readonly DATE_FORMAT='+%s'
readonly SUSPICIOUS_RUNNING_TIME=${SUSPICIOUS_RUNNING_TIME:-'86395'}

today=$(date "${DATE_FORMAT}")
docker ps | sed -e '/^CONTAINER/d' -e 's/^.*tcp *//' | \
while
  read container_name
do
  createdAt=$(date -d "$(docker inspect "${container_name}" | grep StartedAt | sed -e 's/ //g' -e 's/"//g' | cut -f2- -d:  | sed -e 's/\.[0-9]*Z$//' -e 's/T/ /' )" "${DATE_FORMAT}")
  timeElapsed=$(expr ${today} - ${createdAt})
  if [ "${timeElapsed}" -gt "${SUSPICIOUS_RUNNING_TIME}" ]; then
    echo "Docker container $container_name has been running for more than 24 hours !"
    exit 1
  else
    echo "Docker container $container_name seems legit."
  fi
done
