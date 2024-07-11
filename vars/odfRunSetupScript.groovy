def call(){
    script {
        ansiColor('xterm') {
            echo ""
        }
        try {
            sh '''
               cp /etc/resolv.conf.tmp /etc/resolv.conf.modified || true
               sed -i "1s/^/nameserver $BASTION_IP\\n/" /etc/resolv.conf.modified || true
               cp /etc/resolv.conf.modified /etc/resolv.conf || true
               cp -rf ${WORKSPACE}/deploy/id_rsa* ~/.ssh/
               cp ${WORKSPACE}/deploy/data/pull-secret.txt ${WORKSPACE}/
               cp ${WORKSPACE}/deploy/data/auth.yaml ${WORKSPACE}/
               oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=${WORKSPACE}/pull-secret.txt;
               echo "export PLATFORM=${PLATFORM}" > env_vars.sh
               echo "export OCP_VERSION=${OCP_RELEASE}" >> env_vars.sh
               echo "export OCS_VERSION=${ODF_VERSION}" >> env_vars.sh
               echo "export PVS_API_KEY=${IBMCLOUD_API_KEY}" >> env_vars.sh
               echo "export RHID_USERNAME=${REDHAT_USERNAME}" >> env_vars.sh
               echo "export RHID_PASSWORD=${REDHAT_PASSWORD}" >> env_vars.sh
               echo "export PVS_SERVICE_INSTANCE_ID=${SERVICE_INSTANCE_ID}" >> env_vars.sh
               echo "export TIER_TEST=${TIER_TEST}" >> env_vars.sh
               echo "export VAULT_SUPPORT=${ENABLE_VAULT}" >> env_vars.sh
               echo "export FIPS_ENABLEMENT=${ENABLE_FIPS}" >> env_vars.sh
               [ ! -z "$UPGRADE_OCS_VERSION" ] && echo "export UPGRADE_OCS_VERSION=${UPGRADE_OCS_VERSION}" >> env_vars.sh
               [ ! -z "$UPGRADE_OCS_REGISTRY" ] && echo "export UPGRADE_OCS_REGISTRY=${UPGRADE_OCS_REGISTRY}" >> env_vars.sh
               [ ! -z "$OCS_REGISTRY_IMAGE" ] && echo "export OCS_REGISTRY_IMAGE=${OCS_REGISTRY_IMAGE}" >> env_vars.sh
               [ ! -z "$RERUN_TIER_TEST" ] && echo "export RERUN_TIER_TEST=${RERUN_TIER_TEST}" >> env_vars.sh
               if [ "${ODF_VERSION}" = "4.16" ]; then
                   git clone https://github.com/sudeeshjohn/ocs-upi-kvm.git ${WORKSPACE}/ocs-upi-kvm
               elif [ "${ODF_VERSION}" = "4.14" ] || [ "${ODF_VERSION}" = "4.13" ]  || [ "${ODF_VERSION}" = "4.15" ] ; then
                   git clone -b v"${ODF_VERSION}".0 https://github.com/ocp-power-automation/ocs-upi-kvm.git ${WORKSPACE}/ocs-upi-kvm
               else
                   git clone -b v4.12.0 https://github.com/ocp-power-automation/ocs-upi-kvm.git ${WORKSPACE}/ocs-upi-kvm
               fi
               cd ${WORKSPACE}/ocs-upi-kvm; git submodule update --init;
               scp -i ${WORKSPACE}/deploy/id_rsa -o 'StrictHostKeyChecking=no' root@${BASTION_IP}:/root/openstack-upi/metadata.json ${WORKSPACE}/
               chmod 0755 ${WORKSPACE}/env_vars.sh; . ${WORKSPACE}/env_vars.sh; cd ${WORKSPACE}/ocs-upi-kvm/scripts/helper; /bin/bash ./kustomize.sh > kustomize.log 2>&1
               [ "$ENABLE_VAULT" = "true" ] && cd ${WORKSPACE}/ocs-upi-kvm/scripts/helper && /bin/bash ./vault-setup.sh > vault-setup.log 2>&1
               . ${WORKSPACE}/env_vars.sh; cd ${WORKSPACE}/ocs-upi-kvm/scripts; /bin/bash ./setup-ocs-ci.sh > setup-ocs-ci.log 2>&1
            '''
        }
        catch (err) {
            echo 'Error ! Setup script failed!'
            env.FAILED_STAGE=env.STAGE_NAME
            throw err
        }
    }
}
