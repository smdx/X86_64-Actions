#!/bin/bash

echo "开始执行固件信息输出操作……"
echo "========================="

# OpenWrt Source Information
if [[ $REPO_URL == *"lede"* ]]; then
    # 如果地址包含"lede"，执行以下操作
    echo "Openwrt Lean-x86" >> release.txt
elif [[ $REPO_URL == *"immortalwrt"* ]]; then
    # 如果地址包含"immortalwrt"，执行以下操作
    echo "ImmortalWrt-x86" >> release.txt
fi

# 输出 REPO_BRANCH 信息，首字母大写
if [ -n "$REPO_BRANCH" ]; then
    # 将首字母转换为大写
    capitalized_branch="${REPO_BRANCH^}"
    echo "Branch: $capitalized_branch" >> release.txt
fi

# OpenWRT 获取内核版本信息
# 检查 TESTING_KERNEL 设置状态
if grep -q '^CONFIG_TESTING_KERNEL=y' openwrt/.config; then
    # 读取 KERNEL_TESTING_PATCHVER 的值
    KERNEL_PATCHVER=$(grep '^KERNEL_TESTING_PATCHVER:=' openwrt/target/linux/x86/Makefile | cut -d '=' -f2 | tr -d ' ')
else
    # 读取 KERNEL_PATCHVER 的值
    KERNEL_PATCHVER=$(grep '^KERNEL_PATCHVER:=' openwrt/target/linux/x86/Makefile | cut -d '=' -f2 | tr -d ' ')
fi

# 目标文件路径
KERNEL_FILE="openwrt/include/kernel-${KERNEL_PATCHVER}"

# 读取 LINUX_KERNEL_HASH-后的数值提取版本号,输出到release.txt
LINUX_KERNEL_HASH=$(grep "LINUX_KERNEL_HASH-${KERNEL_PATCHVER}" "$KERNEL_FILE")
VERSION_NUMBER=$(echo $LINUX_KERNEL_HASH | cut -d '=' -f1 | awk -F'-' '{print $NF}' | tr -d ' ')
echo "内核版本：$VERSION_NUMBER" >> release.txt

# 路由登录信息
echo "管理地址：10.0.0.1" >> release.txt
echo "默认密码：空" >> release.txt

# 定义需要检查的插件列表
declare -A plugins
plugins=(
    ["AdGuard_Home"]="luci-app-adguardhome"
    ["MosDNS"]="luci-app-mosdns"
    ["SmartDNS"]="luci-app-smartdns"
    ["Passwall"]="luci-app-passwall"
    ["Passwall2"]="luci-app-passwall2"
    ["OpenClash"]="luci-app-openclash"
    ["MiHomo"]="luci-app-mihomo"
    ["HomeProxy"]="luci-app-homeproxy"
    ["Store"]="luci-app-store"
    ["SQM"]="luci-app-sqm"
    ["E_QoS"]="luci-app-eqos"
    ["WOL"]="luci-app-wol"
    ["UPnP"]="luci-app-upnp"
    ["Socat"]="luci-app-socat"
    ["DDNS"]="luci-app-ddns"
    ["Udpxy"]="luci-app-udpxy"
    ["NatMap"]="luci-app-natmap"
    ["ZeroTier"]="luci-app-zerotier"
    ["MultiSD_Lite"]="luci-app-msd_lite"
    ["uHTTPd"]="luci-app-uhttpd"
    ["USB_Printer"]="luci-app-usb-printer"
    ["KMS_Services"]="luci-app-vlmcsd"
)

# 插件状态数组
selected_plugins=()

# 读取配置文件并检查插件状态
while IFS= read -r line; do
    for plugin in "${!plugins[@]}"; do
        if [[ $line == "CONFIG_PACKAGE_${plugins[$plugin]}=y" ]]; then
            selected_plugins+=("$plugin")
        fi
    done
done < openwrt/.config

# 插入插件清单到 release.txt
IFS='、'  # 设置分隔符
echo "插件清单：${selected_plugins[*]}" >> release.txt
unset IFS  # 恢复默认分隔符
echo "---------------------------------------------" >> release.txt

# 主要插件输出版本信息
for plugin in "${selected_plugins[@]}"; do
    case $plugin in
        "AdGuard_Home")
            echo "AdguardHome Version: $adguardhome" >> release.txt
            ;;
        "MosDNS")
            echo "MosDNS Version: $mosdns" >> release.txt
            ;;
        "SmartDNS")
            echo "SmartDNS Version: $smartdns" >> release.txt
            ;;
        "Passwall")
            echo "Passwall Version: $passwall_version" >> release.txt
            ;;
        "Passwall2")
            echo "Passwall2 Version: $passwall2_version" >> release.txt
            ;;
        "OpenClash")
            echo "OpenClash Version: $openclash" >> release.txt
            ;;
        "MiHomo")
            echo "MiHomo Version: $mihomo" >> release.txt
            ;;
        "Store")
            echo "Store Version: $store" >> release.txt
            ;;
    esac
done

echo "========================="
echo " 固件信息输出操作完成……"