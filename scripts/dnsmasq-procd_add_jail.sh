#!/bin/bash

# 指定文件路径
file_path="$GITHUB_WORKSPACE/openwrt/package/network/services/dnsmasq/files/dnsmasq.init"

# 要查找的内容
search_text="procd_add_jail"

# 使用grep查找匹配的行
matching_lines=$(grep -n "$search_text" "$file_path" | cut -d ":" -f 1)

# 循环处理每一行
for line_number in $matching_lines
do
    # 在匹配行前添加#号注释
    sed -i "${line_number}s/^/#/" "$file_path"
done

echo "注释添加完成"
