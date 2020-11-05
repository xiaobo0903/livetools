#!/bin/bash

# Copyright (C) 2020-2030 YunShiCloud, Inc
# 该程序是为了难证直播服务在各种异常流情况下的处理效果；
# written by xiaobo 2020-11-05

echo "##############################################################################"
echo "#                                                                            #"
echo "#                        Onair直播服务的流测试工具                           #"
echo "#                                                                            #"
echo "##############################################################################"

rtmp="rtmp://10.10.10.100/live/111111"
av="./stream/sample.mp4"

if [ "$EUID" = 0 ]; then
    echo "Error:This script must be run as root!" 1>&2
    exit 1
fi
while :
do
    echo ""
    echo ""
    echo "*当前的推流地址是:$rtmp,如需调整，请选择6"
    echo ""
    echo "1、输出带当前时间戳的视频流"
    echo "2、仅输出音频(无画面)"
    echo "3、仅输出画面(无音频)"
    echo "4、先有画面后有音频(音频延时3秒)"
    echo "5、音频与画面同时延时(5秒)"
    echo "6、设置推流地址"
    echo "7、退出"
    read -p  "请你选择(1/2/3/4/5/6/7):" choice
    case $choice in
    #判断变量cho的值
    "1")
	ffmpeg -re -stream_loop -1 -i $av -vf "settb=AVTB,setpts='trunc(PTS/1K)*1K+st(1,trunc(RTCTIME/1K))-1K*trunc(ld(1)/1K)',drawtext=fontsize=60:fontcolor=white:x=2:y=(h-text_h)/2-100:text='%{localtime}.%{eif\:1M*t-1K*trunc(t*1K)\:d}'" -vcodec libx264 -acodec aac -q 21  -f flv $rtmp
    ;;
    "2")
	ffmpeg -re -stream_loop -1 -i $av -vn -acodec copy   -f flv $rtmp
    ;;
    "3")
	ffmpeg -re -stream_loop -1 -i $av -vcodec copy -an   -f flv $rtmp
    ;;
    "4")
	ffmpeg -re -stream_loop -1 -i $av -vcodec copy -acodec aac -filter_complex "adelay=3000|3000" -vcodec libx264 -acodec aac -q 21 -f flv $rtmp
    ;;
    "5")
        read -p "请输入延时的秒数[5]:" mdelay
        if [ "$mdelay" = "" ]; then
             mdelay=5
        fi
        read -p "延时秒数设置的是:$mdelay秒, 确认开始吗[y/n]" yn
        if [ "$yn" = "y" ]; then
            ffmpeg -re -stream_loop -1 -i $av  -filter_complex split[a][b],[b]setpts=PTS+$mdelay/TB[c],[c][a]overlay=0:0 -b 2000k -vcodec libx264 -acodec aac -q 21 -f flv $rtmp 
        fi
    ;;
    "6")
        read -p "请输入推流地址[$rtmp] :" rtmp1
        if [ "$rtmp1" != "" ]; then
           rtmp=$rtmp1
        fi
        echo "设置的推流地址是[$rtmp]"
        ;;
    "7")
        exit
        ;;
    "q")
        exit
        ;;
    esac
done
