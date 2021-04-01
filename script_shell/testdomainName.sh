#!bin/bash


echo -e "网站名称\t网站域名\t是否具有AAAA记录\t解析是否需要www\t\t网站IPv6地址\t\t\t首页是否支持IPv6可访问\tIPv6状态代码"
# 定义dns服务器


# 网站是否具有4A记录

web4a(){
	recode4a=`dig aaaa  $weburl +short | egrep -o "([\da-fA-F0-9]{1,4}(:{1,2})){1,15}[\da-fA-F0-9]{1,4}$"| head -n 1`
    #recode4a=$(nslookup -type=AAAA -timeout=10 $weburl $v6ns | sed -n /[Aa]ddress/p | egrep -o "([\da-fA-F0-9]{1,4}(:{1,2})){1,15}[\da-fA-F0-9]{1,4}$") 
    #echo $recode4a
    if [ -n "$recode4a" ]; then
        str4a="有"
        addwww="不需要"
    else
        
	recode4a=`dig aaaa  "www.$weburl" +short | egrep -o "([\da-fA-F0-9]{1,4}(:{1,2})){1,15}[\da-fA-F0-9]{1,4}$" | head -n 1`
       # recode4a=$(nslookup -type=AAAA -timeout=5 "www.$weburl" $v6ns | sed -n /[Aa]ddress/p | egrep -o "([\da-fA-F0-9]{1,4}(:{1,2})){1,15}[\da-fA-F0-9]{1,4}$")
        if [ -n $recode4a ]; then
            str4a="有"
            addwww="需要"
        else
            str4a="没有"
        fi
    fi

}

#获取状态码，并测试连通性
testurl(){

    
    if [[ ${addwww} == "需要" ]];then
        status_code=$(curl -6 -L -I -m 10 -o /dev/null -s -w %{http_code} "www.$weburl")
        status_codes=$(curl -6 -L -I -m 10 -o /dev/null -s -w %{http_code} "https://www.$weburl")
    else
        addwww="不需要"        
        status_code=$(curl -6 -L -I -m 10 -o /dev/null -s -w %{http_code} "$weburl")
        status_codes=$(curl -6 -L -I -m 10 -o /dev/null -s -w %{http_code} "https://$weburl") 
    fi

    if [ "$status_code" == "200" ] || [ "$status_codes" == "200" ];then
        statusIPv6Access="支持"
    else
        statusIPv6Access="不支持"
    fi
}





# 数据处理主体
while read line
do

###### 网站名称 网站域名 ########

    weburl=$(echo ${line%/*} | awk '{print $2}')
    sitename=$(echo $line | awk '{print $1}')

    web4a
    testurl   

echo -e "$sitename\t$weburl\t\t$str4a\t\t$addwww\t\t\t$recode4a\t\t$statusIPv6Access\t\t\t$status_code $status_codes" 

#| awk -F, '{printf "%-15s %-15s %-10s %-10s %-15s %-15s %-8s\n",$1,$2,$3,$4,$5,$6,$7}' 

done < source.txt

echo "数据处理完成"
exit 0


