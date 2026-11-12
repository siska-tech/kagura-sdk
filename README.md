# kagura-sdk

The host software for [KAGURA-9](https://github.com/siska-tech/kagura), the HDMI video and sound chip on a Tang Nano 9K: the drivers and public APIs a host program uses, the firmware integration for RP2040 MicroPython, and the reusable libraries (UI toolkit, Japanese text, audio HAL and KSNG player).

This repository was split from siska-tech/kagura with its history (2026-11-12). Pull requests before the split are referenced as `siska-tech/kagura#N`. The reasons for the split and the ownership of each module are in [kagura's extraction plan](https://github.com/siska-tech/kagura/blob/c6ae031cb7043171796e134d0dea9870f808206f/docs/sdk-extraction.md).

## Repositories

| Repository | Owns |
|---|---|
| [siska-tech/kagura](https://github.com/siska-tech/kagura) | RTL, simulation, boards, `spec/registers.json` and the register generator, bitstreams and releases, the hardware specifications |
| **siska-tech/kagura-sdk** (this one) | drivers, public C and MicroPython APIs, MicroPython boards and firmware integration, libraries, examples, SDK tools and documents |
| [siska-tech/kagura-desktop](https://github.com/siska-tech/kagura-desktop) | the desktop environment and its applications, built on this SDK |

Dependencies point one way: kagura-desktop depends on kagura-sdk, and kagura-sdk depends on kagura only through the generated register constants and links to the hardware documents. Neither is built from a moving branch: [hardware.lock](hardware.lock) pins the kagura commit.

## Contents

| Path | What |
|---|---|
| `software/micropython` | the MicroPython SDK (`kagura.*`, `kagura.ui`, `kagura_ja`), boards `KAGURA_PICO`, `KAGURA_PICO_W`, `KAGURA_PICO_SHOWCASE`, examples, tests ([README](software/micropython/README.md)) |
| `software/audio` | audio HAL, KSNG format and player, the `kagura_audio` MicroPython module ([README](software/audio/README.md)) |
| `software/pico` | C host driver `kagura_host`, `tile_fb`, diagnostics firmware and demos ([README](software/pico/README.md)) |
| `software/include` | `kagura_regs.h`, generated from kagura's `spec/registers.json` |
| `software/starfall` | PROJECT STARFALL, the original C game (host and Pico builds) |
| `software/tests` | compile test of the generated C header |
| `software/api-snapshot.txt` | the public API, checked by `tools/api-snapshot.py` |
| `tools` | unix-port build, firmware and device tools, asset generators, UI measurement |
| `docs` | programming guide, UI toolkit, framebuffer, showcase and STARFALL documents, measurements |

The register map, host interface, memory map, video and audio specifications are hardware documents and stay in kagura. Links to them point at the commit in `hardware.lock`.

## Generated constants

`software/include/kagura_regs.h` and `software/micropython/kagura/regs.py` are generated in kagura by `tools/gen-registers.ps1` and committed here unchanged. `tools/check-hardware-lock.sh` checks three things:
- the files are exactly what the generator produces at the pinned commit;
- `spec/registers.json` at that commit has the recorded SHA-256;
- the ABI matches `hardware.lock`.

To move to a newer hardware commit, regenerate the files there, copy them here, and update the three lines of `hardware.lock` in the same change.

## Compatibility

- `tools/api-snapshot.py --check` compares the public names and signatures of the Python modules, `kagura_audio` and the public C headers with `software/api-snapshot.txt`, and fails on any difference. An intended API change updates the snapshot with `--write` in the same PR.
- Downstream repositories pin a commit of this repository (kagura-desktop: `sdk/kagura.ref`).

## Building and testing

MicroPython v1.26.0 is expected in `build/micropython-src` (see [.github/workflows/ci.yml](.github/workflows/ci.yml) for the exact commands):

```sh
git clone --depth 1 --branch v1.26.0 https://github.com/micropython/micropython.git build/micropython-src
python3 -I tools/api-snapshot.py --check
bash tools/check-hardware-lock.sh            # needs pwsh
bash tools/test-headers.sh
python3 -I software/micropython/tests/test_driver.py --rp2 build/micropython-src/ports/rp2/modules/rp2.py
bash software/audio/tools/test.sh
make -C build/micropython-src/ports/rp2 BOARD=KAGURA_PICO BOARD_DIR="$PWD/software/micropython/boards/KAGURA_PICO"
```

## Validation status

The split was verified in software only: the CI of this repository and the tests of kagura-desktop against it. It changed no code paths. Results recorded on hardware before the split (`docs/measurements`, the logs under `docs/`) were made with firmware built from siska-tech/kagura and stay the reference for that firmware. Still pending on an RP2040 with KAGURA-9:
- `kagura.tileplane.TilePlane` (added in siska-tech/kagura#96): transfer overhead, HDMI output and VRAM readback;
- firmware built from this repository, which has not been flashed.

Known-good firmware and bitstreams are published with kagura's releases and are not rebuilt or reclassified here.

## License

Apache-2.0 ([LICENSE](LICENSE)), except the third-party material listed in [THIRD_PARTY.md](THIRD_PARTY.md).
