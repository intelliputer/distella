#!/bin/sh
set -eu

program=${1:?usage: smoke.sh path/to/distella}
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT HUP INT TERM

rom="$workdir/minimal.bin"
config="$workdir/minimal.cfg"

dd if=/dev/zero of="$rom" bs=2048 count=1 status=none
printf '\140' | dd of="$rom" bs=1 seek=0 conv=notrunc status=none
# IRQ, reset, and BRK vectors. Reset and BRK both point at the RTS above.
printf '\000\370\000\370\000\370' | dd of="$rom" bs=1 seek=2042 conv=notrunc status=none
printf 'CODE F800 F800\n' > "$config"

output=$("$program" -c "$config" "$rom")
printf '%s\n' "$output" | grep -q 'Disassembly of'
printf '%s\n' "$output" | grep -q 'START:'
printf '%s\n' "$output" | grep -q 'RTS'
