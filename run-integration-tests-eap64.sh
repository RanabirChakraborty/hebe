#!/bin/bash
#
# Run Wildlfy/EAP integration tests
#

source common.sh

# Remove home variable
unset JBOSS_HOME

# Allow to override the following values:
readonly EAP_LOCAL_MAVEN_REPO_FOLDER=${EAP_LOCAL_MAVEN_REPO_FOLDER:-eap-maven-local-repository}
readonly BUILD_ARTIFACTS_FOLDER=${BUILD_ARTIFACTS_FOLDER:-${WORKSPACE}/build-artifacts}
readonly EAP_LOCAL_MAVEN_REPO=${EAP_LOCAL_MAVEN_REPO:-${WORKSPACE}/${EAP_LOCAL_MAVEN_REPO_FOLDER}}
readonly MEMORY_SETTINGS=${MEMORY_SETTINGS:-'-Xmx1024m -Xms512m -XX:MaxPermSize=256m'}
readonly SRC_LOCATION=${SRC_LOCATION:-${WORKSPACE}/eap-sources/}
readonly EAP_DIST_LOCATION=${EAP_DIST_LOCATION:-${WORKSPACE}/jboss-eap-6.4/}
readonly SUREFIRE_FORKED_PROCESS_TIMEOUT=${SUREFIRE_FORKED_PROCESS_TIMEOUT:-'90000'}
readonly MAVEN_IGNORE_TEST_FAILURE=${MAVEN_IGNORE_TEST_FAILURE:-'false'}
readonly OLD_RELEASES_FOLDER=${OLD_RELEASES_FOLDER:-/opt/old-as-releases}
# set maven home
export MAVEN_HOME="${SRC_LOCATION}/tools/maven"

# and will reuse MAVEN_OPTS and TESTSUITE_OPTS if defined.
export MAVEN_OPTS="${MAVEN_OPTS} ${MEMORY_SETTINGS}"
export MAVEN_OPTS="${MAVEN_OPTS} -Dmaven.repo.local=${EAP_LOCAL_MAVEN_REPO} "

# Prepare sources from previously built artifacts
# uzip previous artifacts
cd ${BUILD_ARTIFACTS_FOLDER}
unzip jboss-eap-6.4-src-prepared.zip
unzip jboss-eap-6.4-maven-artifacts.zip
unzip jboss-eap-6.4.zip
mkdir -p "${EAP_LOCAL_MAVEN_REPO}"
mkdir -p "${SRC_LOCATION}"
mkdir -p "${EAP_DIST_LOCATION}"
mv eap-sources/* ${SRC_LOCATION}
mv ${EAP_LOCAL_MAVEN_REPO_FOLDER}/* ${EAP_LOCAL_MAVEN_REPO}
mv jboss-eap-6.4/* ${EAP_DIST_LOCATION}

# Set testing IPs
set_ip_addresses
trap "kill_jboss" EXIT INT QUIT TERM
kill_jboss

echo "Using first node address $MYTESTIP_1"
echo "Using second node address $MYTESTIP_2"
echo "Using multicast address $MCAST_ADDR"

export TESTSUITE_OPTS="${TESTSUITE_OPTS} -fae"
export TESTSUITE_OPTS="${TESTSUITE_OPTS} -Dskip-download-sources -B -Dsurefire.forked.process.timeout=${SUREFIRE_FORKED_PROCESS_TIMEOUT}"
export TESTSUITE_OPTS="${TESTSUITE_OPTS} -Dnode0=${MYTESTIP_1} -Dnode1=${MYTESTIP_2} -Dmcast=${MCAST_ADDR}"
export TESTSUITE_OPTS="${TESTSUITE_OPTS} -Djboss.test.mixed.domain.dir=${OLD_RELEASES_FOLDER}"
export TESTSUITE_OPTS="${TESTSUITE_OPTS} -Dmaven.test.failure.ignore=${MAVEN_IGNORE_TEST_FAILURE}"
#export TESTSUITE_OPTS="${TESTSUITE_OPTS} -Djboss.dist=${EAP_DIST_LOCATION}"

cd ${SRC_LOCATION}

echo "Starting testing..."
echo "JAVA_HOME=$JAVA_HOME"
echo "MAVEN_HOME=$MAVEN_HOME"
echo "MAVEN_OPTS=$MAVEN_OPTS"

# Build and run unit tests
./build.sh clean install -fae -B -Dts.noSmoke
kill_jboss

# Remove the compiled EAP to ensure application of productized bits 
#find -type d -name "jbossas*" ! -path "./build/target/*" | grep target/jbossas | xargs rm -rf || true
#find -type d -name "jboss-as*" ! -path "./build/target/*" | grep target/jboss-as | xargs rm -rf || true
#find -type d -name "jboss-eap*" ! -path "./build/target/*" | grep target/jboss-eap | xargs rm -rf || true
#find -type d -name "jbosseap*" ! -path "./build/target/*" | grep target/jbosseap | xargs rm -rf || true

# Clean up testsuite
cd testsuite
../tools/maven/bin/mvn clean
cd ..

#./integration-tests.sh -DallTests ${TESTSUITE_OPTS}
./integration-tests.sh test -Dts.integration -Ddomain.module -Dcompat.module ${TESTSUITE_OPTS}
kill_jboss

echo "Finished testing"

