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


sed -i '1isrc-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2isrc-git small https://github.com/kenzok8/small' feeds.conf.default
sed -i '3isrc-git zzz https://github.com/blueberry-pie-11/luci-app-natmap'  feeds.conf.default

#sed -i '1isrc-git mosdns https://github.com/sbwml/luci-app-mosdns'  feeds.conf.default
#sed -i '3isrc-git helloworld https://github.com/sbwml/openwrt_helloworld' feeds.conf.default
# echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall;luci-smartdns-dev' >>feeds.conf.default
