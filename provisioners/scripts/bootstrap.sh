#!/bin/bash
set -ex

sed -i "s/AABBccddeeff112233gghh/$api_token/g" ~/.ansible.cfg
curl -L $satellite_manifest -o /tmp/manifest.zip

sudo yum -y install @development
sudo yum -y install python39

export PYVENV_PROJDIR="/tmp/ansible_venv"
mkdir -p $PYVENV_PROJDIR
python3.9 -m pip install --user --upgrade pip setuptools
python3.9 -m venv $PYVENV_PROJDIR
source $PYVENV_PROJDIR/bin/activate
python3.9 -m pip install --upgrade pip setuptools
python3.9 -m pip install wheel
python3.9 -m pip install \
   ansible-core==2.11.7 \
   jmespath
ansible-galaxy collection install -r /tmp/requirements.yml --force
history -c
