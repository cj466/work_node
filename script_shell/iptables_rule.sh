#!/bin/bash

# create_time:2020-3-25
# learn_test


EXTIF="eth0"   # 这个是可以连上 Internat  的网络接口
INIF=""    # 内部 LAN 的连接接口；若无则写成 INIF=""
INNET="10.211.55.0/24"  # 若无内部网域接口，请填写成 INNET=""
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
  if [ -f /home/sunhf/shell_script/iptables/iptables.deny ]; then
        bash /home/sunhf/shell_script/iptables/iptables.deny
  fi
  if [ -f /usr/local/virus/iptables/iptables.allow ]; then
        bash /home/sunhf/shell_script/iptables/iptables.allow
  fi
  if [ -f /home/sunhf/shell_script/iptables/iptables.http ]; then
        bash /home/sunhf/shell_script/iptables/iptables.http
  fi


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

# 6. 最终将这些功能储存下来吧！
iptables-save
