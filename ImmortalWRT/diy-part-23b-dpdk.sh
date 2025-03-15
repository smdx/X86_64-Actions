#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
echo "开始 DIY2 配置……"
echo "========================="

chmod +x ${GITHUB_WORKSPACE}/scripts/function.sh
source ${GITHUB_WORKSPACE}/scripts/function.sh

# merge_folder 拉取指定文件夹操作 示例：
# 参数1是分支名，参数2是库地址，参数3是所有文件下载到指定路径，参数4是指定要下载的包文件夹。
# 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
# 示例:
# merge_folder master https://github.com/WYC-2020/openwrt-packages package/openwrt-packages luci-app-eqos luci-app-openclash luci-app-ddnsto ddnsto 
# merge_folder master https://github.com/lisaac/luci-app-dockerman package/lean applications/luci-app-dockerman

# merge_commits 拉取指定commits操作 示例：
#参数1是分支名，参数2是库地址，参数3是指定commits，参数4是下载到指定路径，参数5是目标包文件夹。
#merge_commits master https://github.com/kenzok8/openwrt-packages 114ee35443ccb8e0fbb92027134c3887feec9b37 feeds/kenzo adguardhome

# Modify default IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# x86 型号只显示 CPU 型号 for Lede
# sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/emortal/autocore/files/x86/autocore

#修正连接数（by ベ七秒鱼ベ）
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

#修复NAT回流
#sed -i '/customized in this file/a net.bridge.bridge-nf-call-arptables=0' package/base-files/files/etc/sysctl.conf
#sed -i '/customized in this file/a net.bridge.bridge-nf-call-ip6tables=0' package/base-files/files/etc/sysctl.conf
#sed -i '/customized in this file/a net.bridge.bridge-nf-call-iptables=0' package/base-files/files/etc/sysctl.conf

#PVE VirtIO半虚拟网卡状态页显示半双工修改
sed -i '/exit 0/i ethtool -s eth0 speed 2500 duplex full\nethtool -s eth1 speed 2500 duplex full' package/base-files/files/etc/rc.local

# 修复procps-ng-top导致首页cpu使用率无法获取
sed -i 's#top -n1#\/bin\/busybox top -n1#g' feeds/luci/modules/luci-base/root/usr/share/rpcd/ucode/luci

# 设置ttyd免帐号登录
#uci set ttyd.@ttyd[0].command='/bin/login -f root'
#uci commit ttyd

# MSD组播转换luci
rm -rf feeds/luci/applications/luci-app-msd_lite
git clone https://github.com/lwb1978/luci-app-msd_lite package/luci-app-msd_lite

# 替换udpxy为修改版，解决组播源数据有重复数据包导致的花屏和马赛克问题
rm -rf feeds/packages/net/udpxy/Makefile
cp -f ${GITHUB_WORKSPACE}/patches/udpxy/Makefile feeds/packages/net/udpxy/
# 修改 udpxy 菜单名称为大写
#sed -i 's#_(\"udpxy\")#_(\"UDPXY\")#g' feeds/luci/applications/luci-app-udpxy/luasrc/controller/udpxy.lua

# uwsgi - fix timeout
sed -i '$a cgi-timeout = 600' feeds/packages/net/uwsgi/files-luci-support/luci-*.ini
sed -i '/limit-as/c\limit-as = 5000' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# disable error log
sed -i "s/procd_set_param stderr 1/procd_set_param stderr 0/g" feeds/packages/net/uwsgi/files/uwsgi.init

# uwsgi - performance
sed -i 's/threads = 1/threads = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/processes = 3/processes = 4/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/cheaper = 1/cheaper = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini

# rpcd - fix timeout
sed -i 's/option timeout 30/option timeout 60/g' package/system/rpcd/files/rpcd.config
sed -i 's#20) \* 1000#60) \* 1000#g' feeds/luci/modules/luci-base/htdocs/luci-static/resources/rpc.js

### 插件切换到指定版本
echo "开始执行切换插件到指定版本"

# 移除要替换的包
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat

# Golang 1.2x
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
echo "Golang 插件切换完成"

# MosDNS
rm -rf feeds/small/mosdns
rm -rf feeds/small/luci-app-mosdns
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/new/mosdns
echo "MosDNS 插件切换完成"

