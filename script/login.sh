#!/bin/sh

# 参数 ./login.sh 账号类型 登录id 登录密码
# 其中账号类型 0表示校园网 1表示中国电信 2表示中国移动 

login_type=$1
login_id=$2
login_password=$3

if [ -z "$login_password" ] || [ -z "$login_id" ] || [ -z "$login_type" ];then
    echo "输入格式错误"
    exit 1
fi

online_hour_begin=7  #允许登录的时间 开始 24小时制
online_hour_end=23   #允许登录的时间 结束 24小时制

online_week='56'    #晚上允许登录的星期 从周一开始计数 1开始 字符串 如 56 代表周五、周六晚上至次日凌晨允许登录
hour=$(date +%H)
week=$(date +%u)

user_agent="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.9 Safari/537.36"  #伪装 user-agent 默认为chrome

hour_ok=1
week_ok=1

# 是否在上网时间段判断
    if [ "$hour" -lt "$online_hour_begin" ] || [ "$hour" -ge  "$online_hour_end" ]; then #小时判断
        # echo "不是上网小时"
        hour_ok=0
    # else
    #     echo "是上网小时"
    fi

    if [ "$hour" -lt "$online_hour_begin" ]; then #星期判断
        week=$(($week-1))
    fi
    week_ok=$(echo ${online_week} | grep -c ${week}) 

    if [ "$hour_ok" -eq "0" ] && [ "$week_ok" -eq "0" ]; then  #既不在可以上网的小时，也不在可以上网的晚上，退出
        # echo "退出"
        exit 0
    fi
# 可以联网
# 是否在上网时间段判断结束

# 检测是否联网
    curl -H "User-Agent:${user_agent}" https://www.baidu.com >/dev/null 2>/dev/null  #检测百度，如果未联网则ssl握手错误
    if [ "$?" -eq "0" ];then
        echo "已经联网，退出程序"
        exit 0
    else
        echo "已经断网，开始联网"
    fi
# 检测是否联网结束


# 登录id获取
    case ${login_type} in
        "0" )
        echo "校园网"
        login_id=",0,${login_id}"
        ;;
        "1" )
        echo "电信"
        login_id=",0,${login_id}@njxy"
        ;;
        "2" )
        echo "移动"
        login_id=",0,${login_id}@cmcc"
        ;;
        * )
        echo "运营商选择错误，退出"
        exit 1
        ;;
    esac
# 登录id获取结束

# exit 1

# userip="10.130.194.44"

# 自动参数获取  (根据url跳转实现)
    return_url=$(curl -Ss -H "User-Agent:${user_agent}" http://www.baidu.com | tr '\n\r' ' ' | sed -e 's/.*a href=\"//g' -e 's/\".*//g')
    hostname=$(echo ${return_url} | sed -e 's/http:\/\///g' -e 's/\/.*//g')  #获取登录用服务器ip
    userip=$(echo ${return_url} | sed -e 's/.*wlanuserip=//g' -e 's/&.*//g')  #获取当前用户ip
    wlanacip=$(echo ${return_url} | sed -e 's/.*wlanacip=//g' -e 's/&.*//g')   #获取wlanacip参数
    wlanacname=$(echo ${return_url} | sed -e 's/.*wlanacname=//g' -e 's/&.*//g')  #获取wlanacname参数
# 自动参数获取结束

# 其他请求参数设置

    # hostname="10.10.244.11"  #备用
    hostport="801"  #暂时没有简单的方法获得
    # wlanacip="10.255.253.118"  #备用
    # wlanacname="SPL-BRAS-SR8806-X"  #备用

# 其他请求参数设置结束

# 登录请求发送
    curl -H "User-Agent:${user_agent}" "http://${hostname}:${hostport}/eportal/?c=ACSetting&a=Login&protocol=http:&hostname=${hostname}&iTermType=1&wlanuserip=${userip}&wlanacip=${wlanacip}&wlanacname=${wlanacname}&mac=00-00-00-00-00-00&ip=${userip}&enAdvert=0&queryACIP=0&loginMethod=1" --data "DDDDD=${login_id}&upass=${login_password}&R1=0&R2=0&R3=0&R6=0&para=00&0MKKey=123456&buttonClicked=&redirect_url=&err_flag=&username=&password=&user=&cmd=&Login=&v6ip=" >/dev/null 2>/dev/null