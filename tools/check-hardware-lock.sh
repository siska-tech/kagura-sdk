#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Checks the SDK's generated register constants against the hardware commit
# named in hardware.lock:
#   - spec/registers.json at that commit has the recorded SHA-256;
#   - software/include/kagura_regs.h and software/micropython/kagura/regs.py
#     are exactly what that commit's tools/gen-registers.ps1 generates
#     (gen-registers.ps1 -Check, run on a copy of that commit with these two
#     files from the SDK put in place);
#   - the ABI in regs.py is the one recorded.
# Needs git and pwsh. KAGURA_HW_DIR: an existing siska-tech/kagura clone to
# read the commit from (it is not modified); without it the commit is fetched
# into build/kagura-hw.
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
field() { awk -v k="$1" '$1 == k { print $2 }' hardware.lock; }
commit="$(field commit)" sha="$(field registers.json-sha256)" abi="$(field abi)"
[[ "$commit" =~ ^[0-9a-f]{40}$ ]] || { echo "FAIL: hardware.lock: commit must be a full SHA"; exit 1; }

hw="${KAGURA_HW_DIR:-build/kagura-hw}"
if [ ! -d "$hw/.git" ] && [ ! -f "$hw/.git" ]; then
    git init -q "$hw"
    git -C "$hw" remote add origin https://github.com/siska-tech/kagura.git
fi
if ! git -C "$hw" cat-file -e "$commit^{commit}" 2> /dev/null; then
    git -C "$hw" fetch -q --depth 1 origin "$commit"
fi

actual="$(git -C "$hw" cat-file blob "$commit:spec/registers.json" | sha256sum | cut -d' ' -f1)"
[ "$actual" = "$sha" ] || { echo "FAIL: spec/registers.json at $commit is $actual, hardware.lock says $sha"; exit 1; }

major="$(sed -n 's/^ABI_MAJOR = const(0x\([0-9A-Fa-f]*\))$/\1/p' software/micropython/kagura/regs.py)"
minor="$(sed -n 's/^ABI_MINOR = const(0x\([0-9A-Fa-f]*\))$/\1/p' software/micropython/kagura/regs.py)"
[ "$((16#$major)).$((16#$minor))" = "$abi" ] || { echo "FAIL: regs.py ABI $major.$minor, hardware.lock says $abi"; exit 1; }

tree="build/hardware-lock"
rm -rf "$tree"
mkdir -p "$tree"
git -C "$hw" archive "$commit" | tar -x -C "$tree"
for f in software/include/kagura_regs.h software/micropython/kagura/regs.py; do
    mkdir -p "$tree/$(dirname "$f")"
    cp "$f" "$tree/$f"
done
pwsh -NoProfile -File "$tree/tools/gen-registers.ps1" -Check
echo "PASS: generated constants match siska-tech/kagura $commit (ABI $abi)"