# SmartDNS
rm -rf feeds/luci/applications/luci-app-smartdns
git clone https://github.com/lwb1978/luci-app-smartdns package/new/luci-app-smartdns
# 替换immortalwrt 软件仓库smartdns版本为官方最新版
rm -rf feeds/packages/net/smartdns
merge_folder main https://github.com/lwb1978/OpenWrt-Actions package/new patch/smartdns
#rm -rf feeds/kenzo/smartdns/Makefile
#wget -O feeds/kenzo/smartdns/Makefile https://raw.githubusercontent.com/kenzok8/jell/refs/heads/main/smartdns/Makefile
echo "SmartDNS 插件切换完成"

# ------------------PassWall 科学上网--------------------------
# 移除 openwrt feeds 自带的app
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/small/luci-app-passwall
rm -rf feeds/small/luci-app-passwall2
merge_folder main https://github.com/xiaorouji/openwrt-passwall package/new luci-app-passwall
merge_folder main https://github.com/xiaorouji/openwrt-passwall2 package/new luci-app-passwall2
# PW New Dnsmasq 防火墙重定向修改为默认关闭
# sed -i 's/local RUN_NEW_DNSMASQ=1/local RUN_NEW_DNSMASQ=0/' feeds/small/luci-app-passwall/root/usr/share/passwall/app.sh
#
# git clone -b luci-smartdns-dev --single-branch https://github.com/lwb1978/openwrt-passwall package/passwall-luci
# git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall
# git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2
# ------------------------------------------------------------
echo "PassWall 插件切换完成"

#AdguardHome指定commits
#rm -rf feeds/kenzo/adguardhome
#rm -rf feeds/kenzo/luci-app-adguardhome
#merge_commits master https://github.com/kenzok8/openwrt-packages 114ee35443ccb8e0fbb92027134c3887feec9b37 feeds/kenzo adguardhome
#merge_commits master https://github.com/kenzok8/openwrt-packages 915f448b80ee1adb928a5cfd58c33c678abacb5c feeds/kenzo luci-app-adguardhome
#echo "AdguardHome 插件切换完成"

# ppp - 2.5.0
rm -rf package/network/services/ppp
git clone https://github.com/sbwml/package_network_services_ppp package/network/services/ppp
echo "ppp 插件切换完成"

# IPSet(Lean源码已跟进)
#rm -rf package/network/utils/ipset
#merge_commits main https://github.com/openwrt/openwrt 9f6a28b91e30de9c6875afbe1493934218dbfb49 package/network/utils package/network/utils/ipset
#echo "IPSet 插件切换完成"

#Dnsmasq 版本替换
#rm -rf package/network/services/dnsmasq
#merge_folder master https://github.com/coolsnowwolf/lede package/network/services package/network/services/dnsmasq
#echo "Dnsmasq 插件切换完成"

# OpenSSL
#pushd package/libs/openssl
#git checkout 4fd8d7b7f8b7752ba8bb06e0d43808d0c5fddde0
#popd
#echo "OpenSSL 插件切换完成"

# Curl
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=8.5.0/g' feeds/packages/net/curl/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=ce4b6a6655431147624aaf582632a36fe1ade262d5fab385c60f78942dd8d87b/g' feeds/packages/net/curl/Makefile
#sed -i 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/net/curl/Makefile
#echo "Curl 插件切换完成"

# GN
#sed -i 's/PKG_SOURCE_DATE:=.*/PKG_SOURCE_DATE:=2023-11-17/g' feeds/small/gn/Makefile
#sed -i 's/PKG_SOURCE_VERSION:=.*/PKG_SOURCE_VERSION:=7367b0df0a0aa25440303998d54045bda73935a5/g' feeds/small/gn/Makefile
#sed -i 's/PKG_MIRROR_HASH:=.*/PKG_MIRROR_HASH:=c11eb62d257f9e41d29139d66e94d3798b013a650dd493ae8759c57e2e64cfd1/g' feeds/small/gn/Makefile
#echo "GN 插件切换完成"

# 替换curl修改版（无nghttp3、ngtcp2）
curl_ver=$(cat feeds/packages/net/curl/Makefile | grep -i "PKG_VERSION:=" | awk 'BEGIN{FS="="};{print $2}')
[ "$(check_ver "$curl_ver" "8.12.0")" != "0" ] && {
	echo "替换curl版本"
	rm -rf feeds/packages/net/curl
	cp -rf ${GITHUB_WORKSPACE}/patches/curl feeds/packages/net/curl
}

