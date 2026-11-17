#!/bin/sh
# The release archive, for Cradle's stove_build (target package) and the
# repo CI: DSDA-Doom built with amiga/Makefile.amigaos on the stove's
# GFOpenGPU developer kit (SDL 2 and SDL2_mixer), with zlib 1.3.1's inflate
# fetched at its pinned commit, as one -m68040 -msoft-float binary (the
# stove's fpuauto takes the FPU when there is one). package/soft-float.sh
# stops the build on a hard-float flag, a compile without soft float, an FPU
# instruction in the objects or no fpuauto. Then package/pack.py makes
# dsdadoom-VERSION-68040.lha: the DSDADoom drawer (dsda-doom, dsda-doom.wad,
# the ReadMe, IWAD-ReadMe, the GPL and their icons) and its icon, with the
# Installer (Install-DSDADoom and its icon, made by amicradle's
# scripts/ports/port_installer.py from package/installer.json) beside them
# at the root. No IWAD is packaged. OUT also gets the .sha256, DSDADoom.tar
# (for a lab) and package.json. STOVE is the os32-gcc16 stove (or its
# prefix/); VERSION is package/VERSION. Nothing is published from here.
# MIT, Copyright (c) 2026 AmiCradle Team.
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$HERE/.." && pwd)
OUT=${OUT:-"$ROOT/build-amiga-package"}
VERSION=$(cat "$HERE/VERSION")
STOVE=${STOVE:-${OS32_GCC16:-"$HOME/AmiCradle/kitchen/stoves/os32-gcc16"}}
mkdir -p "$OUT"
OUT=$(CDPATH= cd -- "$OUT" && pwd)
BUILD=$(mktemp -d "${TMPDIR:-/tmp}/dsdadoom-package.XXXXXX")
trap 'rm -rf "$BUILD"' EXIT INT TERM

# A stove's compiler is in its prefix/; the GFOpenGPU kit is in the prefix's
# m68k-amigaos/ (include/SDL2, lib/libSDL2.a).
if [ ! -x "$STOVE/bin/m68k-amigaos-gcc" ] && [ -x "$STOVE/prefix/bin/m68k-amigaos-gcc" ]; then
	STOVE="$STOVE/prefix"
fi
SDL2KIT="$STOVE/m68k-amigaos"
[ -f "$SDL2KIT/lib/libSDL2_mixer.a" ] || { echo "the stove has no GFOpenGPU kit (libSDL2_mixer.a)"; exit 1; }
if [ -z "${NDK:-}" ]; then
	if [ -f "$SDL2KIT/ndk-include/exec/types.h" ]; then NDK="$SDL2KIT/ndk-include"
	else
		git clone -q --depth 1 https://github.com/DalsinAI/gfopensdk "$BUILD/gfopensdk"
		NDK="$BUILD/gfopensdk/OpenNDK/Include_H"
	fi
fi
git init -q "$BUILD/zlib"
git -C "$BUILD/zlib" fetch -q --depth 1 https://github.com/madler/zlib 51b7f2abdade71cd9bb0e7a373ef2610ec6f9daf	# v1.3.1
git -C "$BUILD/zlib" checkout -q FETCH_HEAD

# A copy of the checkout, so build/ stays out of it.
SRC="$BUILD/src"
mkdir -p "$SRC"
( cd "$ROOT" && tar --exclude=.git --exclude=build-amiga-package --exclude=./build -cf - . ) | ( cd "$SRC" && tar -xf - )
( cd "$SRC" && make -f amiga/Makefile.amigaos STOVE="$STOVE" NDK="$NDK" SDL2KIT="$SDL2KIT" ZLIB="$BUILD/zlib" -j"${JOBS:-2}" all ) \
	> "$OUT/build-output.txt" 2>&1 || { tail -n 60 "$OUT/build-output.txt"; exit 1; }
sh "$HERE/soft-float.sh" "$STOVE" "$SRC/build/amigaos/DSDADoom/dsda-doom" --log "$OUT/build-output.txt" \
	--allow "$HERE/fpu-allow.txt" "$SRC/build/amigaos/obj" > "$OUT/soft-float.txt" || { cat "$OUT/soft-float.txt"; exit 1; }
cat "$OUT/soft-float.txt"

mkdir -p "$BUILD/dist"
cp -R "$SRC/build/amigaos/DSDADoom" "$BUILD/dist/DSDADoom"
cp "$SRC/build/amigaos/DSDADoom.info" "$BUILD/dist/DSDADoom.info"
python3 "$HERE/pack.py" --dist "$BUILD/dist" --drawer DSDADoom --program dsda-doom --archive dsdadoom \
	--version "$VERSION" --installer "$HERE/installer" --source "$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo unknown)" \
	--compiler "$("$STOVE/bin/m68k-amigaos-gcc" --version | head -n 1)" --out "$OUT"
