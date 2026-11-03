#!/bin/bash
# GoOffice Linux amd64 build on WSFL ext4 — autogen + make, logs to /mnt/c
set -o pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
LOG=/mnt/c/Users/NAM/GoOffice/logs/make-build-linux-ext4.log

cd ~/core
if [ ! -f config_host.mk ]; then
    echo "== autogen $(date) ==" | tee -a "$LOG"
    ./autogen.sh >> "$LOG" 2>&1 || { echo "AUTOGEN-FAILED" | tee -a "$LOG"; exit 1; }
fi

echo "== make $(date) ==" | tee -a "$LOG"
make fetch -j"$(nproc)" >> "$LOG" 2>&1
make -j"$(nproc)" >> "$LOG" 2>&1
rc=$?
echo "LINUX-EXT4-MAKE-EXIT:$rc $(date)" | tee -a "$LOG"
exit $rc
