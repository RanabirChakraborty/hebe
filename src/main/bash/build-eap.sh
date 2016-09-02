#!/bin/bash
#
# Build Wildlfy/EAP
#


# Allow to override the following values:
readonly LOCAL_REPO_DIR=${LOCAL_REPO_DIR:-"${WORKSPACE}/maven-local-repository"}
readonly MEMORY_SETTINGS=${MEMORY_SETTINGS:-'-Xmx1024m -Xms512m -XX:MaxPermSize=256m'}
# and will reuse MAVEN_OPTS and TESTSUITE_OPTS if defined.

if [ ! -z "${EXECUTOR_NUMBER}" ]; then
  echo -n "Job run by executor ID ${EXECUTOR_NUMBER} "
fi

if [ ! -z "${WORKSPACE}" ]; then
  echo -n "inside workspace: ${WORKSPACE}"
fi
echo '.'

. /opt/jboss-set-ci-scripts/common_bash.sh
set_ip_addresses
trap "kill_jboss" EXIT INT QUIT TERM
kill_jboss

which java
java -version

which mvn
mvn -version

mkdir -p "${LOCAL_REPO_DIR}"
export MAVEN_OPTS="${MAVEN_OPTS} ${MEMORY_SETTINGS}"
export MAVEN_OPTS="${MAVEN_OPTS} -Dmaven.repo.local=${LOCAL_REPO_DIR}"

unset JBOSS_HOME
./build.sh clean install -B
kill_jboss
