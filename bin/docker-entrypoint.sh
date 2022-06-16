#!/bin/sh
tmpfile=$(mktemp /tmp/opa-input.XXXXXX)
exec 3>"$tmpfile"
exec 4<"$tmpfile"
rm "$tmpfile"

cat /var/opt/opa/input.json | sed "s/GH_TOKEN/$GH_TOKEN/" >&3

exec /opt/opa/opa eval -I -b github $@ <&4
