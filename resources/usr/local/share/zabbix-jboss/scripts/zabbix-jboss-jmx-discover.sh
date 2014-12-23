#!/bin/bash -e

# Note: -e option causes immediate exit in the case a command fails

BASE_DIR=$(cd $(dirname $(which $0)); pwd)

ITEMS=$(${BASE_DIR}/zabbix-jboss-twiddle.sh query $1)

# Twiddle's query command returns the list of objects found, one object per a line like this one:
#   jboss.web:type=Manager,path=/invoker,host=localhost
# We converts it in the JSON format according to Zabbix requirements:
# 1st sed converts each line into the following form:
#   {"{#JMXDOMAIN}":"jboss.web","{#TYPE}":"Manager","{#PATH}":"\/invoker","{#HOST}":"localhost"}
# 2nd sed appends a comma at the end of each line except for the last one
# (see http://stackoverflow.com/questions/1251999/sed-how-can-i-replace-a-newline-n).

echo '{"data":['

echo "${ITEMS}" |
    sed -e 's:\([\\"/]\):\\\1:g' -e 's/^\([^:]*\):/jmxdomain=\1,/' -e 's/\([^=]*\)=\([^,]*\)\(,*\)/"{#\U\1\E}":"\2"\3/g' -e 's/^\(.*\)$/{\1}/' |
    sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/,\n/g'

echo ']}'