# 移动 WOL 到 “网络” 子菜单
sed -i 's/services/network/g' feeds/luci/applications/luci-app-wol/root/usr/share/luci/menu.d/luci-app-wol.json

# luci-app-wrtbwmon拉取插件
merge_folder main https://github.com/kenzok8/jell package/new luci-app-wrtbwmon wrtbwmon
sed -i 's/network/status/g' package/new/luci-app-wrtbwmon/root/usr/share/luci/menu.d/luci-app-wrtbwmon.json
sed -i '1,$c\
{\
	"protocol": "ipv4",\
	"interval": "2",\
	"showColumns": [\
		"thClient",\
		"thDownload",\
		"thUpload",\
		"thTotalDown",\
		"thTotalUp",\
		"thTotal"\
	],\
	"showZero": true,\
	"useBits": false,\
	"useMultiple": "1000",\
	"useDSL": false,\
	"upstream": "100",\
	"downstream": "100",\
	"hideMACs": [\
		"00:00:00:00:00:00"\
	]\
}' package/new/luci-app-wrtbwmon/root/etc/luci-wrtbwmon.conf

echo "luci-app-wrtbwmon 插件拉取完成"

# vim - fix E1187: Failed to source defaults.vim
pushd feeds/packages
	vim_ver=$(cat utils/vim/Makefile | grep -i "PKG_VERSION:=" | awk 'BEGIN{FS="="};{print $2}' | awk 'BEGIN{FS=".";OFS="."};{print $1,$2}')
	[ "$vim_ver" = "9.0" ] && {
		echo "修复 vim E1187 的错误"
		curl -s https://github.com/openwrt/packages/commit/699d3fbee266b676e21b7ed310471c0ed74012c9.patch | patch -p1
	}
popd

# 修复编译时提示 freeswitch 缺少 libpcre 依赖
sed -i 's/+libpcre \\$/+libpcre2 \\/g' package/feeds/telephony/freeswitch/Makefile

# private gitea
export gitea=git.cooluc.com
# script url
export mirror=https://init.cooluc.com
# github mirror
export github="github.com"

# 防火墙4添加自定义nft命令支持
patch -p1 < ${GITHUB_WORKSPACE}/patches/firewall4/100-openwrt-firewall4-add-custom-nft-command-support.patch

pushd feeds/luci
	# 防火墙4添加自定义nft命令选项卡
	patch -p1 < ${GITHUB_WORKSPACE}/patches/firewall4/0004-luci-add-firewall-add-custom-nft-rule-support.patch
	# 状态-防火墙页面去掉iptables警告，并添加nftables、iptables标签页
	patch -p1 < ${GITHUB_WORKSPACE}/patches/firewall4/0004-luci-mod-status-firewall-disable-legacy-firewall-rul.patch
popd

# 补充 firewall4 luci 中文翻译
cat >> "feeds/luci/applications/luci-app-firewall/po/zh_Hans/firewall.po" <<-EOF
	
	msgid ""
	"Custom rules allow you to execute arbitrary nft commands which are not "
	"otherwise covered by the firewall framework. The rules are executed after "
	"each firewall restart, right after the default ruleset has been loaded."
	msgstr ""
	"自定义规则允许您执行不属于防火墙框架的任意 nft 命令。每次重启防火墙时，"
	"这些规则在默认的规则运行后立即执行。"
	
	msgid ""
	"Applicable to internet environments where the router is not assigned an IPv6 prefix, "
	"such as when using an upstream optical modem for dial-up."
	msgstr ""
	"适用于路由器未分配 IPv6 前缀的互联网环境，例如上游使用光猫拨号时。"

	msgid "NFtables Firewall"
	msgstr "NFtables 防火墙"

	msgid "IPtables Firewall"
	msgstr "IPtables 防火墙"
EOF

echo "Firewall4 防火墙操作完成"

# UPnP
#rm -rf feeds/{packages/net/miniupnpd,luci/applications/luci-app-upnp}
#git clone https://$gitea/sbwml/miniupnpd feeds/packages/net/miniupnpd -b v2.3.7
#git clone https://$gitea/sbwml/luci-app-upnp feeds/luci/applications/luci-app-upnp -b main

