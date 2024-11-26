#!/bin/bash

# Simplify Your Life With an SSH Config File
# http://nerderati.com/2011/03/17/simplify-your-life-with-an-ssh-config-file/
# 要注意ssh command的环境变量的问题，在~/.bashrc里面把加载环境变量语句放到开头
# 或者放到~/.zshenv

sep()
{
        printf -v str "%${1}s" ""
        echo -e "\e[1;33m${str// /$2}\e[0m"
        #echo -e "${str// /$2}"
}

sep 100 -

# for server in aa yy dd tuba 102 103 123 124 room
for server in 48 51 52 53 50
do
  echo -e "\e[1;4;33;40m$server\e[0m"
  timeout 8s ssh $server "gpustat -cpu --color"
  sep 100 -
done
