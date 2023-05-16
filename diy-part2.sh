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
# Modify default IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 设置密码为空
sed -i '/CYXluq4wUazHjmCDBCqXF/d' package/lean/default-settings/files/zzz-default-settings

#修正连接数（by ベ七秒鱼ベ）
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

#修复NAT回流
sed -i '/customized in this file/a net.bridge.bridge-nf-call-arptables=0' package/base-files/files/etc/sysctl.conf
sed -i '/customized in this file/a net.bridge.bridge-nf-call-ip6tables=0' package/base-files/files/etc/sysctl.conf
sed -i '/customized in this file/a net.bridge.bridge-nf-call-iptables=0' package/base-files/files/etc/sysctl.conf

#注释防火墙自定义53转发规则
sed -i 's/iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53/#iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53/g' package/lean/default-settings/files/zzz-default-settings
sed -i 's/iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53/#iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53/g' package/lean/default-settings/files/zzz-default-settings
sed -i 's/\[ -n "$(command -v ip6tables)" \] && ip6tables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53/#\[ -n "$(command -v ip6tables)" \] \&\& ip6tables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53/g' package/lean/default-settings/files/zzz-default-settings
sed -i 's/\[ -n "$(command -v ip6tables)" \] && ip6tables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53/#\[ -n "$(command -v ip6tables)" \] \&\& ip6tables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53/g' package/lean/default-settings/files/zzz-default-settings

#nlbwmon 修复log警报
sed -i '/customized in this file/a net.core.wmem_max=16777216' package/base-files/files/etc/sysctl.conf
sed -i '/customized in this file/a net.core.rmem_max=16777216' package/base-files/files/etc/sysctl.conf

# git clone https://github.com/kenzok8/openwrt-packages.git package/openwrt-packages
# git clone https://github.com/kenzok8/small.git package/small-package

# git clone https://github.com/linkease/istore.git package/istore
# sed -i 's/luci-lib-ipkg/luci-base/g' package/feeds/kenzok/luci-app-store/Makefile

# git clone https://github.com/kiddin9/openwrt-bypass.git package/luci-app-bypass

###sirpdboy###
# git clone https://github.com/sirpdboy/sirpdboy-package.git package/sirpdboy-package
git clone https://github.com/sirpdboy/luci-theme-opentopd.git package/luci-theme-opentopd
git clone https://github.com/sirpdboy/luci-app-advanced.git package/luci-app-advanced
git clone https://github.com/sirpdboy/netspeedtest.git package/netspeedtest
# git clone https://github.com/sirpdboy/luci-app-netdata.git package/luci-app-netdata
git clone https://github.com/sirpdboy/luci-app-poweroffdevice.git package/luci-app-poweroffdevice
# git clone https://github.com/sirpdboy/luci-app-autotimeset.git package/luci-app-autotimeset


# themes添加（svn co 命令意思：指定版本如https://github）
git clone https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom.git package/luci-theme-infinityfreedom
# git clone https://github.com/Leo-Jo-My/luci-theme-opentomcat.git package/luci-theme-opentomcat
# git clone https://github.com/openwrt-develop/luci-theme-atmaterial.git package/luci-theme-atmaterial
# Add luci-theme-argon
# git clone https://github.com/kiddin9/luci-app-dnsfilter.git package/luci-app-dnsfilter


# 添加额外非必须软件包
# git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome
# git clone https://github.com/vernesong/OpenClash.git package/OpenClash
# git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
# git clone https://github.com/zzsj0928/luci-app-pushbot.git package/luci-app-pushbot
# git clone https://github.com/riverscn/openwrt-iptvhelper.git package/openwrt-iptvhelper
# git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/luci-app-unblockneteasemusic
# git clone https://github.com/jerrykuku/luci-app-jd-dailybonus.git package/luci-app-jd-dailybonus

# Smartdns
rm -rf package/luci-app-smartdns
rm -rf package/lean/luci-app-smartdns
rm -rf feeds/luci/applications/luci-app-smartdns
rm -rf package/smartdns
rm -rf package/lean/smartdns
rm -rf feeds/luci/applications/smartdns

git clone https://github.com/pymumu/openwrt-smartdns.git package/smartdns
git clone -b lede https://github.com/pymumu/luci-app-smartdns.git package/luci-app-smartdns
