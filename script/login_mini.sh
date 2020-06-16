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

# 检测参数是否成功获取
    if [ -z "$hostname" ] || [ -z "$userip" ] || [ -z "$wlanacip" ] || [ -z "$wlanacname" ];then
        echo "参数获取失败，请检测网络，或者脚本已经失效。"
        exit 0
    fi
# 检测参数是否成功获取结束

# 登录请求发送
    curl -H "User-Agent:${user_agent}" "http://${hostname}:${hostport}/eportal/?c=ACSetting&a=Login&protocol=http:&hostname=${hostname}&iTermType=1&wlanuserip=${userip}&wlanacip=${wlanacip}&wlanacname=${wlanacname}&mac=00-00-00-00-00-00&ip=${userip}&enAdvert=0&queryACIP=0&loginMethod=1" --data "DDDDD=${login_id}&upass=${login_password}&R1=0&R2=0&R3=0&R6=0&para=00&0MKKey=123456&buttonClicked=&redirect_url=&err_flag=&username=&password=&user=&cmd=&Login=&v6ip=" >/dev/null 2>/dev/null