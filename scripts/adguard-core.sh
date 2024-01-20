#!/bin/bash

mkdir -p $GITHUB_WORKSPACE/files/usr/bin/AdGuardHome

AGH_CORE=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | grep /AdGuardHome_linux_${1} | awk -F '"' '{print $4}')

wget -qO- $AGH_CORE | tar xOvz > $GITHUB_WORKSPACE/files/usr/bin/AdGuardHome/AdGuardHome

chmod +x $GITHUB_WORKSPACE/files/usr/bin/AdGuardHome/AdGuardHome
