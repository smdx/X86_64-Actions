#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Uncomment a feed source
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
sed -i 's/Os/O2 -march=x86-64-v2 -ftree-vectorize -fno-strict-aliasing/g' include/target.mk

# 使用动态抢占
cat >> target/linux/x86/config-6.6 <<-EOF
CONFIG_PREEMPT_DYNAMIC=y
EOF
cat >> target/linux/x86/64/config-6.6 <<-EOF
CONFIG_PREEMPT_DYNAMIC=y
EOF

echo "克隆 YAOF"
git clone -b 24.10 --depth 1 https://github.com/QiuSimons/YAOF /workdir/.YAOF

# echo "打打补丁~"
### 必要的 Patches FROM YAOF ###
# TCP optimizations
cp -rf /workdir/.YAOF/PATCH/kernel/6.7_Boost_For_Single_TCP_Flow/* ./target/linux/generic/backport-6.6/
cp -rf /workdir/.YAOF/PATCH/kernel/6.8_Boost_TCP_Performance_For_Many_Concurrent_Connections-bp_but_put_in_hack/* ./target/linux/generic/hack-6.6/
cp -rf /workdir/.YAOF/PATCH/kernel/6.8_Better_data_locality_in_networking_fast_paths-bp_but_put_in_hack/* ./target/linux/generic/hack-6.6/
# UDP
cp -rf /workdir/.YAOF/PATCH/kernel/6.7_FQ_packet_scheduling/* ./target/linux/generic/backport-6.6/
# BBRv3
cp -rf /workdir/.YAOF/PATCH/kernel/bbr3/* ./target/linux/generic/hack-6.6/
# fullcore
cp -rf /workdir/.YAOF/PATCH/kernel/bcmfullcone/* ./target/linux/generic/hack-6.6/

sed -i '1isrc-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2isrc-git small https://github.com/kenzok8/small' feeds.conf.default
sed -i '3isrc-git zzz https://github.com/blueberry-pie-11/luci-app-natmap'  feeds.conf.default

#sed -i '1isrc-git mosdns https://github.com/sbwml/luci-app-mosdns'  feeds.conf.default
#sed -i '3isrc-git helloworld https://github.com/sbwml/openwrt_helloworld' feeds.conf.default
# echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall;luci-smartdns-dev' >>feeds.conf.default