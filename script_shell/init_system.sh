#!/bin/bash

# create_time:  21-3-25
# name: sunhongfan
# gmail: sunhongfan920@gmail.com 


# init centos7.x system script.


systemctl start firewalld.service

iptables -F
iptables -X
iptables -Z


useradd user1

echo "Adminuser1" | passwd --stdin user1 > /dev/null

echo "system defualt [user]: user1    [passwd]: Adminuser1"

echo "Install package ..."
yum install -y git net-tools iftop vim wget  > /dev/null


echo "aliyun.mirror"

mv /etc/yum.repo.d/CentOS-Base.repo /etc/yum.repo.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

yum clean all

yum makecache fast 

yum install -y epel-release iptables-services 

yum update -y


echo "update sudo"

yum install rpm-build zlib-devel openssl-devel gcc perl-devel pam-devel unzip -y > /dev/null

wget --http-user=caictipv6 --http-password=admin2real@rittgxb https://software.topwiki.org/centos7/sudo-1.9.5p2.tar.gz

tar zxf sudo-1.9.5p2.tar.gz

cd sudo-1.9.5p2

./configure --prefix=/usr --libexecdir=/usr/lib --with-secure-path --with-allinsults --with-env-editor --docdir=/usr/share/doc/sudo-1.9.5p2 && make && make install && ln -sfv libsudo_util.so.0.0.0 /usr/lib/sudo/libsudo_util.so.0


echo $(sudo -V)



echo " install openssh and openssl"

wget --http-user=caictipv6 --http-password=admin2real@rittgxb https://software.topwiki.org/openssl/openssl-1.1.1j.tar.gz

tar add openssl-1.1.1j.tar.gz 

cd openssl-1.1.1j

./config --prefix=/usr/local/ssl shared zlib -dynamic enable-camellia 

if [ $? == "0" ];then

	make && make install
fi

ln -s /usr/local/lib64/libssl.so.1.1 /usr/lib64/
ln -s /usr/local/lib64/libcrypto.so.1.1 /usr/lib64/
ln -s /usr/local/ssl/include/openssl /usr/include/openssl
echo "/usr/local/ssl/lib" >>/etc/ld.so.conf

ldconfig

ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl_latest

cd /usr/bin 

mv openssl openssl_old 

mv openssl_latest openssl

cd /home/caictipv6/openssh 
wget --http-user=caictipv6 --http-password=admin2real@rittgxb https://software.topwiki.org/openssh/openssh-8.5p1.tar.gz 

tar zxvf openssh-8.5p1.tar.gz 

cd openssh-8.5p1 

./configure --prefix=/usr --sysconfdir=/etc/ssh --with-ssl-dir=/usr/local/ssl -with-zlib --with-md5-passwords --with-pam --with-selinux

make 

make install


cd /etc/ssh 

chmod 600 ssh_host_ecdsa_key ssh_host_ed25519_key ssh_host_rsa_key
sed -i '/^GSS/d' /etc/sshd/sshd_config


nohup systemctl restart sshd &

npid=$(jobs -l | awk '{ print $2 }')

sleep 2
kill $npid

ssh -V
 
