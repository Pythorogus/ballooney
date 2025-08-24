#!/bin/sh
echo -ne '\033c\033]0;Inflatus\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Inflatus.x86_64" "$@"
