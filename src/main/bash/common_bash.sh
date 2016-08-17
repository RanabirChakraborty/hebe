#!/bin/bash
# Source this file, don't execute it
#

basedir=${BASEDIR:-"/opt/scripts"}
common_variables="${basedir}/common.variables"

for function in ${basedir}/function.d/*
do
  . "${function}"
done
