# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# clashX https/socket proxy "

proxy_on(){
local ip=$(ifconfig eth0 | grep inet | sed -n 1p | awk '{print $2}'|awk -F"." '{print $1"."$2"."$3"."}')
export https_proxy=http://${ip}2:7890 http_proxy=http://${ip}2:7890 all_proxy=socks5://${ip}2:7890
echo "以开启代理 代理地址为: ${ip}2:7890"
sleep 1
}

proxy_off(){

unset https_proxy
unset http_proxy
unset all_proxy

echo "###以关闭代理###"
sleep 1
}
