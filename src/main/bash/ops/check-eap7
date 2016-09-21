#!/bin/bash

readonly RPM_PACKAGE_NAME=${RPM_PACKAGE_NAME:-'eap7-wildfly'}

readonly FILES_MODIFIED=$(rpm -V "${RPM_PACKAGE_NAME}" | sed -e '/.....UG../d' -e '/.....U.../d' -e '/logging.properties/d' -e '/mgmt-groups.properties/d' -e '/mgmt-users.properties/d' | wc -l )
echo "Number of files modified from RPM ${RPM_PACKAGE_NAME}: ${FILES_MODIFIED}."
exit "${FILES_MODIFIED}"
