#!/bin/bah

. /opt/jboss-set-ci-scripts/common_bash.sh
set_ip_addresses
trap "kill_jboss" EXIT INT QUIT TERM
kill_jboss

which java
java -version

#readonly LOCAL_REPO_DIR=${LOCAL_REPO_DIR:-"${WORKSPACE}/maven-local-repository"}

export MAVEN_OPTS="-Xmx1024m -Xms512m -XX:MaxPermSize=256m"
TESTSUITE_OPTS="-Dnode0=127.0.0.1 -Dnode1=127.0.0.1 -DudpGroup=$MCAST_ADDR"
TESTSUITE_OPTS="$TESTSUITE_OPTS -Dsurefire.forked.process.timeout=90000"
TESTSUITE_OPTS="$TESTSUITE_OPTS -Dskip-download-sources -U -B"
TESTSUITE_OPTS="$TESTSUITE_OPTS -Djboss.test.mixed.domain.dir=/opt/old-as-releases"
TESTSUITE_OPTS="$TESTSUITE_OPTS -Dmaven.test.failure.ignore=true"

# export MAVEN_OPTS="$MAVEN_OPTS -Dmaven.repo.local=${LOCAL_REPO_DIR}"

./build.sh clean install -DallTests $TESTSUITE_OPTS

cd build/target
export AS_NAME=$(ls | grep jboss-as)
zip -rq "${AS_NAME}.zip" "${AS_NAME}"