# 精简 UPnP 菜单名称
sed -i 's#\"title\": \"UPnP IGD \& PCP/NAT-PMP\"#\"title\": \"UPnP\"#g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json
# 移动 UPnP 到 “网络” 子菜单
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json

# natmap
#pushd feeds/luci
#    curl -s $mirror/openwrt/patch/luci/applications/luci-app-natmap/0001-luci-app-natmap-add-default-STUN-server-lists.patch | patch -p1
#popd

# GCC Optimization level -O3
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/target-modify_for_x86_64.patch | patch -p1

# DPDK
merge_folder master https://github.com/sbwml/r4s_build_script package/new openwrt/patch/dpdk/dpdk openwrt/patch/dpdk/numactl
echo "DPDK 插件拉取完成"

# kselftests-bpf
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/packages-patches/kselftests-bpf/Makefile > package/devel/kselftests-bpf/Makefile

# SQM Translation
mkdir -p feeds/packages/net/sqm-scripts/patches
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/sqm/001-help-translation.patch > feeds/packages/net/sqm-scripts/patches/001-help-translation.patch

# opkg
mkdir -p package/system/opkg/patches
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/opkg/900-opkg-download-disable-hsts.patch > package/system/opkg/patches/900-opkg-download-disable-hsts.patch

# Realtek driver - R8168 & R8125 & R8126 & R8152 & R8101
rm -rf package/kernel/{r8168,r8152,r8101,r8125,r8126}
git clone https://$github/sbwml/package_kernel_r8168 package/kernel/r8168
git clone https://$github/sbwml/package_kernel_r8152 package/kernel/r8152
git clone https://$github/sbwml/package_kernel_r8101 package/kernel/r8101
git clone https://$github/sbwml/package_kernel_r8125 package/kernel/r8125
git clone https://$github/sbwml/package_kernel_r8126 package/kernel/r8126

# LTO编译状态确认再执行
if grep -q "^CONFIG_USE_LTO=y" .config; then
    # xdp-tools lto fix
    rm -rf package/network/utils/xdp-tools
    git clone https://$github/sbwml/package_network_utils_xdp-tools package/network/utils/xdp-tools

    # openssl - lto
    sed -i "s/ no-lto//g" package/libs/openssl/Makefile
    sed -i "/TARGET_CFLAGS +=/ s/\$/ -ffat-lto-objects/" package/libs/openssl/Makefile
    
    # libsodium - fix build with lto (GNU BUG - 89147)
    sed -i "/CONFIGURE_ARGS/i\TARGET_CFLAGS += -ffat-lto-objects\n" feeds/packages/libs/libsodium/Makefile
    
    # grub2 lto error fix
    sed -i '/^PKG_BUILD_FLAGS:=no-lto/s/$/ no-gc-sections/' package/boot/grub2/Makefile
else
    echo "CONFIG_USE_LTO is not set, skipping..."
fi

echo "插件自定义操作执行完毕"

# 添加主题
# argon
rm -rf feeds/kenzo/luci-app-argon-config
rm -rf feeds/kenzo/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-argon
merge_folder main https://github.com/sbwml/luci-theme-argon package/new luci-app-argon-config luci-theme-argon
echo "luci-theme-argon 替换完成"

# git clone https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom.git package/luci-theme-infinityfreedom
# git clone https://github.com/Leo-Jo-My/luci-theme-opentomcat.git package/luci-theme-opentomcat

# 取消自添加主题的默认设置
# find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

# 设置默认主题
# default_theme='Argon'
# sed -i "s/bootstrap/$default_theme/g" feeds/luci/modules/luci-base/root/etc/config/luci

# 其他软件包
# git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome
# git clone https://github.com/vernesong/OpenClash.git package/OpenClash
# git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
# git clone https://github.com/zzsj0928/luci-app-pushbot.git package/luci-app-pushbot
# git clone https://github.com/riverscn/openwrt-iptvhelper.git package/openwrt-iptvhelper
# git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/luci-app-unblockneteasemusic
# git clone https://github.com/jerrykuku/luci-app-jd-dailybonus.git package/luci-app-jd-dailybonus
#
# Smartdns
#git clone -b lede https://github.com/pymumu/luci-app-smartdns.git package/luci-app-smartdns
#git clone https://github.com/pymumu/smartdns.git package/smartdns

#echo 'refresh feeds'
# ./scripts/feeds update -a
# ./scripts/feeds install -a

echo "========================="
echo " DIY2 配置完成……"