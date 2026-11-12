# Third-party material

siska-tech/kagura から分離した際に、SDKに含まれる第三者由来の素材の記載を[kaguraのTHIRD_PARTY.md](https://github.com/siska-tech/kagura/blob/c6ae031cb7043171796e134d0dea9870f808206f/THIRD_PARTY.md)から写した。

`software/pico/pico_sdk_import.cmake`はRaspberry Pi Pico SDK 2.2.0（commit `a1438dff1d38bd9c65dbd693f0e5db4b9ae91779`）の`external/pico_sdk_import.cmake`の無改変の写しで、SDKのBSD-3-Clauseに従う。CIはSDK版の同ファイルと一致することを検査する。Pico SDK本体とArm GNU Toolchainはビルド時に取得し、リポジトリに含めない。

`software/micropython/examples/sakura_assets/piano_c4.pcm`は`software/pico/piano_c4_sample.h`の72000サンプルを符号付き8bitのままバイナリにした写しで、Meta Open Sound（Meta Piano `INSPiano_Vel03_C4_01.ogg`）由来のCC0 1.0素材である。変換内容と上流のSHA-256は[Pico側の記載](software/pico/THIRD_PARTY.md)を参照。`tests/test_sakura.py`が両者の一致を検査する。

`software/micropython/fonts/misaki8.kfnt`は門真なむ氏の8×8日本語フォント「美咲ゴシック」2021-05-05版（`misaki_bdf_2021-05-05.zip`の`misaki_gothic.bdf`）を`tools/gen-kagura-ja-font.py`でKJ8F形式へ変換したもの。字形は無改変で、半角字形をセル内で中央寄せした。ツールは上流アーカイブとBDFのSHA-256を検証する。Apache-2.0は適用せず、原著作権表示と許諾文（使用・複製・改変・再配布を商用/非商用とも許可、無保証）を[フォント資料](software/micropython/fonts/README.md)に保持する。
