# 简介
masscan和namp结合实现全端口快速扫描，修改至onetwopunch项目bash脚本

# 使用
1.首先安装nmap和masscan
1.用法
```
Usage: ./fastportscan.sh -t targets.txt [-e PATH] [-h]
       -h: Help
       -t: File containing ip addresses to scan. This option is required.
       -e: masscan's path (ex: /root/masscan/bin/).
```
-t ip列表文件
-e masscan的执行文件路径
       

