#!/bin/bash
set -ex

sed -i "s/AABBccddeeff112233gghh/$api_token/g" ~/.ansible.cfg

#sudo yum -y install git
#curl https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -o /tmp/epel-release-latest-7.noarch.rpm
#sudo yum install -y /tmp/epel-release-latest-7.noarch.rpm
#sudo yum install -y ansible
#sudo yum remove -y epel-release
#rm /tmp/epel-release-latest-7.noarch.rpm

sudo yum -y install @development
export PYVENV_PROJDIR="/tmp/ansible_venv"
mkdir -p $PYVENV_PROJDIR
/usr/libexec/platform-python -m venv $PYVENV_PROJDIR
source $PYVENV_PROJDIR/bin/activate
python3 -m pip install --upgrade pip setuptools
python3 -m pip install wheel
python3 -m pip install \
    ansible-core==2.11.7 \
    awscli==1.22.49 \
    boto3==1.20.49 \
    boto==2.49.0 \
    invoke==1.6.0 \
    jmespath==0.10.0 \
    netaddr==0.8.0 \
    passlib==1.7.4 \
    python_terraform==0.10.1 \
    pywinrm==0.4.2 \
    requests==2.27.1 \
    requests-credssp==2.0.0 \
    tox==3.22.0 \
    yamllint==1.26.3
ansible-galaxy collection install -r /tmp/requirements.yml --force
history -c
