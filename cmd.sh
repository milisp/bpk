#!/bin/bash
set -e

script_dir=$(dirname "$(readlink "$0")")
pkgs_dir="$script_dir/pkgs"
cache_dir=~/.cache/bpk
export TARGET_DIR=$HOME/.local/etc
export BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
platform="$(uname -m)"
force=0

mkdir -p "$cache_dir"
mkdir -p "$TARGET_DIR"
mkdir -p "$BIN_DIR"

extract() {
    if [ -f "$filepath" ]; then
        case $filename in
            *.tar.gz|*.tar.xz )
                tar xf "$filepath" -C "$TARGET_DIR";;
            *.pkg )
                sudo installer -pkg "$filepath" -target /;;
            *.dmg )
                hdiutil attach "$filepath"
                ;;
            *)
                echo no recognize;;
        esac
    fi
}

get_info_str() {
    info_prefix="^$1:"
    command_str=$(grep "${info_prefix}" "$pkgs_dir/$pkg/info")
    cmd_len=${#command_str}
    info_str=${command_str[*]:2:$cmd_len}
}

remove_old_version() {
    # echo "rm old version"
    get_info_str "p"
    echo "$info_str"
    # ls $TARGET_DIR/$info_str*
    if [ -n "$info_str" ]; then
        # echo "rm"
        eval "rm -r $TARGET_DIR/$info_str*"
    else
        get_info_str "r"
        echo "$info_str"
        echo "rm r"
    fi
}

install_pkg() {
    pkg=$1
    pkg_dir="$pkgs_dir/$pkg"
    if [ -f "$pkg_dir"/url ]; then
        if ( grep -q -e all "$pkg_dir"/url ); then
            platform_url="$(grep all "$pkg_dir"/url)"
        else
            platform_url=$(grep "$platform" "$pkg_dir"/url)
        fi
        url_template=$(echo "$platform_url" | cut -d "|" -f2)
        if [ -f "$pkg_dir"/version ]; then
            version="$(tail -n 1 "$pkg_dir"/version | cut -d '|' -f1)"
        else
            if [ -f "$pkg_dir"/"${platform}"_version ]; then
                version="$(tail -n 1 "$pkg_dir"/"${platform}"_version | cut -d'|' -f1)"
            else
                echo version no exists
                exit
            fi
        fi
        echo "$version"
        url="${url_template//\#v/$version}"
        echo "$url"
        filename=$(echo "$url" | awk -F '/' '{print $NF}')
        echo "$filename"
        filepath=$cache_dir/$filename
        curl -L -C - -o "$filepath" "$url"
        remove_old_version
        extract
        # link and other: eg. detach
        if [ -f "$pkg_dir/link.sh" ]; then
            echo link
            bash "$pkg_dir/link.sh"
        fi
    else
        echo "$pkg_dir/url doesn't exists"
    fi
}

install_all() {
    for pkg in "$@"; do
        if [ "$force" -gt 0 ]; then
            install_pkg "$pkg"
        else
            if command -v "$pkg" &> /dev/null
            then
                type "$pkg"
                echo "$pkg already exists, use -f to force install."
            else
                if [ -f "$pkgs_dir/$pkg"/info ]; then
                    get_info_str "c"
                    # check pkgs/$pkg/info startwith c:
                    if command -v "$info_str" &> /dev/null
                    then
                        echo "$pkg" already exists
                    else
                        #echo install
                        install_pkg "$pkg"
                    fi
                else
                    echo "$pkg -- no info yet"
                fi
            fi
        fi
    done
}

case $1 in
    i|install)
       shift
       if [ "$1" = "-f" ]; then
           shift
           force=1
       fi
       if [ $# -gt 0 ]; then
           install_all "$@"
       else
           echo "no pkg"
       fi
       ;;
   s|search)
       shift
       echo "search"
       cat "$pkgs_dir/$1/info"
       ;;
   info)
       shift
       if [ -f "$pkgs_dir/$1/info" ]; then
           cat "$pkgs_dir/$1/info"
       fi
       ;;
   l|list)
       ls "$pkgs_dir"
       ;;
   *)
       echo help
esac
