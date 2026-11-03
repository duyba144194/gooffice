#!/bin/bash
# Rebuild ~/core cleanly on ext4 from the intact /mnt/c repo, then fetch submodules
set -e
rm -rf ~/core
echo "== cloning from /mnt/c repo (local) =="
git clone /mnt/c/Users/NAM/GoOffice/src/core ~/core 2>&1 | tail -1
cd ~/core
git remote set-url origin https://github.com/LibreOffice/core
echo "== fetching submodules =="
git submodule update --init --depth 1 dictionaries helpcontent2 translations 2>&1 | tail -3
cp -f /mnt/c/Users/NAM/Desktop/office/autogen/linux-x64-ext4.input ~/core/autogen.input
echo "== verify =="
git -C ~/core log --oneline | head -1
du -sh ~/core/dictionaries ~/core/helpcontent2 ~/core/translations
echo REBUILD-DONE
