#!/bin/bash

# create_time:  21-3-25
# name: sunhongfan
# gmail: sunhongfan920@gmail.com 


# init centos7.x system script.


if [[ $(id -u) != 0 ]]; then 
    echo -e "\033[1;31m Error! You must be root to run this script! \033[0m"
    exit 100
fi

end_info(){
    echo -e "\033[1;31m 系统初始化完成，bug提交 Sun_hongfan@163.com  即将重启  \033[0m"
    sleep 2
    reboot
}




add_user(){
    read -p "请输入创建的用户名 默认为[Admin]: " username
    local username
    
    if [ -z "$username" ];then
        id Admin > /dev/null 2>&1
        
        if [ $? != 0 ];then 
	        useradd Admin
	        echo Adminpasswd | passwd --stdin Admin > /dev/null
            echo -e "\033[1;31m Username: Admin  Passwd: Adminpasswd \033[0m"
        else
            echo Adminpasswd | passwd --stdin Admin > /dev/null
            echo -e "\033[1;31m Username: Admin  Passwd: Adminpasswd \033[0m"
        fi
    else
       echo Adminpasswd | passwd --stdin Admin > /dev/null
       echo -e "\033[1;31m Username: $username  Passwd: Adminpasswd \033[0m"
    fi
}


url_check(){
    check=a=$(curl -s "$key_url" | grep ^ssh-rsa)
    
    if [ -n "$check"]; then
        curl $key_url >> /home/$username/.ssh/authorized_keys
        chmod 644  /home/$username/.ssh/authorized_keys
    else
        echo "url 错误"
        exit 101
    fi
}


id_key_pub(){
# 配置密钥

read -p "是否为 ${uaername} 配置免密登录: [Y/N]" YN

case $YN in 
    [Yy][Ee][Ss]|[Yy])
        read -p "请输入的的密钥路径url: " key_url
        
        if [ -f /home/$username/.ssh/authorized_keys ];then

            mkdir -p /home/$username/.ssh > /dev/null 2>&1
            url_check
        else
            mkdir -p /home/$username/.ssh && chmod 700 /home/$username/.ssh
            url_check
        fi
    ;;
    *)
        echo ""
        ;;
esac
}


sshd_conf(){

sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config  
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config  

}


install_package(){


    echo "aliyun.mirror"
    mv /etc/yum.repo.d/CentOS-Base.repo /etc/yum.repo.d/CentOS-Base.repo.backup
    curl -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo > /dev/null
    
    yum clean all
    
    yum makecache fast
    
    
    
    
    echo "Install package ..."
    yum install -y git epel-release iptables-services net-tools iftop vim wget  > /dev/null
    yum update -y
}


update_sudo(){



    echo"update sudo"
    
    yum install rpm-build zlib-devel openssl-devel gcc perl-devel pam-devel unzip -y > /dev/null
    
    cd /root
    
    wget --http-user=caictipv6 --http-password=admin2real@rittgxb https://software.topwiki.org/centos7/sudo-1.9.5p2.tar.gz
    
    tar zxf sudo-1.9.5p2.tar.gz
    
    cd sudo-1.9.5p2
    
    ./configure --prefix=/usr --libexecdir=/usr/lib --with-secure-path --with-allinsults --with-env-editor --docdir=/usr/share/doc/sudo-1.9.5p2 && make && make install && ln -sfv libsudo_util.so.0.0.0 /usr/lib/sudo/libsudo_util.so.0
    
    
    echo $(sudo -V)

}


update_ssh(){

    
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
    
}


