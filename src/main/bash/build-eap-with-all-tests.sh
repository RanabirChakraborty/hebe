#!/bin/bash
#
# Build project and run all tests
#
# Allow to override the following values:
readonly LOCAL_REPO_DIR=${LOCAL_REPO_DIR:-"${WORKSPACE}/maven-local-repository"}
readonly OLD_RELEASES_FOLDER=${OLD_RELEASES_FOLDER:-'/opt/old-as-releases'}
readonly MEMORY_SETTINGS=${MEMORY_SETTINGS:-'-Xmx1024m -Xms512m -XX:MaxPermSize=256m'}
readonly SUREFIRE_FORKED_PROCESS_TIMEOUT=${SUREFIRE_FORKED_PROCESS_TIMEOUT:-'90000'}
readonly MAVEN_IGNORE_TEST_FAILURE=${MAVEN_IGNORE_TEST_FAILURE:-'true'}
readonly NODE0_ADDR=${NODE0_ADDR:-'127.0.0.1'}
readonly NODE1_ADDR=${NODE1_ADDR:-'127.0.0.1'}
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

export MAVEN_OPTS="${MAVEN_OPTS} ${MEMORY_SETTINGS}"
export TESTSUITE_OPTS="${TESTSUITE_OPTS} -Dnode0=${NODE0_ADDR} -Dnode1=${NODE1_ADDR} -DudpGroup=${MCAST_ADDR}"
export TESTSUITE_OPTS="${TESTSUITE_OPTS} -Dsurefire.forked.process.timeout=${SUREFIRE_FORKED_PROCESS_TIMEOUT}"
export TESTSUITE_OPTS="${TESTSUITE_OPTS} -Dskip-download-sources -U -B"
export TESTSUITE_OPTS="${TESTSUITE_OPTS} -Djboss.test.mixed.domain.dir=${OLD_RELEASES_FOLDER}"
export TESTSUITE_OPTS="${TESTSUITE_OPTS} -Dmaven.test.failure.ignore=${MAVEN_IGNORE_TEST_FAILURE}"

./build.sh clean install -DallTests ${TESTSUITE_OPTS}
