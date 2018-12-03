#!/bin/bash

# Simplify Your Life With an SSH Config File
# http://nerderati.com/2011/03/17/simplify-your-life-with-an-ssh-config-file/
# 要注意ssh command的环境变量的问题，在~/.bashrc里面把加载环境变量语句放到开头

for server in aa yy dd tuba 102 103
do
  echo $server
  timeout 3s ssh $server "gpustat -cpu --color"
done
