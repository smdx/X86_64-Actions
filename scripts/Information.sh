#!/bin/bash

echo "开始执行固件信息输出操作……"
echo "==========================="

# OpenWrt Source Information
if [[ $REPO_URL == *"lede"* ]]; then
    echo "Openwrt Lean-x86" >> release.txt
elif [[ $REPO_URL == *"immortalwrt"* ]]; then
    echo "ImmortalWrt-x86" >> release.txt
fi

# 输出 REPO_BRANCH 信息，首字母大写
if [ -n "$REPO_BRANCH" ]; then
    # 将首字母转换为大写
    capitalized_branch="${REPO_BRANCH^}"
    echo "Branch: $capitalized_branch" >> release.txt
fi

# 获取内核版本信息
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
LINUX_KERNEL_HASH=$(grep "LINUX_KERNEL_HASH-${KERNEL_PATCHVER}" "$KERNEL_FILE")
VERSION_NUMBER=$(echo $LINUX_KERNEL_HASH | cut -d '=' -f1 | awk -F'-' '{print $NF}' | tr -d ' ')
echo "内核版本：$VERSION_NUMBER" >> release.txt

# 路由登录信息
echo "管理地址：10.0.0.1" >> release.txt
echo "默认密码：空" >> release.txt

# 定义插件顺序及包名映射
plugin_order=(
    "AdGuard Home"
    "MosDNS"
    "SmartDNS"
    "Passwall"
    "Passwall2"
    "OpenClash"
    "Mi Homo"
    "FC Homo"
    "Home Proxy"
    "Store"
    "SQM"
    "EQoS"
    "WOL"
    "UPnP"
    "Socat"
    "DDNS"
    "Udpxy"
    "VNT"
    "xfrpc"
    "Lucky"
    "NatMap"
    "ZeroTier"
    "Watchat"
    "Rtp2HTTPd"
    "WireGuard"
    "MultiSD_Lite"
    "uHTTPd"
    "USB Printer"
    "KMS Services"
)

declare -A plugin_packages=(
    ["AdGuard Home"]="luci-app-adguardhome"
    ["MosDNS"]="luci-app-mosdns"
    ["SmartDNS"]="luci-app-smartdns"
    ["Passwall"]="luci-app-passwall"
    ["Passwall2"]="luci-app-passwall2"
    ["OpenClash"]="luci-app-openclash"
    ["Mi Homo"]="luci-app-mihomo"
    ["FC Homo"]="luci-app-fchomo"
    ["Home Proxy"]="luci-app-homeproxy"
    ["SQM"]="luci-app-sqm"
    ["EQoS"]="luci-app-eqos"
    ["WOL"]="luci-app-wol"
    ["UPnP"]="luci-app-upnp"
    ["Store"]="luci-app-store"
    ["Socat"]="luci-app-socat"
    ["DDNS"]="luci-app-ddns"
    ["Udpxy"]="luci-app-udpxy"
    ["VNT"]="luci-app-vnt"
    ["xfrpc"]="luci-app-xfrpc"
    ["Lucky"]="luci-app-lucky"
    ["NatMap"]="luci-app-natmap"
    ["Watchat"]="luci-app-watchat"
    ["Rtp2HTTPd"]="luci-app-rtp2httpd"
    ["ZeroTier"]="luci-app-zerotier"
    ["WireGuard"]="wireguard-tools"
    ["MultiSD_Lite"]="luci-app-msd_lite"
    ["uHTTPd"]="luci-app-uhttpd"
    ["USB Printer"]="luci-app-usb-printer"
    ["KMS Services"]="luci-app-vlmcsd"
)

# 按顺序检查并生成插件清单
selected_plugins=()
for plugin in "${plugin_order[@]}"; do
    package="${plugin_packages[$plugin]}"
    if grep -q "^CONFIG_PACKAGE_${package}=y" openwrt/.config; then
        selected_plugins+=("$plugin")
    fi
done

# 设置分隔符，输出插件清单到 release.txt
echo "插件清单：$(IFS='、'; echo "${selected_plugins[*]}")" >> release.txt
echo "---------------------------------------------" >> release.txt

# 按预定义顺序输出版本信息
for plugin in "${selected_plugins[@]}"; do
    case $plugin in
        "AdGuard Home") echo "Adguard Home Version: ${adguardhome}" >> release.txt ;;
        "Store") echo "Store Version: ${store}" >> release.txt ;;
        "MosDNS") echo "MosDNS Version: ${mosdns}" >> release.txt ;;
        "SmartDNS") echo "SmartDNS Version: ${smartdns}" >> release.txt ;;
        "Passwall") echo "Passwall Version: ${passwall}" >> release.txt ;;
        "Passwall2") echo "Passwall2 Version: ${passwall2}" >> release.txt ;;
        "OpenClash") echo "OpenClash Version: ${openclash}" >> release.txt ;;
        "Mi Homo") echo "Mi Homo Version: ${mihomo}" >> release.txt ;;
        "FC Homo") echo "FC Homo Version: ${fchomo}" >> release.txt ;;
        "Home Proxy") echo "Home Proxy Version: ${homeproxy}" >> release.txt ;;
        "VNT") echo "VNT Version: ${vnt}" >> release.txt ;;
        "Lucky") echo "Lucky Version: ${lucky}" >> release.txt ;;
        "Watchat") echo "Watchat Version: ${watchat}" >> release.txt ;;
        "Rtp2HTTPd") echo "Rtp2HTTPd Version: ${rtp2httpd}" >> release.txt ;;
        "ZeroTier") echo "ZeroTier Version: ${zerotier}" >> release.txt ;;
        "WireGuard") echo "WireGuard Version: ${wireguard}" >> release.txt ;;
    esac
done

echo "==========================="
echo " 固件信息输出操作完成……"