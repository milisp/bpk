#!/bin/bash
set -e

TARGET_DIR=${TARGET_DIR:-$HOME/.local/etc}
echo "$TARGET_DIR"/xh-v*
path="$HOME/.local/etc/xh-v*"
echo "$path"
if ls "$path"  &> /dev/null
then
    echo 1
else
    echo 0
fi
