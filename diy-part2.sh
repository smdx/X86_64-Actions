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

# Modify default IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 设置密码为空
sed -i '/CYXluq4wUazHjmCDBCqXF/d' package/lean/default-settings/files/zzz-default-settings

# x86 型号只显示 CPU 型号
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

#修正连接数（by ベ七秒鱼ベ）
#sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

#修复NAT回流
#sed -i '/customized in this file/a net.bridge.bridge-nf-call-arptables=0' package/base-files/files/etc/sysctl.conf
#sed -i '/customized in this file/a net.bridge.bridge-nf-call-ip6tables=0' package/base-files/files/etc/sysctl.conf
#sed -i '/customized in this file/a net.bridge.bridge-nf-call-iptables=0' package/base-files/files/etc/sysctl.conf

#注释防火墙自定义53转发规则
sed -i 's/iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53/# iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53/g' package/lean/default-settings/files/zzz-default-settings
sed -i 's/iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53/# iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53/g' package/lean/default-settings/files/zzz-default-settings
sed -i 's/\[ -n "$(command -v ip6tables)" \] && ip6tables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53/# \[ -n "$(command -v ip6tables)" \] \&\& ip6tables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53/g' package/lean/default-settings/files/zzz-default-settings
sed -i 's/\[ -n "$(command -v ip6tables)" \] && ip6tables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53/# \[ -n "$(command -v ip6tables)" \] \&\& ip6tables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53/g' package/lean/default-settings/files/zzz-default-settings

#在防火墙自定义添加FTP规则 9099端口对应FTP转发端口
sed -i '46a echo '\''iptables -t raw -A PREROUTING -p tcp --dport 9099 -j CT --helper ftp'\'' >> /etc/firewall.user\n' package/lean/default-settings/files/zzz-default-settings

#防止init.d目录下权限问题
sed -i '60a\\nchmod 0755 /etc/init.d/*' package/lean/default-settings/files/zzz-default-settings

#PVE VirtIO半虚拟网卡状态页显示半双工修改
sed -i '/exit 0/i ethtool -s eth0 speed 2500 duplex full\nethtool -s eth1 speed 2500 duplex full' package/base-files/files/etc/rc.local

#nlbwmon 修复log警报
#sed -i '/customized in this file/a net.core.rmem_default=16777216' package/base-files/files/etc/sysctl.conf
#sed -i '/customized in this file/a net.core.wmem_default=16777216' package/base-files/files/etc/sysctl.conf
#sed -i '/customized in this file/a net.core.rmem_max=16777216' package/base-files/files/etc/sysctl.conf
#sed -i '/customized in this file/a net.core.wmem_max=16777216' package/base-files/files/etc/sysctl.conf

# Git稀疏克隆，只克隆指定目录到本地
#function git_sparse_clone() {
#  branch="$1" repourl="$2" && shift 2
#  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
#  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
#  cd $repodir && git sparse-checkout set $@
#  mv -f $@ ../package
#  cd .. && rm -rf $repodir
#}

# 移除要替换的包
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang


# 插件切换到指定版本 
# Golang
git clone https://github.com/kenzok8/golang feeds/packages/lang/golang

# OpenSSL
#pushd package/libs/openssl
#git checkout 4fd8d7b7f8b7752ba8bb06e0d43808d0c5fddde0
#popd

# curl
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=8.5.0/g' feeds/packages/net/curl/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=ce4b6a6655431147624aaf582632a36fe1ade262d5fab385c60f78942dd8d87b/g' feeds/packages/net/curl/Makefile
#sed -i 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/net/curl/Makefile

# gn
#sed -i 's/PKG_SOURCE_DATE:=.*/PKG_SOURCE_DATE:=2023-11-17/g' feeds/small/gn/Makefile
#sed -i 's/PKG_SOURCE_VERSION:=.*/PKG_SOURCE_VERSION:=7367b0df0a0aa25440303998d54045bda73935a5/g' feeds/small/gn/Makefile
#sed -i 's/PKG_MIRROR_HASH:=.*/PKG_MIRROR_HASH:=c11eb62d257f9e41d29139d66e94d3798b013a650dd493ae8759c57e2e64cfd1/g' feeds/small/gn/Makefile

# 添加额外非必须软件包
#
# git clone https://github.com/linkease/istore.git package/istore
# sed -i 's/luci-lib-ipkg/luci-base/g' package/feeds/kenzok/luci-app-store/Makefile

###sirpdboy###
# git clone https://github.com/sirpdboy/sirpdboy-package.git package/sirpdboy-package
# git clone https://github.com/sirpdboy/luci-theme-opentopd.git package/luci-theme-opentopd
# git clone https://github.com/sirpdboy/luci-app-advanced.git package/luci-app-advanced
# git clone https://github.com/sirpdboy/netspeedtest.git package/netspeedtest
# git clone https://github.com/sirpdboy/luci-app-netdata.git package/luci-app-netdata
# git clone https://github.com/sirpdboy/luci-app-poweroffdevice.git package/luci-app-poweroffdevice
# git clone https://github.com/sirpdboy/luci-app-autotimeset.git package/luci-app-autotimeset

# themes添加（svn co 命令意思：指定版本如https://github）
# git clone https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom.git package/luci-theme-infinityfreedom
# git clone https://github.com/Leo-Jo-My/luci-theme-opentomcat.git package/luci-theme-opentomcat
# git clone https://github.com/openwrt-develop/luci-theme-atmaterial.git package/luci-theme-atmaterial
# git clone https://github.com/kiddin9/luci-app-dnsfilter.git package/luci-app-dnsfilter

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
#./scripts/feeds update -a
#./scripts/feeds install -a
