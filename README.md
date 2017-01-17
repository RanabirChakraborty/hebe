# Central CI build scripts

This project includes all required scripts for builds on Central CI.

## Available scripts
* *common.sh* Common functions which can be sourced into a build script.
* *build-eap64-with-artifacts.sh* EAP 6.4 build script for creating artifacts for next step testing. This script does not run tests.
* *run-integration-tests-eap64.sh* EAP 6.4 integration tests script. This script reuses sources and Maven repo from the proposed build.
