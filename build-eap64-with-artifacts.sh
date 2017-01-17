#!/bin/bash
#
# Build Wildlfy/EAP
#

source common.sh

# Allow to override the following values:
readonly EAP_LOCAL_MAVEN_REPO_FOLDER=${EAP_LOCAL_MAVEN_REPO_FOLDER:-eap-maven-local-repository}
readonly EAP_LOCAL_MAVEN_REPO=${EAP_LOCAL_MAVEN_REPO:-${WORKSPACE}/${EAP_LOCAL_MAVEN_REPO_FOLDER}}
readonly MEMORY_SETTINGS=${MEMORY_SETTINGS:-'-Xmx1024m -Xms512m -XX:MaxPermSize=256m'}
readonly SRC_LOCATION_FOLDER=${SRC_LOCATION_FOLDER:-eap-sources}
readonly SRC_LOCATION=${SRC_LOCATION:-${WORKSPACE}/${SRC_LOCATION_FOLDER}}

# and will reuse MAVEN_OPTS and TESTSUITE_OPTS if defined.
mkdir -p "${EAP_LOCAL_MAVEN_REPO}"
export MAVEN_OPTS="${MAVEN_OPTS} ${MEMORY_SETTINGS}"
export MAVEN_OPTS="${MAVEN_OPTS} -Dmaven.repo.local=${EAP_LOCAL_MAVEN_REPO}"

set_ip_addresses
trap "kill_jboss" EXIT INT QUIT TERM
kill_jboss

echo "Using first node address $MYTESTIP_1"
echo "Using second node address $MYTESTIP_2"
echo "Using multicast address $MCAST_ADDR"

# Remove home variable
unset JBOSS_HOME

cd ${SRC_LOCATION}
echo "Starting build..."
./build.sh clean install -fae -B -DskipTests -Dts.noSmoke -DallTests -Prelease
kill_jboss

# Remove the compiled EAP to ensure application of productized bits 
# find -type d -name "jbossas*" ! -path "./build/target/*" | grep target/jbossas | xargs rm -rf || true
# find -type d -name "jboss-as*" ! -path "./build/target/*" | grep target/jboss-as | xargs rm -rf || true
# find -type d -name "jboss-eap*" ! -path "./build/target/*" | grep target/jboss-eap | xargs rm -rf || true
# find -type d -name "jbosseap*" ! -path "./build/target/*" | grep target/jbosseap | xargs rm -rf || true

# Workaround for Bug 1160227 - SAMLMetadataTestCase fails once -Dnode0 and -Dnode1 are used
#rm testsuite/integration/picketlink/target/test-classes/org/wildfly/test/integration/security/picketlink/federation/*-metadata*.xml

# Adjust Surefire memory settings (due to failures in JDK6)
echo "Adjusted memory settings"
sed -i 's/-Duser.language=en<\/argLine>/-Duser.language=en -XX:MaxPermSize=256m<\/argLine>/g' pom.xml

echo "Finished build"
cd ${WORKSPACE}

# Make all artifacts
# Maven artifacts
# find ${EAP_LOCAL_MAVEN_REPO} -type f -name '*.repositories' -exec rm -f {} \;
# find ${EAP_LOCAL_MAVEN_REPO} -type f -name '*.lastUpdated' -exec rm -f {} \;
zip -qr jboss-eap-6.4-maven-artifacts.zip ${EAP_LOCAL_MAVEN_REPO_FOLDER}

# Server and sources
echo "Copying distribution artifacts to workspace"
#mv -v ${SRC_LOCATION}/dist/target/jboss-eap-6.4.zip ${WORKSPACE}/
#mv -v ${SRC_LOCATION}/dist/target/jboss-eap-6.4-src.zip ${WORKSPACE}/
zip -qr jboss-eap-6.4-src-prepared.zip ${SRC_LOCATION_FOLDER}

