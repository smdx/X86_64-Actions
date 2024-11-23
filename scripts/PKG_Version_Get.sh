#!/bin/bash
# Package  Version Output to Env
adguardhome_version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' feeds/kenzo/adguardhome/Makefile)
mosdns_version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' package/mosdns/mosdns/Makefile)
smartdns_version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' feeds/kenzo/luci-app-smartdns/Makefile)
passwall_version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' feeds/small/luci-app-passwall/Makefile)
passwall_release=$(grep -oP 'PKG_RELEASE:=\K[^ ]+' feeds/small/luci-app-passwall/Makefile)
passwall2_version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' feeds/small/luci-app-passwall2/Makefile)
passwall2_release=$(grep -oP 'PKG_RELEASE:=\K[^ ]+' feeds/small/luci-app-passwall2/Makefile)
openclash_version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' feeds/small/luci-app-openclash/Makefile)
store_version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' feeds/kenzo/luci-app-store/Makefile)
echo "adguardhome=$adguardhome_version" >> $GITHUB_ENV
echo "mosdns=$mosdns_version" >> $GITHUB_ENV
echo "smartdns=$smartdns_version" >> $GITHUB_ENV
echo "passwall_version=${passwall_version}-${passwall_release}" >> $GITHUB_ENV
echo "passwall2_version=${passwall2_version}-${passwall_release}" >> $GITHUB_ENV
echo "openclash=$openclash_version" >> $GITHUB_ENV
echo "store=$store_version" >> $GITHUB_ENV
