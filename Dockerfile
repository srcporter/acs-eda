FROM fedora:latest

ENV OC_VERSION 4.14

RUN dnf update -y
RUN dnf install -y gcc python3 python3-pip python3-devel java-17-openjdk java-17-openjdk-devel maven-openjdk17
RUN export JAVA_HOME=/usr/lib/jvm/jre-17-openjdk/
ENV JAVA_HOME /usr/lib/jvm/jre-17-openjdk/

RUN mkdir -p /etc/ansible /ansible /ansible/playbooks /ansible/collections /ansible/roles /.ansible/galaxy_cache /root/.ansible/galaxy_cache
WORKDIR /ansible/playbooks

RUN set -x && \
    \
    echo "==> Adding hosts for convenience..."  && \
    echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost" >> /etc/ansible/hosts


RUN mkdir /tools && \
    curl -sLo /tmp/oc.tar.gz https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable-$(echo $OC_VERSION)/openshift-client-linux.tar.gz &&\
    tar xzvf /tmp/oc.tar.gz -C /bin &&\
    rm -rf /tmp/oc.tar.gz


ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PYTHONPATH /ansible/lib
ENV PATH /ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /ansible/library
ENV ANSIBLE_CONFIG /ansible/ansible.cfg
ENV COLLECTIONS_PATH /ansible/collections


COPY playbooks/*.yml /ansible/playbooks/
COPY ansible.cfg /ansible

RUN pip3 install --upgrade pip
RUN pip3 install ansible ansible-runner ansible-rulebook
# RUN ansible-galaxy install -p $COLLECTIONS_PATH -r requirements.yml
RUN ansible-galaxy collection install -p $COLLECTIONS_PATH ansible.eda 
RUN ansible-galaxy collection install -p $COLLECTIONS_PATH community.kubernetes 

ENTRYPOINT ["ansible-rulebook", "-r", "webhook.yml", "-i", "inventory.yml", "--verbose"]
