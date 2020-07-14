#!/usr/local/bin/env bash
# Usage: su
# 	 ./init_bsd_zmos.sh

set -xeuo pipefail

export USERNAME=$USER
export PROXY_IP="192.168.0.182"

function user_run {
    sudo -u $USERNAME $0 $*
}

# function root_mode {
#     [ x`id -u` = x0 ] || {
# 	echo "ERROR: You need to provide password to run as root!" >&2
#         sudo $0 $*
#         exit $?
#     }
# }

function inst_ZMOS
{
    # cd ~
    # user_run git clone https://github.com/$USERNAME/ZMOS.git
    # cd ~/ZMOS
    ./XDE/install-xde.sh
    user_run ./XDE/user-xde.sh
}

function inst_workbench
{
    cd ~
    git clone 192.168.0.103:~/Dropbox/Software/noesworkbench.git
    cd noesworkbench
    ./install_all.sh
}

mkdir -p /usr/local/etc/pkg/repos
cat > /usr/local/etc/pkg/repos/FreeBSD.conf <<EOF
FreeBSD: {
  url: "pkg+http://mirrors.ustc.edu.cn/freebsd-pkg/${ABI}/quarterly",
}

EOF

pkg update
pkg install -y proxychains sudo
sed -i -e "s/socks4.*127.0.0.1.*9050$/socks5 	$PROXY_IP 1080/g" /usr/local/etc/proxychains.conf
sed -i -e 's/#quiet_mode/quiet_mode/g' /usr/local/etc/proxychains.conf
sed -i -e "s/^# %wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) ALL/g" /usr/local/etc/sudoers

pkg install -y git tmux bash zsh coreutils emacs-devel nerd-font sakura sbcl

user_run chsh -s /usr/local/bin/zsh

user_run inst_workbench
inst_ZMOS
