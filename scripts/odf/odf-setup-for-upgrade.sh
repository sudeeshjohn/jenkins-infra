#!/bin/bash
set -x
if [ -d "${WORKSPACE}/ocs-upi-kvm" ]; then rm -rf ${WORKSPACE}/ocs-upi-kvm; fi
if [ "${UPGRADE_OCS_VERSION}" = "4.16" ]; then
    git clone https://github.com/ocp-power-automation/ocs-upi-kvm.git ${WORKSPACE}/ocs-upi-kvm
elif [ "${UPGRADE_OCS_VERSION}" = "4.14" ] || [ "${UPGRADE_OCS_VERSION}" = "4.13" ]  || [ "${UPGRADE_OCS_VERSION}" = "4.15" ] ; then
    git clone -b v"${UPGRADE_OCS_VERSION}".0 https://github.com/ocp-power-automation/ocs-upi-kvm.git ${WORKSPACE}/ocs-upi-kvm
else
    git clone -b v4.12.0 https://github.com/ocp-power-automation/ocs-upi-kvm.git ${WORKSPACE}/ocs-upi-kvm
fi
cd ${WORKSPACE}/ocs-upi-kvm; git submodule update --init;
scp -i ${WORKSPACE}/deploy/id_rsa -o 'StrictHostKeyChecking=no' root@${BASTION_IP}:/root/openstack-upi/metadata.json ${WORKSPACE}/
chmod 0755 ${WORKSPACE}/env_vars.sh; . ${WORKSPACE}/env_vars.sh; cd ${WORKSPACE}/ocs-upi-kvm/scripts/helper; /bin/bash ./kustomize.sh > kustomize.log 2>&1
[ "$ENABLE_VAULT" = "true" ] && cd ${WORKSPACE}/ocs-upi-kvm/scripts/helper && /bin/bash ./vault-setup.sh > vault-setup.log 2>&1
. ${WORKSPACE}/env_vars.sh; cd ${WORKSPACE}/ocs-upi-kvm/scripts; /bin/bash ./setup-ocs-ci.sh > setup-ocs-ci.log 2>&1
