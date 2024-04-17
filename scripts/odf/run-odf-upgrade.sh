#!/bin/bash
##
## This scripts runs ODF upgrade script from the ocs-upi-kvm in the remote bastion node
##
. ${WORKSPACE}/env_vars.sh; echo "Upgrading ODF to ${UPGRADE_OCS_VERSION}"; cd ${WORKSPACE}/ocs-upi-kvm/scripts; ./upgrade-ocs-ci.sh > upgrade-ocs-ci.log ;
odf_csv=`oc get csv -n openshift-storage |grep odf-operator | awk {'print $1'}`; oc get csv $odf_csv -n openshift-storage -o yaml |grep full_version |awk {'print $2'} | tail -n 1 > ${WORKSPACE}/odf-full-build.txt
