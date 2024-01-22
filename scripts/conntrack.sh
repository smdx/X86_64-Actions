#!/bin/bash

sed -i 's/net.nf_conntrack_max/net.netfilter.nf_conntrack_max/g' $GITHUB_WORKSPACE/openwrt/package/lean/autocore/files/x86/index.htm
sed -i 's/net.nf_conntrack_max/net.netfilter.nf_conntrack_max/g' $GITHUB_WORKSPACE/openwrt/feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
