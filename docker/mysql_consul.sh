#!/bin/bash

set -e

consul agent -config-dir=/etc/consul.d --enable-local-script-checks

mysqld