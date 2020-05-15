Host xx
  User acgtyrant
  Hostname 10.10.24.92
  Port 22
  IdentityFile ~/.ssh/id_rsa


Host yy
  User acjishu2
  gtyrant
  Hostname 192.168.9.6
  Port 22
  IdentityFile ~/.ssh/id_rsa


Host zz
  User acgtyrant
  Hostname 192.168.9.5
  Port 22
  IdentityFile ~/.ssh/id_rsa

http://nerderati.com/2011/03/17/simplify-your-life-with-an-ssh-config-file/

这篇写的很好很全面：zhehttps://www.digitalocean.com/community/tutorials/how-to-configure-custom-connection-options-for-your-ssh-client

免密码登录：ssh-copy-id user@host
ssh-copy-id将密钥复制到远程主机，并追加到远程账号的~/.ssh/authorized_keys文件中。

vim /etc/hosts

添加
10.10.24.92 XX
192.168.9.6 yy
192.168.9.5 zz


10.10.14.72 AA
192.168.9.7 cc

10.10.24.107 aa

