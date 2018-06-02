#!/usr/bin/env bash

service apache2 status
service apache2 start
service apache2 status

tail -f /dev/null