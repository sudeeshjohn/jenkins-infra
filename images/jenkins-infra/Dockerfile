FROM ubuntu:22.04

ENV JENKINS_URI localhost
ENV JENKINS_USER admin
ENV JENKINS_PASSWORD passw0rd
ENV CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
RUN mkdir -p /etc/ssl/certs/
RUN chmod 755 /etc/ssl/certs/

RUN apt-get update -y && apt-get install -y curl python3 python3-pip libyaml-dev git crudini python3-dev python3-setuptools libffi-dev libssl-dev  \
    && python3 -m pip install --upgrade  pip \
    && pip3 install typing \
    && pip3 install stevedore \
#    && pip3 install pyOpenSSL \
    && git clone https://git.openstack.org/openstack-infra/jenkins-job-builder \
    && cd jenkins-job-builder && pip3 install -r requirements.txt && python3 setup.py install \
    && pip3 install jinja2-cli 

COPY ca-certificates.crt /etc/ssl/certs/ca-certificates.crt 
COPY jenkins_jobs.ini /etc/jenkins_jobs/
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
