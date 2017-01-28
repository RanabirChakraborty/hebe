#!/bin/bash
# Common functions for builds

function set_ip_addresses() {
   DEFAULT_INTERFACE=`netstat -rn | awk '{ if ($1 == "0.0.0.0") print $NF}'`
   CHECKED_IP_ADDRESS=$(/sbin/ifconfig $DEFAULT_INTERFACE | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
   export MYTESTIP_1=$CHECKED_IP_ADDRESS
   export MYTESTIP_2=127.0.0.1
   #export MCAST_ADDR=$(netstat -gn | grep "$DEFAULT_INTERFACE" | awk '/[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/ {print $3}' | sort)
   export MCAST_ADDR=$(echo ${CHECKED_IP_ADDRESS} | sed 's/^[0-9]*\./239./')
}

function kill_jboss {
  local process_identifier='jboss-modules.jar'
  # fetch PID of running services to be sure this script will NOT shut'em down by mistake
  jboss_eap_7_pid=$(cat /var/run/jboss-eap/jboss-eap.pid)
  jbossas_pid=$(cat /var/run/jbossas-standalone)
  
  if [ -z "$jboss_eap_7_pid" ]; then
    jboss_eap_7_pid="N/A"
  fi
  if [ -z "$jbossas_pid" ]; then
    jbossas_pid="N/A"	
  fi

 (
  if [[ $(uname -s) == 'Linux' ]]; then
   local PS='ps -eaf --columns 20000 | grep "${process_identifier}" | grep -v "${jboss_eap_7_pid}" | grep -v "${jbossas_pid}" | grep -v -w grep | awk '\''{ print $2; }'\'
   jboss_pid=`eval ${PS}`
   echo ${jboss_pid} >> /tmp/kill_jboss.log
   if [ -n "$jboss_pid" ]; then
    echo "Found PID: ${jboss_pid}"
    eval "${PS}" | xargs kill -3
    sleep 1
    eval "${PS}" | xargs kill
    sleep 10
    eval "${PS}" | xargs kill -9
   fi
  elif lsof -i TCP:8080 &> /dev/null; then
    local LSOF='lsof -t -i TCP:8080,8443,1099,1098,4444,4445,1093,1701'
    kill -3 $($LSOF)
    sleep 1
    kill $($LSOF)
    sleep 10
    kill -9 $($LSOF)
  elif netstat -an | findstr LISTENING | findstr :8080 ; then
    tmp_file=$(mktemp)
    netstat -aon | findstr LISTENING | findstr :8080 > "${tmp_file}"
    cmd \/C FOR \/F "usebackq tokens=5" %i in \(${tmp_file}\) do taskkill /F /T /PID %i
    rm -f "${tmp_file}"
  elif jps &>/dev/null; then
    local PS='jps | grep -e "${process_identifier}" | grep -v -w grep | awk '\''{ print $1; }'\'

    case $(uname) in
      CYGWIN*)
        jps | grep -e "${process_identifier}" | grep -v -w grep | awk '{print $1}'
        for i in $(jps | grep "${process_identifier}" | grep -v -w grep | awk '{print $1}'); do
           taskkill /F /T /PID $i;
        done
        ;;
      *)
        eval "${PS}" | xargs kill -3
        sleep 1
        eval "${PS}" | xargs kill
        sleep 10
        eval "${PS}" | xargs kill -9
        ;;
    esac

  else
    echo Not yet supported on $(uname -s) UNIX favour without working lsof.
    return 1
  fi
 ) || return 0
}
