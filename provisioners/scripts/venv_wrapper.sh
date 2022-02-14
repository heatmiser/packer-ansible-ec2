#!/bin/bash
source /tmp/ansible_venv/bin/activate && ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 /tmp/ansible_venv/bin/ansible-playbook "$@"
