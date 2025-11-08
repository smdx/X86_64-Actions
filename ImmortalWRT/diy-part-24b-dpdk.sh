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
#rm -rf feeds/luci/applications/luci-app-msd_lite
#git clone https://github.com/lwb1978/luci-app-msd_lite package/luci-app-msd_lite

# 替换udpxy为修改版，解决组播源数据有重复数据包导致的花屏和马赛克问题
#rm -rf feeds/packages/net/udpxy/Makefile
#cp -f ${GITHUB_WORKSPACE}/patches/udpxy/Makefile feeds/packages/net/udpxy/
# 修改 udpxy 菜单名称为大写
#sed -i 's#_(\"udpxy\")#_(\"UDPXY\")#g' feeds/luci/applications/luci-app-udpxy/luasrc/controller/udpxy.lua

# 添加rtp2httpd
git clone --depth=1 -b main https://github.com/stackia/rtp2httpd rtp2httpd_tmp
rm -rf package/rtp2httpd-openwrt
mv rtp2httpd_tmp/openwrt-support package/rtp2httpd-openwrt
mkdir package/rtp2httpd-openwrt/rtp2httpd/src
mv rtp2httpd_tmp/* package/rtp2httpd-openwrt/rtp2httpd/src
rm -rf rtp2httpd_tmp
rm -f package/rtp2httpd-openwrt/rtp2httpd/Makefile
cp -f ${GITHUB_WORKSPACE}/patches/rtp2httpd/Makefile_core package/rtp2httpd-openwrt/rtp2httpd/Makefile
rm -f package/rtp2httpd-openwrt/luci-app-rtp2httpd/Makefile
cp -f ${GITHUB_WORKSPACE}/patches/rtp2httpd/Makefile_luci package/rtp2httpd-openwrt/luci-app-rtp2httpd/Makefile
RTP2HTTPD_VERSION=$(curl -s https://api.github.com/repos/stackia/rtp2httpd/releases?per_page=1 | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')
if [ -n "$RTP2HTTPD_VERSION" ]; then
	RTP2HTTPD_PKG_VERSION=$(echo "$RTP2HTTPD_VERSION" | sed -E 's/-([a-z]+)\.([0-9]+)/_\1\2/g')
	echo "rtp2httpd获取到版本：$RTP2HTTPD_VERSION"
	echo "rtp2httpd转换为包版本：$RTP2HTTPD_PKG_VERSION"
	sed -i "s|^\(PKG_VERSION:=\).*|\1$RTP2HTTPD_PKG_VERSION|" package/rtp2httpd-openwrt/rtp2httpd/Makefile
	sed -i "s|^\(PKG_VERSION:=\).*|\1$RTP2HTTPD_PKG_VERSION|" package/rtp2httpd-openwrt/luci-app-rtp2httpd/Makefile
	sed -i "s|^\([[:space:]]*AC_INIT([[:space:]]*\[rtp2httpd\][[:space:]]*,[[:space:]]*\[\)[^]]*\(\].*\)|\1$RTP2HTTPD_VERSION\2|" package/rtp2httpd-openwrt/rtp2httpd/src/configure.ac
fi
echo "" >> .config  # 添加一个空行(确保正确换行)
echo "CONFIG_PACKAGE_luci-app-rtp2httpd=y" >> .config
echo "CONFIG_PACKAGE_rtp2httpd=y" >> .config

echo "添加 rtp2httpd 流媒体转发服务器"

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

# Golang 1.25
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang
echo "Golang 插件切换完成"

# VNT 简便高效的异地组网、内网穿透工具
merge_folder main https://github.com/lmq8267/luci-app-vnt package/new luci-app-vnt vnt vnts

# MosDNS
rm -rf feeds/small/mosdns
rm -rf feeds/small/luci-app-mosdns
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/new/mosdns
echo "MosDNS 插件切换完成"

# SmartDNS
rm -rf feeds/luci/applications/luci-app-smartdns
rm -rf feeds/kenzo/luci-app-smartdns
git clone https://github.com/lwb1978/luci-app-smartdns package/luci-app-smartdns
# 替换immortalwrt 软件仓库smartdns版本为官方最新版
rm -rf feeds/packages/net/smartdns
rm -rf feeds/kenzo/smartdns
# cp -rf ${GITHUB_WORKSPACE}/patch/smartdns package/
git clone https://github.com/smdx/openwrt-smartdns package/smartdns
# 添加 smartdns-ui
# echo "" >> .config  # 添加一个空行(确保正确换行)
# echo "CONFIG_PACKAGE_luci-app-smartdns_INCLUDE_smartdns_ui=y" >> .config
# echo "CONFIG_PACKAGE_smartdns-ui=y" >> .config

# openssl Enable QUIC and KTLS support
echo "" >> .config  # 添加一个空行(确保正确换行)
echo "CONFIG_OPENSSL_WITH_QUIC=y" >> .config
echo "CONFIG_OPENSSL_WITH_KTLS=y" >> .config
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
# sing-box-1.12.0 with_ech error fix
sed -i '/config SING_BOX_WITH_ECH/,+3d' feeds/small/sing-box/Makefile
sed -i '/CONFIG_SING_BOX_WITH_ECH/d' feeds/small/sing-box/Makefile
echo "PassWall 插件切换完成"

#Nikki Mihomo
rm -rf feeds/small/nikki
rm -rf feeds/small/luci-app-nikki
merge_folder main https://github.com/nikkinikki-org/OpenWrt-nikki package/new nikki luci-app-nikki
echo "" >> .config  # 添加一个空行(确保正确换行)
echo "CONFIG_PACKAGE_nikki=y" >> .config
echo "CONFIG_PACKAGE_luci-app-nikki=y" >> .config
echo "Nikki Mihomo 插件操作完成"

# Naiveproxy 缺少x86编译失败版本回退
sed -i 's/140.0.7339.123-2/140.0.7339.123-1/g' feeds/small/naiveproxy/Makefile

#AdguardHome指定commits
#rm -rf feeds/kenzo/adguardhome
#rm -rf feeds/kenzo/luci-app-adguardhome
#merge_commits master https://github.com/kenzok8/openwrt-packages 114ee35443ccb8e0fbb92027134c3887feec9b37 feeds/kenzo adguardhome
#merge_commits master https://github.com/kenzok8/openwrt-packages 915f448b80ee1adb928a5cfd58c33c678abacb5c feeds/kenzo luci-app-adguardhome
#echo "AdguardHome 插件切换完成"

# ppp - 2.5.0
#rm -rf package/network/services/ppp
#git clone https://github.com/sbwml/package_network_services_ppp package/network/services/ppp
#echo "ppp 插件切换完成"

# curl
rm -rf feeds/packages/net/curl
git clone https://github.com/sbwml/feeds_packages_net_curl feeds/packages/net/curl

# 替换curl修改版（无nghttp3、ngtcp2）
curl_ver=$(cat feeds/packages/net/curl/Makefile | grep -i "PKG_VERSION:=" | awk 'BEGIN{FS="="};{print $2}')
[ "$(check_ver "$curl_ver" "8.12.0")" != "0" ] && {
	echo "替换curl版本"
	rm -rf feeds/packages/net/curl
	cp -rf ${GITHUB_WORKSPACE}/patches/curl feeds/packages/net/curl
}

# apk-tools APK管理器不再校验版本号的合法性
mkdir -p package/system/apk/patches && cp -f ${GITHUB_WORKSPACE}/patches/apk-tools/9999-hack-for-linux-pre-releases.patch package/system/apk/patches/

# Lukcy大吉
#rm -rf feeds/kenzo/luci-app-lucky
#git clone https://github.com/sirpdboy/luci-app-lucky package/lucky-packages
### git clone https://github.com/gdy666/luci-app-lucky.git package/lucky-packages

# 移动 WOL 到 “网络” 子菜单
sed -i 's/services/network/g' feeds/luci/applications/luci-app-wol/root/usr/share/luci/menu.d/luci-app-wol.json

# luci-app-wrtbwmon拉取插件
#merge_folder main https://github.com/kenzok8/jell package/new luci-app-wrtbwmon wrtbwmon
#sed -i 's/network/status/g' package/new/luci-app-wrtbwmon/root/usr/share/luci/menu.d/luci-app-wrtbwmon.json
#sed -i '1,$c\
#{\
#	"protocol": "ipv4",\
#	"interval": "2",\
#	"showColumns": [\
#		"thClient",\
#		"thDownload",\
#		"thUpload",\
#		"thTotalDown",\
#		"thTotalUp",\
#		"thTotal"\
#	],\
#	"showZero": true,\
#	"useBits": false,\
#	"useMultiple": "1000",\
#	"useDSL": false,\
#	"upstream": "100",\
#	"downstream": "100",\
#	"hideMACs": [\
#		"00:00:00:00:00:00"\
#	]\
#}' package/new/luci-app-wrtbwmon/root/etc/luci-wrtbwmon.conf

#echo "luci-app-wrtbwmon 插件拉取完成"

# LuCI Bandix 流量监控
merge_folder main https://github.com/timsaya/openwrt-bandix package/new openwrt-bandix
merge_folder main https://github.com/timsaya/luci-app-bandix package/new luci-app-bandix
sed -i 's/network/status/g' package/new/luci-app-bandix/root/usr/share/luci/menu.d/luci-app-bandix.json
echo "" >> .config  # 添加一个空行(确保正确换行)
echo "CONFIG_PACKAGE_bandix=y" >> .config
echo "CONFIG_PACKAGE_luci-app-bandix=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-bandix-zh-cn=y" >> .config

echo "LuCI Bandix 流量监控 插件拉取完成"

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

# 精简 UPnP 菜单名称
sed -i 's#\"title\": \"UPnP IGD \& PCP\"#\"title\": \"UPnP\"#g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json
# 移动 UPnP 到 “网络” 子菜单
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json

# node - prebuilt
rm -rf feeds/packages/lang/node
git clone https://$github/sbwml/feeds_packages_lang_node-prebuilt feeds/packages/lang/node -b packages-24.10

## GCC Optimization level -O3
#curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/target-modify_for_x86_64.patch | patch -p1

## patch source
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/generic-24.10/0001-tools-add-upx-tools.patch | patch -p1
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/generic-24.10/0002-rootfs-add-upx-compression-support.patch | patch -p1
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/generic-24.10/0003-rootfs-add-r-w-permissions-for-UCI-configuration-fil.patch | patch -p1
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/generic-24.10/0004-rootfs-Add-support-for-local-kmod-installation-sourc.patch | patch -p1
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/generic-24.10/0005-kernel-Add-support-for-llvm-clang-compiler.patch | patch -p1
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/generic-24.10/0006-build-kernel-add-out-of-tree-kernel-config.patch | patch -p1
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/generic-24.10/0007-include-kernel-add-miss-config-for-linux-6.11.patch | patch -p1
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/generic-24.10/0008-meson-add-platform-variable-to-cross-compilation-fil.patch | patch -p1
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/generic-24.10/0009-kernel-add-legacy-cgroup-v1-memory-controller.patch | patch -p1
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/generic-24.10/0010-kernel-add-PREEMPT_RT-support-for-aarch64-x86_64.patch | patch -p1

## perf
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/openwrt-6.x/musl/990-add-typedefs-for-Elf64_Relr-and-Elf32_Relr.patch > toolchain/musl/patches/990-add-typedefs-for-Elf64_Relr-and-Elf32_Relr.patch
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/openwrt-6.x/perf/Makefile > package/devel/perf/Makefile

## libpfring
rm -rf feeds/packages/libs/libpfring
mkdir -p feeds/packages/libs/libpfring/patches
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/packages-patches/libpfring/Makefile > feeds/packages/libs/libpfring/Makefile
pushd feeds/packages/libs/libpfring/patches
  curl -Os https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/packages-patches/libpfring/patches/0001-fix-cross-compiling.patch
  curl -Os https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/packages-patches/libpfring/patches/100-fix-compilation-warning.patch
  curl -Os https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/packages-patches/libpfring/patches/900-fix-linux-6.6.patch
popd

# DPDK
merge_folder master https://github.com/sbwml/r4s_build_script package/new openwrt/patch/dpdk/dpdk openwrt/patch/dpdk/numactl
echo "DPDK 插件拉取完成"

# kselftests-bpf
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/packages-patches/kselftests-bpf/Makefile > package/devel/kselftests-bpf/Makefile

# SQM Translation
mkdir -p feeds/packages/net/sqm-scripts/patches
curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/sqm/001-help-translation.patch > feeds/packages/net/sqm-scripts/patches/001-help-translation.patch

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
    
    # xtables-addons module
    rm -rf feeds/packages/net/xtables-addons
    git clone https://$github/sbwml/kmod_packages_net_xtables-addons feeds/packages/net/xtables-addons
    
    # netatop
    sed -i 's/$(MAKE)/$(KERNEL_MAKE)/g' feeds/packages/admin/netatop/Makefile
    curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/packages-patches/clang/netatop/900-fix-build-with-clang.patch > feeds/packages/admin/netatop/patches/900-fix-build-with-clang.patch
    
    # dmx_usb_module
    rm -rf feeds/packages/libs/dmx_usb_module
    git clone https://$gitea/sbwml/feeds_packages_libs_dmx_usb_module feeds/packages/libs/dmx_usb_module
    
    # macremapper
    curl -s https://raw.githubusercontent.com/smdx/X86_64-Actions/refs/heads/main/patches/packages-patches/clang/macremapper/100-macremapper-fix-clang-build.patch | patch -p1
    # coova-chilli module
    rm -rf feeds/packages/net/coova-chilli
    git clone https://$github/sbwml/kmod_packages_net_coova-chilli feeds/packages/net/coova-chilli
else
    echo "CONFIG_USE_LTO is not set, skipping..."
fi

echo "插件自定义操作执行完毕"

# 添加主题
# argon
rm -rf feeds/kenzo/luci-app-argon-config
rm -rf feeds/kenzo/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-argon
merge_folder openwrt-24.10 https://github.com/sbwml/luci-theme-argon package/new luci-app-argon-config luci-theme-argon
echo "luci-theme-argon 替换完成"

# git clone https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom.git package/luci-theme-infinityfreedom
# git clone https://github.com/Leo-Jo-My/luci-theme-opentomcat.git package/luci-theme-opentomcat

# 取消自添加主题的默认设置
# find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

# 设置默认主题
# default_theme='Argon'
# sed -i "s/bootstrap/$default_theme/g" feeds/luci/modules/luci-base/root/etc/config/luci

# 修正部分从第三方仓库拉取的软件 Makefile 路径问题
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/rust\/rust-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/rust\/rust-package.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

#echo 'refresh feeds'
#./scripts/feeds update -a
#./scripts/feeds install -a

echo "========================="
echo " DIY2 配置完成……"