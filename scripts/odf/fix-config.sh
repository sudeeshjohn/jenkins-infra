#!/bin/bash
##
## This scripts updates the env_vars.sh and ocs-ci-conf.yaml after ODF upgrade
##
. ${WORKSPACE}/env_vars.sh; export OCS_VERSION=`echo ${UPGRADE_OCS_VERSION} | cut -d "." -f 1-2`; export OCS_CSV_CHANNEL=stable-$OCS_VERSION; yq -y -i ".DEPLOYMENT.ocs_csv_channel |= env.OCS_CSV_CHANNEL" ${WORKSPACE}/ocs-ci-conf.yaml; yq -y -i ".ENV_DATA.ocs_version |= env.OCS_VERSION" ${WORKSPACE}/ocs-ci-conf.yaml ;  sed -i "s|log_dir:.*$|log_dir: ${WORKSPACE}/logs-ocs-ci/"$OCS_VERSION"|g"  ${WORKSPACE}/ocs-ci-conf.yaml
cat ${WORKSPACE}/ocs-ci-conf.yaml
. ${WORKSPACE}/env_vars.sh; CURRENT_OCS_VERSION=`echo ${UPGRADE_OCS_VERSION} | cut -d "." -f 1-2`; sed -i "s|export OCS_VERSION=.*$|export OCS_VERSION=${CURRENT_OCS_VERSION}|g" ${WORKSPACE}/nv_vars.sh
cat ${WORKSPACE}/env_vars.sh