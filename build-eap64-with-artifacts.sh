#!/bin/bash
#
# Build Wildlfy/EAP
#


source common.sh

# Allow to override the following values:
readonly EAP_LOCAL_MAVEN_REPO_FOLDER=${EAP_LOCAL_MAVEN_REPO_FOLDER:-eap-maven-local-repository}
readonly EAP_LOCAL_MAVEN_REPO=${EAP_LOCAL_MAVEN_REPO:-${WORKSPACE}/${EAP_LOCAL_MAVEN_REPO_FOLDER}}
readonly MEMORY_SETTINGS=${MEMORY_SETTINGS:-'-Xmx1024m -Xms512m -XX:MaxPermSize=256m'}
readonly SRC_LOCATION=${SRC_LOCATION:-${WORKSPACE}/eap-sources/}

# and will reuse MAVEN_OPTS and TESTSUITE_OPTS if defined.
mkdir -p "${EAP_LOCAL_MAVEN_REPO}"
export MAVEN_OPTS="${MAVEN_OPTS} ${MEMORY_SETTINGS}"
export MAVEN_OPTS="${MAVEN_OPTS} -Dmaven.repo.local=${EAP_LOCAL_MAVEN_REPO}"

set_ip_addresses
echo "Using first node address $MYTESTIP_1"
echo "Using second node address $MYTESTIP_2"
echo "Using multicast address $MCAST_ADDR"

cd ${SRC_LOCATION}
echo "Starting build..."
mvn clean install -fae -B -DskipTests -Dts.noSmoke -DallTests -Prelease
echo "Finished build"
cd ${WORKSPACE}

# Make all artifacts
# Maven artifacts
find ${EAP_LOCAL_MAVEN_REPO} -type f -name '*.repositories' -exec rm -f {} \;
find ${EAP_LOCAL_MAVEN_REPO} -type f -name '*.lastUpdated' -exec rm -f {} \;
zip -qr jboss-eap-6.4-maven-artifacts.zip ${EAP_LOCAL_MAVEN_REPO_FOLDER}

# Server and sources
echo "Copying distribution artifacts to workspace"
mv -v ${SRC_LOCATION}/dist/target/jboss-eap-6.4.zip ${WORKSPACE}/
mv -v ${SRC_LOCATION}/dist/target/jboss-eap-6.4-src.zip ${WORKSPACE}/

