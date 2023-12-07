#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

WHAT="${WHAT:-}"

INFRA_ROOT="$(cd "$(dirname "${BASH_SOURCE}")/.." && pwd -P)"

if [[ -z "${WHAT}" ]]; then
    pushd ${INFRA_ROOT}
    folders=(`find jobs/pipelines -name Jenkinsfile -print | sed "s|jobs/pipelines/||g" | sed "s|/Jenkinsfile||" | xargs -I"{}" dirname {} | uniq`)
    popd
else
    folders=(${WHAT})
fi
crudini --set /etc/jenkins_jobs/jenkins_jobs.ini jenkins url ${JENKINS_URI}
echo "Creating Folders: ${folders[@]}"
TMP_DIR=$(mktemp -d)
for folder in "${folders[@]}"
do
	IFS=/
        JOB_FOLDER=""
        file_name=""
	for i in $folder
	do
        if [[ "$folder" != "." ]]
        then
            unset IFS
            echo $i
            JOB_FOLDER+=$i
            file_name+=$i
            echo "{\"JOB_FOLDER\":${JOB_FOLDER}}" | jinja2 ${INFRA_ROOT}/hack/jjb_template_folder.jinja2 > ${TMP_DIR}/$file_name.yml
            JOB_FOLDER+='/'
            echo $JOB_FOLDER
            IFS=/
        fi
	done
	unset IFS
done

echo "jenkins-jobs --user ${JENKINS_USER} --password ${JENKINS_PASSWORD} update ${TMP_DIR}"
jenkins-jobs --user ${JENKINS_USER} --password ${JENKINS_PASSWORD} update ${TMP_DIR}

if [[ -z "${WHAT}" ]]; then
    pushd ${INFRA_ROOT}
    jenkinsfiles=(`find jobs/pipelines -name Jenkinsfile -print`)
    popd
else
    jenkinsfiles=(${WHAT})
fi

echo "Loading pipelines: ${jenkinsfiles[@]}"
TMP_DIR=$(mktemp -d)
for jenkinsfile in "${jenkinsfiles[@]}"
do
    JENKINS_FILE=${jenkinsfile}
    DIR_NAME="$(dirname "${jenkinsfile}")"
    JOB_NAME=$(dirname ${INFRA_ROOT}/${jenkinsfile}| xargs basename)
    JOB_FOLDER=$(echo $DIR_NAME | sed "s|jobs/pipelines/||g" | sed "s|/$JOB_NAME||g")
    if [[ "$JOB_FOLDER" = "$JOB_NAME" ]]; then JOB_PATH="${JOB_NAME}" ;else JOB_PATH="${JOB_FOLDER}/${JOB_NAME}"; fi
    echo "{\"JOB_NAME\":${JOB_PATH},\"JENKINS_FILE\":${JENKINS_FILE}}" | jinja2 ${INFRA_ROOT}/hack/jjb_template.jinja2 > ${TMP_DIR}/${JOB_NAME}.yml
done

jenkins-jobs --user ${JENKINS_USER} --password ${JENKINS_PASSWORD} update ${TMP_DIR}
