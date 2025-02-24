#! /bin/bash

pacman -Qi | awk '/^Name/{name=$3}/^Installed Size/{size=$4 $5} /^$/ {print size, name}' | sort -rh
