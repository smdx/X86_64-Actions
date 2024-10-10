#!/bin/bash
# Get Package Versions
adguardhome_version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' openwrt/feeds/kenzo/adguardhome/Makefile)
mosdns_version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' openwrt/package/mosdns/mosdns/Makefile)
smartdns_version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' openwrt/feeds/kenzo/luci-app-smartdns/Makefile)
passwall_version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' openwrt/feeds/small/luci-app-passwall/Makefile)
passwall2_version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' openwrt/feeds/small/luci-app-passwall2/Makefile)
openclash_version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' openwrt/feeds/kenzo/luci-app-openclash/Makefile)
store_version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' openwrt/feeds/kenzo/luci-app-store/Makefile)
echo "adguardhome=$adguardhome_version" >> $GITHUB_ENV
echo "mosdns=$mosdns_version" >> $GITHUB_ENV
echo "smartdns=$smartdns_version" >> $GITHUB_ENV
echo "passwall_version=$passwall_version" >> $GITHUB_ENV
echo "passwall2_version=$passwall2_version" >> $GITHUB_ENV
echo "openclash=$openclash_version" >> $GITHUB_ENV
echo "store=$store_version" >> $GITHUB_ENV

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

# 路由登录信息
echo "管理地址：10.0.0.1" >> release.txt
echo "默认密码：空" >> release.txt

# 定义需要检查的插件列表
declare -A plugins
plugins=(
    ["AdGuard Home"]="luci-app-adguardhome"
    ["MosDNS"]="luci-app-mosdns"
    ["SmartDNS"]="luci-app-smartdns"
    ["Passwall"]="luci-app-passwall"
    ["Passwall2"]="luci-app-passwall2"
    ["OpenClash"]="luci-app-openclash"
    ["HomeProxy"]="luci-app-homeproxy"
    ["Store"]="luci-app-store"
    ["SQM"]="luci-app-sqm"
    ["WOL"]="luci-app-wol"
    ["UPnP"]="luci-app-upnp"
    ["DDNS"]="luci-app-ddns"
    ["uHTTPd"]="luci-app-uhttpd"
    ["Udpxy"]="luci-app-udpxy"
    ["NatMap"]="luci-app-natmap"
    ["MultiSD_Lite"]="luci-app-msd_lite"
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
echo "插件清单：${selected_plugins[*]}" >> release.txt
echo "---------------------------------------------" >> release.txt

# 主要插件输出版本信息
for plugin in "${selected_plugins[@]}"; do
    case $plugin in
        "AdGuard Home")
            echo "Adguardhome Version: $adguardhome" >> release.txt
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
        "Store")
            echo "Store Version: $store" >> release.txt
            ;;
    esac
done