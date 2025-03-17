#!/bin/bash

# 定义插件列表
plugins=(
    "adguardhome"
    "mosdns"
    "smartdns"
    "luci-app-store"
    "luci-app-passwall"
    "luci-app-passwall2"
    "luci-app-fchomo"
    "luci-app-mihomo"
    "luci-app-openclash"
    "luci-app-zerotier"
    "luci-app-watchcat"
    "luci-app-wireguard"
)

# 定义需要自定义目录名称的插件映射（插件名:目录名称）
# 示例：["luci-app-fchomo"]="mihomo"   将luci-app-fchomo的目录名称指定为mihomo
declare -A custom_dir_names=(
    ["luci-app-fchomo"]="mihomo"
    ["luci-app-zerotier"]="zerotier"
    ["luci-app-watchcat"]="watchcat"
    ["luci-app-wireguard"]="wireguard-tools"
)

# 遍历插件
for plugin in "${plugins[@]}"; do
    # 检查是否存在自定义目录名称
    if [[ -n "${custom_dir_names[$plugin]}" ]]; then
        dir_name="${custom_dir_names[$plugin]}"
        echo "检查自定义目录名称: $dir_name (插件: $plugin)"
        # 在package和feeds目录下查找指定名称的目录
        dir=$(find package feeds -maxdepth 3 -type d -name "$dir_name" -print -quit)
        if [[ -z "$dir" ]]; then
            echo "未找到自定义目录名称对应的目录: $dir_name"
            continue
        fi
        echo "找到自定义目录: $dir"
    else
        # 默认查找逻辑：在package和feeds中查找插件目录
        dir=$(find package feeds -maxdepth 3 -type d -name "$plugin" -print -quit)
        # 检查目录是否存在
        if [[ -z "$dir" ]]; then
            echo "未找到插件目录: $plugin"
            continue
        fi
    fi

    # 检查Makefile路径
    makefile="$dir/Makefile"
    if [[ ! -f "$makefile" ]]; then
        # 尝试在目录下的同名子目录查找
        makefile="$dir/$plugin/Makefile"
        if [[ -f "$makefile" ]]; then
            dir="$dir/$plugin"
            echo "找到下一级目录: $dir"
        else
            echo "未找到Makefile: $plugin"
            continue
        fi
    fi

    # 读取版本信息
    version=$(grep -oP 'PKG_VERSION:=\K[^ ]+' "$makefile")
    # 读取PKG_RELEASE（可选）
    release=$(grep -oP 'PKG_RELEASE:=\K[^ ]+' "$makefile" || true)

    # 清理插件名（去除luci-app-前缀）
    clean_name=${plugin/luci-app-/}

    # 验证版本信息
    if [[ -z "$version" ]]; then
        echo "未找到版本信息: $plugin"
        continue
    fi

    # 输出到环境变量文件
    if [[ -n "$release" ]]; then
        echo "${clean_name}=${version}-${release}" >> $GITHUB_ENV
    else
        # 如果没有 PKG_RELEASE，则只输出版本
        echo "${clean_name}=${version}" >> $GITHUB_ENV
    fi
done