firewalld(){
    

    read -p "请输入网卡接口名称[eth0]: " EXTIF
    read -p "内部 LAN 的连接接口；若无则写成 INIF='' " INIF 
    read -p "请输入 内部LAN网段 若无内网接口，请填写成 INNET=''  " INNET 
    export EXTIF INIF INNET
    
    
    # 第一部份，针对本机的防火墙设定！##########################################
    # 1. 先设定好核心的网络功能：
    echo "1" > /proc/sys/net/ipv4/tcp_syncookies
    echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
    
    for i in /proc/sys/net/ipv4/conf/*/{rp_filter,log_martians}; do
       echo "1" > $i
    done
    
    
    for i in /proc/sys/net/ipv4/conf/*/{accept_source_route,accept_redirects,send_redirects}; do
            echo "0" > $i
    done
    
    # 2. 清除规则、设定默认政策及开放 lo 与相关的设定值
    iptables -F
    iptables -X
    iptables -Z
    iptables -P INPUT   DROP
    iptables -P OUTPUT  ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    
    
    # 3. 启动额外的防火墙 script 模块
    #  if [ -f /home/sunhf/shell_script/iptables/iptables.deny ]; then
    #        bash /home/sunhf/shell_script/iptables/iptables.deny
    #  fi
    #  if [ -f /usr/local/virus/iptables/iptables.allow ]; then
    #        bash /home/sunhf/shell_script/iptables/iptables.allow
    #  fi
    #  if [ -f /home/sunhf/shell_script/iptables/iptables.http ]; then
    #        bash /home/sunhf/shell_script/iptables/iptables.http
    #  fi
    
    
    # 4. 允许某些类型的 ICMP 封包进入
    AICMP="0 3 3/4 4 11 12 14 16 18"
    for tyicmp in $AICMP
    do
      iptables -A INPUT -i $EXTIF -p icmp --icmp-type $tyicmp -j ACCEPT
    done
    
    
    
    
    # 5. 允许某些服务的进入，请依照你自己的环境开启
    # iptables -A INPUT -p TCP -i $EXTIF --dport  21 --sport 1024:65534 -j ACCEPT # FTP
    iptables -A INPUT -p TCP -i $EXTIF --dport  22 --sport 1024:65534 -j ACCEPT # SSH
    # iptables -A INPUT -p TCP -i $EXTIF --dport  25 --sport 1024:65534 -j ACCEPT # SMTP
    # iptables -A INPUT -p UDP -i $EXTIF --dport  53 --sport 1024:65534 -j ACCEPT # DNS
    # iptables -A INPUT -p TCP -i $EXTIF --dport  53 --sport 1024:65534 -j ACCEPT # DNS
    iptables -A INPUT -p TCP -i $EXTIF --dport  80 --sport 1024:65534 -j ACCEPT # WWW
    # iptables -A INPUT -p TCP -i $EXTIF --dport 110 --sport 1024:65534 -j ACCEPT # POP3
    # iptables -A INPUT -p TCP -i $EXTIF --dport 443 --sport 1024:65534 -j ACCEPT # HTTPS
    
    
    # 第二部份，针对后端主机的防火墙设定！###############################
    # 1. 先加载一些有用的模块
    modules="ip_tables iptable_nat ip_nat_ftp ip_nat_irc ip_conntrack ip_conntrack_ftp ip_conntrack_irc"
    for mod in $modules
    do
        testmod=`lsmod | grep "^${mod} " | awk '{print $1}'`
        if [ "$testmod" == "" ]; then
              modprobe $mod
        fi
    done
    
    # 2. 清除 NAT table 的规则吧！
    iptables -F -t nat
    iptables -X -t nat
    iptables -Z -t nat
    iptables -t nat -P PREROUTING  ACCEPT
    iptables -t nat -P POSTROUTING ACCEPT
    iptables -t nat -P OUTPUT      ACCEPT
    
    # 3. 若有内部接口的存在 (双网卡) 开放成为路由器，且为 IP 分享器！
      if [ "$INIF" != "" ]; then
        iptables -A INPUT -i $INIF -j ACCEPT
        echo "1" > /proc/sys/net/ipv4/ip_forward
        if [ "$INNET" != "" ]; then
            for innet in $INNET
            do
                iptables -t nat -A POSTROUTING -s $innet -o $EXTIF -j MASQUERADE
            done
        fi
      fi
    
    # 如果你的 MSN 一直无法联机，或者是某些网站 OK 某些网站不 OK，
    # 可能是 MTU 的问题，那你可以将底下这一行给他取消批注来启动 MTU 限制范围
    # iptables -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss \
    #          --mss 1400:1536 -j TCPMSS --clamp-mss-to-pmtu
    
    # 4. NAT 服务器后端的 LAN 内对外之服务器设定
    # iptables -t nat -A PREROUTING -p tcp -i $EXTIF --dport 80 \
    #          -j DNAT --to-destination 192.168.1.210:80 # WWW
    
    # 5. 特殊的功能，包括 Windows 远程桌面所产生的规则，假设桌面主机为 1.2.3.4
    # iptables -t nat -A PREROUTING -p tcp -s 1.2.3.4  --dport 6000 \
    #          -j DNAT --to-destination 192.168.100.10
    # iptables -t nat -A PREROUTING -p tcp -s 1.2.3.4  --sport 3389 \
    #          -j DNAT --to-destination 192.168.100.20
    
    iptables-save


main(){
    add_user
    sshd_conf
    id_key_pub
    install_package
    update_sudo
    update_ssh
    firewalld   
    end_info
}

main
