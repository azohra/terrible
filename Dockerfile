FROM ubuntu:14.04

LABEL maintainer="Azohra"

RUN mkdir /root/.ssh
RUN mkdir /root/.roles
RUN mkdir /go
RUN mkdir /plays
RUN mkdir /templates


ENV DEBIAN_FRONTEND="noninteractive"
ENV ANSIBLE_CONFIG="/root/.ansible.cfg"
ENV TERRAFORM_VERSION="0.11.1"
ENV GOROOT="/usr/bin/go"
ENV GOPATH="/go"
ENV TFROOT="/usr/bin/terraform"
ENV PATH="$GOPATH/bin:$GOROOT/bin:$TFROOT/bin:$PATH"

WORKDIR /tmp 

# Ansible
RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" | tee /etc/apt/sources.list.d/ansible.list 
RUN echo "deb-src http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/ansible.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7BB9C367
RUN apt-get update
RUN apt-get install -y wget ca-certificates unzip jq 
RUN apt-get install -y sshpass openssh-client openssl 
RUN apt-get install -y ansible python-pip git  
RUN rm -rf /var/lib/apt/lists/*  /etc/apt/sources.list.d/ansible.list
RUN pip install boto boto3
RUN ansible-galaxy install -p /root/.roles/ geerlingguy.docker
RUN ansible-galaxy install -p /root/.roles/ geerlingguy.pip

WORKDIR /
# Go
RUN wget https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz
RUN sudo tar -xvf go1.9.2.linux-amd64.tar.gz
RUN sudo mv go /usr/bin

WORKDIR /tmp 
# Terraform 
RUN go get -u github.com/squat/terraform-provider-vultr
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin
RUN go get -u github.com/squat/terraform-provider-vultr

# Cleanup
RUN rm -rf /tmp/* 

COPY config/ansible.cfg /root/.ansible.cfg
COPY config/.terraformrc /root/.terraformrc
COPY config/config /root/.ssh/config

COPY plays/create.yml /plays/create.yml
COPY plays/delete.yml /plays/delete.yml
COPY plays/get.yml /plays/get.yml
COPY templates/main.tf.j2 /templates/main.tf.j2

WORKDIR /


