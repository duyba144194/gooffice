#!/bin/bash
# Build GoOffice for Linux amd64 — run INSIDE WSL Ubuntu-24.04
# Prereqs: apt packages installed (see admin-init), source at /mnt/c/Users/NAM/GoOffice/src/core-linux
# NOTE: builds in a SEPARATE tree from the Windows build (out-of-tree build).
set -eo pipefail

SRC="/mnt/c/Users/NAM/GoOffice/src/core"
BUILD="/mnt/c/Users/NAM/GoOffice/build-linux-x64"
LOG="/mnt/c/Users/NAM/GoOffice/logs/build-linux-x64.log"
WORKSPACE="/mnt/c/Users/NAM/Desktop/office"

mkdir -p "$BUILD" /mnt/c/Users/NAM/GoOffice/logs

echo "== GoOffice build: Linux amd64 (WSL) =="
echo "== start: $(date) ==" | tee -a "$LOG"

cd "$BUILD"
cp -f "$WORKSPACE/autogen/linux-x64.input" autogen.input

if [ ! -f config_host.mk ] || [ "$1" == "reconfig" ]; then
    echo "== running autogen.sh (out-of-tree) ==" | tee -a "$LOG"
    "$SRC/autogen.sh" 2>&1 | tee -a "$LOG"
fi

echo "== make (fetch + build) ==" | tee -a "$LOG"
make fetch -j"$(nproc)" 2>&1 | tee -a "$LOG"
make -j"$(nproc)" 2>&1 | tee -a "$LOG"

echo "== done: $(date) ==" | tee -a "$LOG"
echo "Output: $BUILD/instdir/program/soffice"
