cat > /files/etc/uci-defaults/zzz-conntrack << "EOF"
#!/bin/sh
  
sed -i 's/net.nf_conntrack_max/net.netfilter.nf_conntrack_max/g' /usr/lib/lua/luci/view/admin_status/index.htm
EOF
