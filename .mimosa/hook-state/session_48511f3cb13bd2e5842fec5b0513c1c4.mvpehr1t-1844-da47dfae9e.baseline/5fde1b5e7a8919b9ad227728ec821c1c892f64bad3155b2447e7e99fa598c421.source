#!/bin/bash
# Build GoOffice for Windows amd64 — run from Git Bash (not from inside WSL)
# Prereqs: VS2022 BuildTools (VCTools), ~/bin (make/jom), ~/lo (perl/ant/junit),
#          WSL Ubuntu-24.04 running (for autogen.sh), JDK17 at GoOffice/tools/jdk17
set -eo pipefail

export PATH="$HOME/bin:$PATH"
export JAVA_HOME="C:/Users/NAM/GoOffice/tools/jdk17"
SRC="/c/Users/NAM/GoOffice/src/core"
LOG="/c/Users/NAM/GoOffice/logs/build-win-x64.log"
WORKSPACE="/c/Users/NAM/Desktop/office"

mkdir -p /c/Users/NAM/GoOffice/logs

echo "== GoOffice build: Windows amd64 =="
echo "== start: $(date) ==" | tee -a "$LOG"

cd "$SRC"
cp -f "$WORKSPACE/autogen/win-x64.input" autogen.input

if [ ! -f config_host.mk ] || [ "$1" == "reconfig" ]; then
    echo "== running autogen.sh via WSL ==" | tee -a "$LOG"
    wsl ./autogen.sh 2>&1 | tee -a "$LOG"
fi

echo "== make (fetch + build) ==" | tee -a "$LOG"
make fetch 2>&1 | tee -a "$LOG"
make 2>&1 | tee -a "$LOG"

echo "== done: $(date) ==" | tee -a "$LOG"
echo "Output: $SRC/instdir/program/soffice.exe"
