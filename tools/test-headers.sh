#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Compile check for the generated C header software/include/kagura_regs.h.
# The header is generated in siska-tech/kagura (tools/gen-registers.ps1) at
# the commit in hardware.lock; tools/check-hardware-lock.sh checks that copy.
# The ca65 include (software/w65c02) and its assembly test stay in kagura.
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
out=build/headers
mkdir -p "$out"
cc -std=c11 -Wall -Wextra -pedantic -Werror -Isoftware/include software/tests/regs_c.c -o "$out/regs_c"
"$out/regs_c"
echo "PASS: C header"
