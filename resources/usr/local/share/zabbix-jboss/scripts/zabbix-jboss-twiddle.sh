#!/bin/bash

##############################################################################
#                                                                            #
#  NOTE ! NOTE ! NOTE ! NOTE ! NOTE ! NOTE ! NOTE ! NOTE !                   #
#                                                                            #
# JBoss's twiddle command takes JMX username/password from the command line. #
# It is insecure, because this data are displayed in the ps output,          #
# and any local user potentially can catch it.                               #
#                                                                            #
# YOU ARE WARNED. Use JMX authentication with caution here.                  #
#                                                                            #
##############################################################################

BASE_DIR=$(cd $(dirname $(which $0)); pwd)

CONF_DIR=/etc/zabbix/jboss

ENV_KEY=${ENV_KEY:-default}

. ${CONF_DIR}/zabbix-jboss-env.${ENV_KEY}.sh

JAVA_OPTS="-Dlog4j.configuration=file://${BASE_DIR}/zabbix-jboss-log4j.properties"

TWIDDLE_OPTS=

if [ -n "${JBOSS_JMX_HOST}" ]; then
    TWIDDLE_OPTS="${TWIDDLE_OPTS} --host=${JBOSS_JMX_HOST}"
fi

if [ -n "${JBOSS_JMX_PORT}" ]; then
    TWIDDLE_OPTS="${TWIDDLE_OPTS} --port=${JBOSS_JMX_PORT}"
fi

if [ -n "${JBOSS_JMX_USER}" ]; then
    LOGIN_FILE="${CONF_DIR}/zabbix-jboss-jmx.${ENV_KEY}.login"
    if [ ! -f "${LOGIN_FILE}" ]; then
        echo "JMX authorization requested, but no login file exists: ${LOGIN_FILE}" >&2
        exit 1
    fi
    JBOSS_JMX_PASSWORD=$(cat ${LOGIN_FILE} |
        grep -v '^[[:space:]]#' | grep -e "^[[:space:]]*${JBOSS_JMX_USER}[[:space:]]*=" |
        awk -F '[ =]' '{ printf "%s", $2 }')
    TWIDDLE_OPTS="${TWIDDLE_OPTS} --user=${JBOSS_JMX_USER} --password=${JBOSS_JMX_PASSWORD}"
fi

JAVA_OPTS="${JAVA_OPTS}" ${JBOSS_HOME}/bin/twiddle.sh ${TWIDDLE_OPTS} $*
