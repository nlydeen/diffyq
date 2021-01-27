#!/usr/bin/env nix-shell
#!nix-shell -i sh -p webfs

nix-build && webfsd -F -p 8080 -r result
