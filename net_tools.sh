#!/bin/bash
echo "##############################################################################"
echo "#                                                                            #"
echo "#                     OnAir 直播流网络干扰测试工具                           #"
echo "#                                                                            #"
echo "##############################################################################"

eth="eth1"
if [ "$EUID" = 0 ]; then
    echo "Error:This script must be run as root!" 1>&2
    exit 1
fi
while :
do
    echo ""
    echo "1、启动"
    echo "2、停止"
    echo "3、退出"
    read -p  "请你选择(1/2/3):" choice
    case $choice in
    #判断变量cho的值
    "1")
        read -p "请输入本机网络设备名称[eth1]:" ieth 
        if [ "$ieth" != "" ]; then
           eth=$ieth
        fi
        read -p "请设置丢包的比例[10%]" nrate
        if [ "$nrate" = "" ]; then
           nrate=10
        fi
        read -p "请输入包的延时[0ms]" delay
        if [ "$delay" = "" ]; then
           delay=0
        fi
        read -p "设备名称:$eth, 网络丢包率设置为:$((nrate+0))%, 包延时设置为:$delay, 设置是否正确?[y/n]" yn
        if [ "$yn" = "y" ];then
           echo "网络干扰已经启动......"
           sudo tc qdisc add dev $eth root netem loss $nrate% delay ${delay}ms
           #sudo tc qdisc add dev $eth root netem delay ${delay}ms
        fi
    ;;
    "2")
        sudo tc qdisc del dev $eth root 
        echo "网络干扰已经停止......"
        ;;
    "3")
        exit
        ;;
    esac
done
