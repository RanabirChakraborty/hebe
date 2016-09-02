#/bin/bash
#
# A sanity check script, to check that the docker image has been properly configured with the
# required mount for jobs to run smoothly within a container.
#

set +e

cat /etc/redhat-release

ARRAY=(/usr/lib/jvm/java-1.8.0 /usr/share/javazi-1.8 /opt/ /home/jboss/.ssh /home/jboss/.gitconfig /home/jboss/pull-request-processor/ i /home/jboss/.m2 /home/jboss/jenkins_workspace)

for volume in ${ARRAY[*]}
do
  echo "Checking if ${volume} is mounted:"
  ls -d ${volume}
done
