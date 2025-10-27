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

echo "开始 DIY1 配置……"
echo "========================="

chmod +x ${GITHUB_WORKSPACE}/scripts/function.sh
source ${GITHUB_WORKSPACE}/scripts/function.sh

# Add a feed source
sed -i 's/Os/O2 -march=x86-64-v2 -ftree-vectorize -fno-strict-aliasing/g' include/target.mk

# 使用动态抢占
cat >> target/linux/x86/config-6.6 <<-EOF
CONFIG_PREEMPT_DYNAMIC=y
EOF
cat >> target/linux/x86/64/config-6.6 <<-EOF
CONFIG_PREEMPT_DYNAMIC=y
EOF

#openssl replace version 3.5.0
# rm -rf package/libs/openssl
# merge_folder master https://github.com/immortalwrt/immortalwrt package/libs/ package/libs/openssl
#openssl Enable QUIC and KTLS support
# openssl_ver=$(cat package/libs/openssl/Makefile | grep -i "PKG_VERSION:=" | awk 'BEGIN{FS="="};{print $2}')
# [ "$(check_ver "$openssl_ver" "3.5.0")" != "0" ] && {
	# curl -s https://github.com/openwrt/openwrt/commit/362aea4649485ca7c31ce42c371d5051e7dead4d.patch | patch -p1
	# pushd package/libs/openssl/patches
	# curl -sSL https://github.com/openssl/openssl/commit/99ea6b38430dc977ba63c832694cdb3c2cb3c2c9.patch -o 900-Add-NULL-check-in-ossl_quic_get_peer_token.patch
	# popd
# }

sed -i '1isrc-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2isrc-git small https://github.com/kenzok8/small' feeds.conf.default
sed -i '3isrc-git zzz https://github.com/blueberry-pie-11/luci-app-natmap'  feeds.conf.default

#sed -i '1isrc-git mosdns https://github.com/sbwml/luci-app-mosdns'  feeds.conf.default
#sed -i '3isrc-git helloworld https://github.com/sbwml/openwrt_helloworld' feeds.conf.default
# echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall;luci-smartdns-dev' >>feeds.conf.default

echo "========================="
echo " DIY1 配置完成……"