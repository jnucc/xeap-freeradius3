#!/bin/sh

USERNAME=$1
PASSWORD=$2

sed -e "s/USERNAME/$USERNAME/" -e "s/PASSWORD/$PASSWORD/" test.conf.template > test.conf

eapol_test -a 127.0.0.1  -p 1812 -s testing123 -c test.conf 

