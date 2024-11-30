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

# x86 型号只显示 CPU 型号
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/emortal/autocore/files/x86/autocore

#修正连接数（by ベ七秒鱼ベ）
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

#修复NAT回流
#sed -i '/customized in this file/a net.bridge.bridge-nf-call-arptables=0' package/base-files/files/etc/sysctl.conf
#sed -i '/customized in this file/a net.bridge.bridge-nf-call-ip6tables=0' package/base-files/files/etc/sysctl.conf
#sed -i '/customized in this file/a net.bridge.bridge-nf-call-iptables=0' package/base-files/files/etc/sysctl.conf

#PVE VirtIO半虚拟网卡状态页显示半双工修改
sed -i '/exit 0/i ethtool -s eth0 speed 2500 duplex full\nethtool -s eth1 speed 2500 duplex full' package/base-files/files/etc/rc.local

# 设置ttyd免帐号登录
#uci set ttyd.@ttyd[0].command='/bin/login -f root'
#uci commit ttyd

#nlbwmon 修复log警报
#sed -i '/customized in this file/a net.core.rmem_default=16777216' package/base-files/files/etc/sysctl.conf
#sed -i '/customized in this file/a net.core.wmem_default=16777216' package/base-files/files/etc/sysctl.conf
#sed -i '/customized in this file/a net.core.rmem_max=16777216' package/base-files/files/etc/sysctl.conf
#sed -i '/customized in this file/a net.core.wmem_max=16777216' package/base-files/files/etc/sysctl.conf

# MSD组播转换luci
rm -rf feeds/luci/applications/luci-app-msd_lite
git clone https://github.com/lwb1978/luci-app-msd_lite package/luci-app-msd_lite

# 替换udpxy为修改版，解决组播源数据有重复数据包导致的花屏和马赛克问题
rm -rf feeds/packages/net/udpxy/Makefile
cp -f ${GITHUB_WORKSPACE}/patches/udpxy/Makefile feeds/packages/net/udpxy/
# 修改 udpxy 菜单名称为大写
#sed -i 's#_(\"udpxy\")#_(\"UDPXY\")#g' feeds/luci/applications/luci-app-udpxy/luasrc/controller/udpxy.lua

# 移除要替换的包
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang

# 插件切换到指定版本
echo "开始执行切换插件到指定版本"
# Golang
git clone https://github.com/kenzok8/golang feeds/packages/lang/golang
echo "Golang 插件切换完成"

#AdguardHome指定commits
#rm -rf feeds/kenzo/adguardhome
#rm -rf feeds/kenzo/luci-app-adguardhome
#merge_commits master https://github.com/kenzok8/openwrt-packages 114ee35443ccb8e0fbb92027134c3887feec9b37 feeds/kenzo adguardhome
#merge_commits master https://github.com/kenzok8/openwrt-packages 915f448b80ee1adb928a5cfd58c33c678abacb5c feeds/kenzo luci-app-adguardhome
#echo "AdguardHome 插件切换完成"

# IPSet(Lean源码已跟进)
#rm -rf package/network/utils/ipset
#merge_commits main https://github.com/openwrt/openwrt 9f6a28b91e30de9c6875afbe1493934218dbfb49 package/network/utils package/network/utils/ipset
#echo "IPSet 插件切换完成"

#改用MosDNS源码：
rm -rf feeds/small/luci-app-mosdns
rm -rf feeds/small/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
echo "MosDNS 插件切换完成"

#Miniupnpd 替换 (ImmortalWRT源码用)
rm -rf feeds/packages/net/miniupnpd
merge_folder master https://github.com/coolsnowwolf/packages feeds/packages/net net/miniupnpd
echo "Miniupnpd 插件切换完成"

#Dnsmasq 版本替换
rm -rf package/network/services/dnsmasq
merge_folder master https://github.com/coolsnowwolf/lede package/network/services package/network/services/dnsmasq
echo "Dnsmasq 插件切换完成"

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

# DPDK
merge_commits main https://github.com/k13132/openwrt-dpdk e1329c9da0c06cc2994e92b23cd4d21e3a36ac2e package/new packages/dpdk packages/kmod-amd_iommu_v2 packages/kmod-uio_pci_generic packages/kmod-vfio-pci packages/numactl
sed -i '/^define Package\/libdpdk/,/^endef/ s/\(DEPENDS:=.*\)/\1 +libbpf +libelf/' package/new/dpdk/Makefile
echo "DPDK 插件拉取完成"

# luci-app-wrtbwmon
merge_folder master https://github.com/coolsnowwolf/luci feeds/luci/applications applications/luci-app-wrtbwmon
sed -i 's/interval: 5,/interval: 1,/' feeds/luci/applications/luci-app-wrtbwmon/htdocs/luci-static/wrtbwmon/wrtbwmon.js
sed -i 's/<option value="5" selected="selected">5 <%=translate("Seconds")%>/<option value="5">5 <%=translate("Second")%>/' feeds/luci/applications/luci-app-wrtbwmon/luasrc/view/wrtbwmon/wrtbwmon.htm
sed -i 's/<option value="1">1 <%=translate("Second")%>/<option value="1" selected="selected">1 <%=translate("Second")%>/' feeds/luci/applications/luci-app-wrtbwmon/luasrc/view/wrtbwmon/wrtbwmon.htm
echo "Wrtbwmon 插件拉取完成"

echo "插件切换操作执行完毕"

# 移动 nlbwmon 到 状态 子菜单
sed -i 's/services/status/g' feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json

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

# 添加主题
# argon
rm -rf feeds/kenzo/luci-app-argon-config
rm -rf feeds/kenzo/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-argon
merge_folder main https://github.com/sbwml/luci-theme-argon package/openwrt-packages luci-app-argon-config luci-theme-argon
#
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
#./scripts/feeds update -a
#./scripts/feeds install -a
