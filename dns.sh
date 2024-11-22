#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以 root 权限进行。请使用 sudo。"
    exit 1
fi

declare -A dns_domains
dns_domains["Disney_Netflix"]="
e13252.dscg.akamaiedge.net
h-netflix.online-metrix.net
netflix.com.edgesuite.net
cookielaw.org
fast.com
flxvpn.net
netflix.ca
netflix.com
netflix.com.au
netflix.com.edgesuite.net
netflix.net
netflixdnstest0.com
netflixdnstest1.com
netflixdnstest10.com
netflixdnstest2.com
netflixdnstest3.com
netflixdnstest4.com
netflixdnstest5.com
netflixdnstest6.com
netflixdnstest7.com
netflixdnstest8.com
netflixdnstest9.com
netflixinvestor.com
netflixstudios.com
netflixtechblog.com
nflxext.com
nflximg.com
nflximg.net
nflxsearch.net
nflxso.net
nflxvideo.net

disney.api.edge.bamgrid.com
disney-plus.net
disneyplus.com
dssott.com
disneynow.com
disneystreaming.com
cdn.registerdisney.go.com
"

dns_domains["ChatGPT"]="
openai.com
chatgpt.com
cdn.auth0.com
azureedge.net
sentry.io
azurefd.net
intercomcdn.com
intercom.io
identrust.com
challenges.cloudflare.com
ai.com
oaistatic.com
oaiusercontent.com
"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
On_Yellow="\033[43m" 
On_White="\033[47m"
IGreen="\033[0;92m"

# Bold High Intensity
BIBlack="\033[1;90m"
BIRed="\033[1;91m"
BIGreen="\033[1;92m"
BIYellow="\033[1;93m"
BIBlue="\033[1;94m"
BIPurple="\033[1;95m"
BICyan="\033[1;96m"
BIWhite="\033[1;97m"

On_ICyan="\033[0;106m"
On_IWhite="\033[0;107m"
On_IRed="\033[0;101m" 

NC='\033[0m' # No Color

# 显示脚本信息函数
show_info() {
    echo -e "  ${BIGreen}作者${NC}: ${BIYellow}KKKKKCAT${NC}"
    echo -e "  ${BIGreen}GitHub 项目${NC}: ${BIYellow}https://github.com/KKKKKCAT/KKScript/tree/main/script/dnsmasq${NC}"
    # 显示当前系统 DNS 设置
    echo -e "${BICyan}系统 DNS：${NC}${BIWhite}$(grep 'nameserver' /etc/resolv.conf | awk '{ print $2 }' | tr '\n' ' ')${NC}"
    
    # 检查并显示各区域的 DNS 配置
    if [ -f /etc/dnsmasq.conf ]; then
        disney_dns=$(grep 'netflix.com' /etc/dnsmasq.conf | cut -d '/' -f 4)
        chatgpt_dns=$(grep 'openai.com' /etc/dnsmasq.conf | cut -d '/' -f 4)
    else
        disney_dns=""
        chatgpt_dns=""
    fi

    # 输出各区域 DNS 配置
    echo -e "${BICyan}Disney+/Netflix DNS：${NC}${BIWhite}${disney_dns}${NC}"
    echo -e "${BICyan}ChatGPT DNS：${NC}${BIWhite}${chatgpt_dns}${NC}"
}

# 主脚本逻辑
clear
show_info
echo -e ""
echo -e "${BIWhite}请选择操作:${NC}"
echo -e "${BIYellow}1.${NC} ${IGreen}安装 dnsmasq${NC}"
echo -e "${BIYellow}2.${NC} ${IGreen}配置 dnsmasq${NC}"
echo -e "${BIYellow}3.${NC} ${IGreen}启动 dnsmasq${NC}"
echo -e "${BIRed}4.${NC} ${On_IRed}停止 dnsmasq${NC}"
echo -e "${BIYellow}5.${NC} ${IGreen}重启 dnsmasq${NC}"
echo -e "${BIRed}6.${NC} ${On_IRed}卸载 dnsmasq${NC}"
read -p "输入选择（例如：1）: " action

