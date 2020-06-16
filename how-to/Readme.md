# NJUPT_Network_AutoLogin How_to

本文主要讲述这个脚本是如何写成的，以便于各位学习相关技术，并在学校更新参数导致本脚本失效时可以自行修改。写这个脚本时主要参考博客[Dr.COM校园网多设备解决方案](https://jakting.com/archives/drcom-autologin-padavan-tgbot.html)。

## 获取进行登录的请求

首先需要一个带有调试模式的浏览器，我常用的是Firefox浏览器，因此以此为例。

首先进入学校网络的登录界面[10.10.244.11](http://10.10.244.11)，然后打开工具箱(快捷键是F12)，进入其中的网络标签，此时里面内容为空。

![1](pictures/1.JPG)

随后进行登录操作直到成功(根据实测经验，第一次的登录会失败，第二次才会成功)，此时网络标签显示如下：

![2](pictures/2.JPG)

找到第一个POST请求，点开，查看其详细参数(部分参数为虚构)：

在消息头标签页中，获取请求字符串样例如下:

`http://10.10.244.11:801/eportal/?c=ACSetting&a=Login&protocol=http:&hostname=10.10.244.11&iTermType=1&wlanuserip=10.130.194.44&wlanacip=10.255.253.118&wlanacname=SPL-BRAS-SR8806-X&mac=00-00-00-00-00-00&ip=10.130.194.44&enAdvert=0&queryACIP=0&loginMethod=1`

随后转到请求标签页，查看其查询字符串和表单数据，样例如下(以json形式列出):

查询字符串

```
{
    "c": "ACSetting",
    "a": "Login",
    "protocol": "http:",
    "hostname": "10.10.244.11",
    "iTermType": "1",
    "wlanuserip": "10.130.194.44",
    "wlanacip": "10.255.253.118",
    "wlanacname": "SPL-BRAS-SR8806-X",
    "mac": "00-00-00-00-00-00",
    "ip": "10.130.194.44",
    "enAdvert": "0",
    "queryACIP": "0",
    "loginMethod": "1"
}
```

表单数据

```
{
    "DDDDD": ",0,agagaefa@njxy",
    "upass": "dgagergawg",
    "R1": "0",
    "R2": "0",
    "R3": "0",
    "R6": "0",
    "para": "00",
    "0MKKey": "123456",
    "buttonClicked": "",
    "redirect_url": "",
    "err_flag": "",
    "username": "",
    "password": "",
    "user": "",
    "cmd": "",
    "Login": "",
    "v6ip": ""
}
```

可以在多台电脑上进行尝试，并尝试不同的运营商组合，以便找到其规律。目前我测试时找到的规律如下：

请求的URL实际为`http://10.10.244.11:801/eportal/`，表示请求的地址为`10.10.244.11`端口为`801`，后续使用`?`搭载查询字符串，格式为：`名称=数据`，使用`&`符号连接。

查询字符串中发现的规律为：

参数名称|规律
----|----
c|常数`ACSetting`
a|常数`Login`
protocol|常数`http:`
hostname|与请求地址相同
iTermType|常数`1`
wlanuserip|设备的ip地址，如果设备位于路由器后则为路由器的ip地址
wlanacip|某个地址，看似是常数，但其他项目中填的地址不同
