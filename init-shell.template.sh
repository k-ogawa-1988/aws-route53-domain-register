#!/bin/sh
# chkconfig: 2345 99 10
# description: update Route53 shell

case "$1" in
  start)
       {%ROOT_DIR%}/ec2setup.sh
       ;;
  *) break ;;
esac