# 根据用户选择执行不同操作
case $action in
    1)
        # 安装 dnsmasq
        echo "正在安装 dnsmasq..."
        apt-get update && apt-get -y install dnsmasq

        # 复制 /etc/resolv.conf 内容到 /etc/dnsmasq.d/custom.conf
        if [ -f /etc/resolv.conf ]; then
            cp /etc/resolv.conf /etc/resolv.conf.bak -f
        else
            echo "未找到 /etc/resolv.conf 文件，跳过复制操作。"
        fi
        echo -e "\nserver=8.8.8.8" >> /etc/dnsmasq.d/custom.conf

        # 设置系统 DNS 指向本地 dnsmasq 服务
        rm /etc/resolv.conf
        touch /etc/resolv.conf
        bash -c 'echo -e "nameserver 127.0.0.1\nnameserver 8.8.8.8" > /etc/resolv.conf'
        chattr +i /etc/resolv.conf

        # 启用并启动 dnsmasq 服务
        systemctl unmask dnsmasq
        systemctl enable dnsmasq
        systemctl start dnsmasq
        ;;
    2)
        # 配置 dnsmasq
        echo -e ""
        echo -e "${BIBlue}1. Disney+/Netflix${NC}"
        echo -e "${BIYellow}2. ChatGPT${NC}"
        echo -e ""
        read -p "输入选择（例如：1）或按 Enter 取消: " region_choice

        # 处理用户输入
        if [ -z "$region_choice" ]; then
            echo -e "${BIRed}没有输入选择，操作已取消。${NC}"
            exit 0
        fi

        echo "输入 DNS IP 地址 (例如：8.8.8.8) 或按 Enter 删除旧设置:"
        read dns_ip

        # 根据选择配置对应的区域 DNS
        case $region_choice in
            1) selected_region="Disney_Netflix";;
            2) selected_region="ChatGPT";;
            *) echo -e "${BIRed}选择的区域无效，请重新运行脚本。${NC}"; exit 1;;
        esac

        # 删除旧 DNS 配置
        if [ -f /etc/dnsmasq.d/custom.conf ]; then
            echo -e "${BIRed}删除与所选区域相关的旧 DNS 设置${NC}"
            for domain in ${dns_domains[$selected_region]}; do
                sed -i "/server=\/$domain\//d" /etc/dnsmasq.d/custom.conf
            done
        fi

        # 添加新 DNS 配置
        if [ -n "$dns_ip" ]; then
            config_content=""
            for domain in ${dns_domains[$selected_region]}; do
                config_content+="server=/$domain/$dns_ip\n"
            done
            if ! grep -q "no-resolv" /etc/dnsmasq.conf; then
                config_content+="no-resolv\n"
                config_content+="log-queries\n"
                config_content+="log-facility=/dev/null\n"
                config_content+="cache-size=500\n"
            fi

            echo -e "$config_content" >> /etc/dnsmasq.d/custom.conf
            echo "正在重启 dnsmasq..."
            systemctl restart dnsmasq
        else
            echo "所有与所选区域相关的 DNS 设置已删除，未添加新配置。"
        fi
        ;;
    3)
        # 啟動 dnsmasq
        echo "正在启动 dnsmasq..."
        systemctl start dnsmasq
        ;;
    4)
        # 停止 dnsmasq
        echo "正在停止 dnsmasq..."
        systemctl stop dnsmasq
        ;;
    5)
        # 重啟 dnsmasq
        echo "正在重启 dnsmasq..."
        systemctl restart dnsmasq
        ;;
    6)
        # 卸載 dnsmasq
        echo "正在卸载 dnsmasq..."
        chattr -i /etc/resolv.conf
        systemctl stop dnsmasq
        apt-get remove -y dnsmasq
        rm /etc/dnsmasq.d/custom.conf

        if [ -f /etc/resolv.conf.bak ]; then
            cp /etc/resolv.conf.bak /etc/resolv.conf
            echo "恢复原来dns文件"
        else
            echo "未找到dns备份文件，重新添加"
            touch /etc/resolv.conf
            bash -c 'echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf'
        fi
        ;;
    *)
        echo -e "${BIRed}沒有输入选择，操作已取消。${NC}"
        exit 1
        ;;
esac

