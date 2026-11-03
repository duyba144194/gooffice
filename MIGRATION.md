# GoOffice — Project Handover / PC Migration Guide

> Viết ngày 2026-11-03 khi đóng gói dự án để chuyển sang PC mới.

## 1. Dự án đã đạt được gì (final state)

**GoOffice 1.0.0.0** — fork LibreOffice 26.8.2.2, đủ 5 nền tảng:

| Nền tảng | Trạng thái | Asset trên Release v1.0.0 |
|---|---|---|
| Windows x64 (MSI) | ✅ shipped + QA | `GoOffice_1.0.0.0_Win_x86-64_en-US_vi.msi` + helppack ×2 + sdk |
| Windows arm64 (MSI) | ✅ shipped + QA | `GoOffice_1.0.0.0_Win_aarch64_en-US_vi.msi` + helppack ×2 + sdk |
| Linux amd64 (DEB tar) | ✅ shipped + QA + reproducible | `GoOffice_1.0.0.0_Linux_x86-64_deb.tar.gz` |
| Linux arm64 (DEB tar) | ✅ CI PASS (run 41532411671) | `GoOffice_1.0.0.0_Linux_arm64_deb.tar.gz` (44 DEB, có tiếng Việt) |
| macOS arm64 + x64 (DMG) | ⏳ CI run 41563169277 đang chạy | chờ upload |

**Tính năng đặc biệt:**
- 🇻🇳 Tiếng Việt đầy đủ: UI (.mo), help, từ điển chính tả (dict-vi)
- 💰 Ký hiệu tiền VNĐ (không phải ₫ Unicode) — patch 0014
- 🚫 Không donate/get-involved trong UI — patch 0015
- 🎨 Icon GoOffice xanh — patches 0009/0010
- Mặc định `ooLocale=vi` + `ooSetupSystemLocale=vi-VN` — patch 0012

**QA đã PASS:** license scan (MPL 2.0), 19 format roundtrip, render so MS Word, VBA roundtrip, font Việt, reproducible build.

## 2. Mọi thứ đã an toàn trên GitHub

Repo public: `https://github.com/duyba144194/gooffice`
- Toàn bộ 17 patches (`patches/0001-0017`) — CI tự apply khi build
- Workflow `.github/workflows/build.yml` (build đủ 4 nền tảng, unlimited free vì repo public)
- autogen inputs cho 8 cấu hình build
- branding + setup scripts (commit cuối)
- Release v1.0.0: 10/12 assets

**PC mới KHÔNG cần mang gì từ PC cũ cả** — chỉ cần `git clone`.

## 3. Setup PC mới (5 phút)

```bash
git clone https://github.com/duyba144194/gooffice
cd gooffice
gh auth login          # GitHub CLI
```

Xong. Muốn build local thì xem `autogen/` + `setup/`, muốn CI thì:
```bash
gh workflow run build.yml --field platforms="macos-arm64,macos-x64-cross"
```

## 4. Việc còn treo (làm từ PC mới được)

### 4.1. Upload 2 DMG macOS còn thiếu
CI run `41563169277` (kích hoạt 2026-11-03 ~09:20) đang build trên GitHub —
không phụ thuộc PC nào. Khi xong:
```bash
gh run view 41563169277 --repo duyba144194/gooffice
gh run download 41563169277 --repo duyba144194/gooffice -D /tmp/dmg
gh release upload v1.0.0 /tmp/dmg/GoOffice-macos-arm64/*.dmg /tmp/dmg/GoOffice-macos-x64-cross/*.dmg --repo duyba144194/gooffice
```
Nếu job macOS fail vì "not acquired by Runner" (quá tải) → chỉ cần re-run:
```bash
gh run rerun 41563169277 --failed --repo duyba144194/gooffice
```

### 4.2. Nếu build macOS fail thật (không phải quá tải)
Xem lỗi qua `gh api repos/duyba144194/gooffice/actions/jobs/<id>/logs`.
Lưu ý: patch 0017 (debug print) còn nằm trong chuỗi patch — vô hại, chỉ in
vài dòng DBG. Có thể bỏ khi không cần.

## 5. Bài học quan trọng nhất (đừng quên!)

**Bug installer 329-file khét tiếng:** `OFFICEDIRECTORYNAME` trong
openoffice.lst làm installer GHI ĐÈ HostName của Brand Root dir thành
"GoOffice" → mọi destination nhận prefix `GoOffice/` không tồn tại trong
instdir → packaging chết. Upstream không định nghĩa biến này — ĐỪNG THÊM
vào patch 0002 lần nữa. (Đã xóa trong commit fc16cb2.)

**CI cần clone 3 repo:** core + translations + dictionaries (translations
chứa .po tiếng Việt, dictionaries chứa .dic). Thiếu 1 trong 2 là installer
fail với hàng trăm "Source not found".

## 6. Trên PC cũ — có thể XÓA an toàn (~270GB)

| Thư mục | Dung lượng | Lý do được xóa |
|---|---|---|
| `C:\Users\NAM\GoOffice\build-linux-x64` | ~100GB | build tree, tái tạo từ repo |
| `C:\Users\NAM\GoOffice\build-win-arm64` | ~80GB | đã có MSI trên Release |
| `C:\Users\NAM\GoOffice\src\core` | ~15GB | clone lại từ GitHub |
| `C:\Users\NAM\GoOffice\lo-externaltar` | ~5GB | tarball tự tải lại |
| `C:\Users\NAM\GoOffice\dist.rar` | 1.7GB | đã giải nén + assets lên Release |
| `C:\Users\NAM\GoOffice\dist` | ~1.5GB | giữ nếu muốn — đã có trên Release |

**GIỮ LẠI** (đã vào repo, chỉ mang file git): `setup\` scripts, patches, autogen.

## 7. Cấu trúc repo

```
gooffice/
├── patches/0001-0017    # patch chuỗi áp lên LibreOffice core khi build
├── autogen/             # cấu hình build 8 biến thể (win/linux/macos × arch)
├── branding/            # logo, banner, splash cho --with-branding
├── setup/               # scripts hỗ trợ (icon gen, WSL build, cài tiếng Việt)
├── .github/workflows/build.yml  # CI build 4 nền tảng
├── docs/                # QA report, license compliance
└── PROJECT.md           # lịch sử dự án
```
