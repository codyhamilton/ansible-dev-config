#!/bin/bash

if command -v 'ansible-playbook'; then
	ansible-playbook playbook.yml -i inventory
	source ~/.bash_profile
else
	echo "You need to install ansible first"
	exit 1
fi
