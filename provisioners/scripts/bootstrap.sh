#!/bin/bash
set -ex

sed -i "s/AABBccddeeff112233gghh/$api_token/g" ~/.ansible.cfg
curl -L $satellite_manifest -o /tmp/manifest.zip

#sudo yum -y install git
#curl https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -o /tmp/epel-release-latest-7.noarch.rpm
#sudo yum install -y /tmp/epel-release-latest-7.noarch.rpm
#sudo yum install -y ansible
#sudo yum remove -y epel-release
#rm /tmp/epel-release-latest-7.noarch.rpm

sudo yum-config-manager --enable rhel-7-server-rhui-optional-rpms
sudo yum-config-manager --enable rhel-server-rhui-rhscl-7-rpms
sudo yum -y install @development
sudo yum -y install rh-python36
#scl enable rh-python36 bash ### doesn't work within a bash script
source /opt/rh/rh-python36/enable
export PYVENV_PROJDIR="/tmp/ansible_venv"
mkdir -p $PYVENV_PROJDIR
python3.6 -m pip install --user --upgrade pip setuptools
python3.6 -m venv $PYVENV_PROJDIR
source $PYVENV_PROJDIR/bin/activate
python3.6 -m pip install --upgrade pip setuptools
python3.6 -m pip install wheel
python3.6 -m pip install \
   ansible==2.9.27 \
   jmespath
ansible-galaxy collection install -r /tmp/requirements.yml --force
history -c
