FROM fedora:latest

RUN dnf update -y
RUN dnf install -y gcc python3 python3-pip python3-devel java-17-openjdk java-17-openjdk-devel maven-openjdk17 kubernetes-client

RUN mkdir -p /etc/ansible /ansible /ansible/playbooks /ansible/collections /ansible/roles /ansible/tmp /ansible/galaxy_cache
WORKDIR /ansible/playbooks

#RUN set -x && \
#    \
#    echo "==> Adding hosts for convenience..."  && \
#    echo "[local]" >> /etc/ansible/hosts && \
#    echo "localhost" >> /etc/ansible/hosts

ENV JAVA_HOME /usr/lib/jvm/jre-17-openjdk/
ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/roles
ENV ANSIBLE_HOME /ansible
ENV PYTHONPATH /ansible/lib
ENV ANSIBLE_CONFIG /ansible/ansible.cfg
ENV COLLECTIONS_PATH /ansible/collections
ENV PATH /ansible/bin:$PATH

COPY playbooks/*.yml /ansible/playbooks/
COPY ansible.cfg /ansible/

RUN pip3 install --upgrade pip
RUN pip3 install ansible ansible-runner ansible-rulebook 
RUN ansible-galaxy collection install -p $COLLECTIONS_PATH ansible.eda 
RUN ansible-galaxy collection install -p $COLLECTIONS_PATH kubernetes.core

RUN dnf remove -y gcc maven-openjdk17 java-17-openjdk-devel python3-devel

ENTRYPOINT ["ansible-rulebook", "-r", "webhook.yml", "-i", "inventory.yml", "--verbose"]
