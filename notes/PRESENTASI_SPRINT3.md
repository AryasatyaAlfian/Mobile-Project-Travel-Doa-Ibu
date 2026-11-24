# PROTEIN Sprint 3 — Ringkasan Progress (internal)

## Status
- Kandidat FE: `d6accb4`
- APK: `9358A8BAC573C975BF52AE4AD0FD3CEB54AA69EFB8955D08E1DDF188CC638739`
- Ukuran APK: 188.828.252 byte (debug)
- Backend yang dipakai: `72e1223`
- `flutter test`: 286/286 PASS
- `flutter analyze`: 0 error, 2 info

## Yang sudah terbukti
- Background location tracking: 24 sampel; durasi sesi 366,83 detik; interval 20 detik; seluruh sampel `available` dan memiliki `received_at`; aplikasi background; koordinat emulator diberi label simulasi.
- Panel anggota grup dan marker peer tampil; F1 visual PASS menurut auditor.
- GPS off tidak lagi menampilkan “Live Tracking”.
- Kontrak `/me/tracker` mengirim `members` sesuai grup; akses lintas grup ditolak; tanpa grup = kosong; tanpa autentikasi = 401.

## Verdict auditor terakhir
- MFE-013/014: PARTIAL PASS
- MFE-012/015/018/019/020/025/026: HOLD
- Sprint 3: NOT ACC

## Bukti yang masih kurang
- Identitas APK terpasang + lifecycle/foreground service/logcat + uji layar terkunci.
- Konsistensi semantik timestamp F2 (kartu lokal vs panel server).
- Runtime F3 (lokasi kosong, izin ditolak, GPS off, API gagal).
- F4 tablet; role/Felix/admin; permission end-to-end; profiling; matriks acceptance criteria sembilan tiket.

## Catatan push
- Branch FE: `feat/s2-fe-mobile`; belum punya upstream.
- Jangan merge ke `main` sebelum ACC.
- Backend `main` masih ahead 1/behind 1 dari upstream; jangan push paksa.
