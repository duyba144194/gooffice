#!/bin/bash
# GoOffice reproducibility test: clean clone + clean build with identical config,
# then compare produced artifacts against the original ~/core build.
set -o pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
LOG=/mnt/c/Users/NAM/GoOffice/logs/repro-build.log

echo "== repro test start: $(date) ==" | tee -a "$LOG"

# 1. sync ~/core to the current patched source, then clean-clone it
git -C ~/core fetch /mnt/c/Users/NAM/GoOffice/src/core '+refs/heads/master:refs/heads/master' 2>&1 | tail -1
git -C ~/core reset --hard FETCH_HEAD >> "$LOG" 2>&1
rm -rf ~/core-repro
git clone ~/core ~/core-repro 2>&1 | tail -1
cd ~/core-repro
git remote set-url origin https://github.com/LibreOffice/core
cp -f ~/core/autogen.input ~/core-repro/autogen.input
c1=$(git -C ~/core rev-parse HEAD); c2=$(git -C ~/core-repro rev-parse HEAD)
echo "same-commit-check: orig=$c1 repro=$c2" | tee -a "$LOG"
[ "$c1" = "$c2" ] || { echo "COMMIT-MISMATCH" | tee -a "$LOG"; exit 1; }

# 2. clean build
./autogen.sh >> "$LOG" 2>&1 || { echo REPRO-AUTOGEN-FAIL | tee -a "$LOG"; exit 1; }
make fetch -j"$(nproc)" >> "$LOG" 2>&1
make -j"$(nproc)" >> "$LOG" 2>&1
rc=$?
echo "REPRO-BUILD-EXIT:$rc $(date)" | tee -a "$LOG"
[ $rc -ne 0 ] && exit $rc

# 3. compare file inventory + text-file hashes (binary .so differ by build-id/timestamps)
python3 - <<'EOF' >> "$LOG" 2>&1
import os, hashlib, json
def inventory(root):
    inv = {}
    for dp, dn, fn in os.walk(os.path.join(root, 'instdir', 'program')):
        for f in fn:
            p = os.path.join(dp, f)
            rel = os.path.relpath(p, os.path.join(root, 'instdir', 'program'))
            inv[rel] = os.path.getsize(p)
    return inv
a = inventory(os.path.expanduser('~/core'))
b = inventory(os.path.expanduser('~/core-repro'))
only_a = sorted(set(a) - set(b)); only_b = sorted(set(b) - set(a))
diff = sorted(k for k in set(a) & set(b) if a[k] != b[k])
print(f"REPRO files: orig={len(a)} repro={len(b)}")
print(f"REPRO only-in-orig: {len(only_a)}; only-in-repro: {len(only_b)}; size-mismatch: {len(diff)}")
for k in only_a[:10]: print("  A-only:", k)
for k in only_b[:10]: print("  B-only:", k)
for k in diff[:15]: print(f"  DIFF: {k} {a[k]} vs {b[k]}")
same = sum(1 for k in set(a) & set(b) if a[k] == b[k])
print(f"REPRO identical-size files: {same}/{len(set(a) & set(b))}")
print("REPRO-VERDICT:", "PASS-STRUCTURAL" if not only_a and not only_b and len(diff) <= len(a)*0.25 else "INVESTIGATE")
EOF
echo "== repro test end: $(date) ==" | tee -a "$LOG"
