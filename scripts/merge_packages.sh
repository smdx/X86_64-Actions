function merge_package(){
    # 参数1是分支名,参数2是库地址。所有文件下载到openwrt/package/openwrt-packages路径。
    # 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
    trap 'rm -rf "$tmpdir"' EXIT
    branch="$1" curl="$2" && shift 2
    rootdir="$PWD"
    localdir=package/openwrt-packages
    [ -d "$localdir" ] || mkdir -p "$localdir"
    tmpdir="$(mktemp -d)" || exit 1
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
    cd "$tmpdir"
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    mv -f "$@" "$rootdir"/"$localdir" && cd "$rootdir"
}
merge_package main https://github.com/sbwml/luci-theme-argon luci-app-argon-config luci-theme-argon