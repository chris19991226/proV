#!/bin/bash

#安装v2
bash <(curl -L -s https://install.direct/go.sh)

#生成随机整数，用来生成端口
rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
    echo $(($num%$max+$min))  
}
#获取本机外网ip
yum install -y wget

serverip(){
    local IP=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipinfo.io/ip )
    [ ! -z ${IP} ] && echo ${IP} || echo
}

#进入v2配置文件目录
cd /etc/v2ray/

#删除原有v2配置文件
rm -f config.json

#下载kcp+tcp配置文件，kcp（srtp混淆），tcp（http混淆）
wget https://raw.githubusercontent.com/yobabyshark/proV/master/config.json

#生成并替换uuid，kcp、tcp各一个
kcpuuid=$(cat /proc/sys/kernel/random/uuid)
tcpuuid=$(cat /proc/sys/kernel/random/uuid)
sed -i "s/aaaa/$kcpuuid/;s/bbbb/$tcpuuid/;" config.json

#生成并修改端口
port=$(rand 10000 30000)
sed -i "s/11234/$port/" config.json

#重启v2
service v2ray restart

#输出配置信息
clear
echo
echo "安装已经完成，开启了kcp和tcp两种模式，客户端可任意选择对应的配置"
echo 
echo "===========KCP配置============="
echo "地址：$(serverip)"
echo "端口：${port}"
echo "uuid：${kcpuuid}"
echo "额外id：64"
echo "加密方式：aes-128-gcm"
echo "传输协议：kcp"
echo "别名：mykcp"
echo "伪装类型：srtp"
echo 
echo "===========TCP配置============="
echo "地址：$(serverip)"
echo "端口：${port}"
echo "uuid：${tcpuuid}"
echo "额外id：64"
echo "加密方式：aes-128-gcm"
echo "传输协议：tcp"
echo "别名：mytcp"
echo "伪装类型：http"
echo "伪装域名：bing.com,cloudflare.com,ajax.microsoft.com"
echo



