# Sprint 3 checkpoint — fbd4b90
- Branch: feat/s2-fe-mobile; commit fbd4b90
- APK debug: FBB41A03B20B07A27BAA442FFEFC59CECD8CA0FA8FC458ED353C585F86B43DA9; 188819789 B
- analyze 0 error/2 info; test 286/286
- GPS background: server intervals 19s/20s, max 20s (<30s); app home/background.
- Permission flow: dialog in-app + Android foreground/background granted; foreground service starts.
- UI: status lokasi, last location age, detail age; pemilih grup via bottom sheet.
- Notion: 9 FE Sprint3 In Progress; 2 tablet tickets revised to Android HP; MFE-014 decision role-based recorded.
- BLOCKED: MFE-014 endpoint peer jemaah 403 (backend); MFE-020 fresh restart with GPS off not yet captured; MFE-013/025/026 fresh screenshots/audit pending.

## Update auditor
- MFE-014: BLOCKED integrasi peer jemaah; endpoint /departure-groups/{id}/tracker 403 untuk Zara; tidak ada endpoint peer resmi. Auditor menyarankan repository/service + fixture berlabel + error 401/403 terpisah; MBE-014 dependency. Jangan pakai token admin.
- Kandidat FBB41A03 / fbd4b90 diajukan; auditor belum memberi verdict Sprint 3 (baru diagnosis MFE-014).

## Final candidate 1EF37148
- FE commit after optimization; APK SHA 1EF37148D9F89729D0BD2D4956E25BDB42F809DF37B3E9DA97B49BD1AE29E51B; 188822547 B; tests 286/286; analyze 0 error/2 info.
- MFE-012/015/018/019/020/025/026 -> Notion In Review; MFE-013/014 In Progress; MBE-014 In Review.
- Map: OSM tiles blank in emulator; markers/list render after recenter; peer list verified with Nadia+Zara.
- Smoothness: removed continuous pulse animation when SOS inactive; profiling via gfxinfo limited (emulator high jank baseline).

## Candidate 2E43DCC
- APK 2E43DCC618DC26A17CCBF02C34649B3B3C0567D3A33D188444632DE0EBC1A027; 188825904 B; tests 286/286; analyze 0 error/2 info.
- Live label now only when fix <60s; stale shows "Lokasi terakhir · X" / "Terakhir · X".
- Camera fits peers on async member load; peer marker NP and panel visible; permission system dialog captured.
- MFE-013 API: Felix group1 tracker 200; group3 403.

## Candidate DB81ECF5
- APK DB81ECF587917526812B1842A6BCE1BCA4D006A810124F1360FAE5C4781CB4E0; 188826779 B; tests 286/286; analyze 0 error/2 info.
- F3: hapus fallback 1200 m/Timur Laut/Aman untuk anggota tanpa lokasi; status jadi Belum tersedia.
- F4: padding detail mengikuti safe area + 110; tombol tidak tertutup navbar.
- F1/F2: label Live hanya saat fix <60s; kamera fit peers; timestamp tracker dipakai.

## Audit closure attempts (DB81)
- DB81 APK: 188826779 B; tests 286/286; analyze 0/2.
- F1 camera fit + peer marker/panel verified in s3_final_map_age4.
- F2 stale label verified: "Lokasi terakhir · 4 menit lalu"/"Terakhir · 4 menit lalu"; GPS off screen exists.
- F3 fake 1200m/Timur Laut/Aman removed; F4 navbar padding safe-area+110.
- Background 5-min run FAIL: sampler got HTTP 403 for all 10 samples; direct curl token returned 200; not counted as PASS.
- Profile APK built (77.6 MB); trace not captured; no smoothness PASS.
- Auditor CDP remains unavailable; no ACC.

## Diagnosa 403 background
- Request QA tanpa header User-Agent -> 403; dengan User-Agent protein-audit -> 200. Bukan token/role; endpoint tracker grup memang 403 untuk jemaah.
- Sampel 5 menit terbaru: 10/10 HTTP 200, tetapi `last_location.updated_at` tetap 17:14:24 dan `received_at` null -> aplikasi tidak mengirim lokasi saat background pada percobaan ini. Status FAIL, bukan PASS.
- Perlu perbaiki foreground service/start flow; tidak diklaim selesai.

## Candidate F44C — chain fix
- FE commit (HEAD), APK F44C45877CB107F086FC8773263498D69E96A019F02581AE98B577871C6B7DE6; 188828340 B; tests 286/286; analyze 0/2.
- Service now exposes lastFix; state acquires until first fix; page listens to lastPosition and uses position.timestamp; sendLocation rethrows/empty response treated as failure.
- Device QA blocked: fresh AVD wipe still 'System UI isn't responding'; host FreeMB ~1400, guest boot ok. No background/UI PASS on this candidate.
- Auditor: lucifer Edge dedicated profile is logged out (ChatGPT shows Log in); default Edge debug forbidden; EdgeCdp task dead. Need interactive login on dedicated profile before Chat-mode audit. No ACC.

## Latest candidate FD1B14FC / fa07a0a
- APK FD1B14FC10246EEA994D1973C67E5949778D0C4BEE1D1D0163E47F67A7201A79; 188827541 B; tests 286/286; analyze 0/2.
- Panel Anggota grup now inside address card (verified on D6F6); GPS service status stream added.
- Background PASS verified on F44C: 16 samples, server updated_at gaps 19–21 s max 21 s, app background; simulated coords, UA protein-audit. Latest candidate still needs rerun.
- Auditor blocked: Edge dedicated profile at C:\Users\syahr\AppData\Local\Microsoft\Edge\User is logged out (ChatGPT "Log in"; Google needs email); default profile debug is refused by Edge; no audit verdict/ACC.

## Auditor re-audit FD1B (Chat mode)
- ZIP attached directly; auditor INTEGRITY PASS (923348 B; ZIP SHA 08f012e6...; 5 file hashes match).
- Verdict: HOLD — NOT ACC. MFE-013 BLOCKED; MFE-014 PARTIAL PASS; MFE-012/015/018/019/020/025/026 HOLD.
- Findings: F44C background only 4m08.99s (not >=5m); FD1B background BLOCKED/System UI ANR; F2 label "Terakhir · baru saja" vs Zara 4m; panel overlaps in old screenshot; F3 needs no-location/permission/GPS/API-fail proof; F4 navbar HP/tablet; ZIP lacked raw analyze/test logs and full AC matrix.
- Current FD1B device: app installs, but emulator/app ANR; service reports acquisition_failed; no valid FD1B background run. Do not claim PASS.

## Candidate 9358A8BA
- APK 9358A8BAC573C975BF52AE4AD0FD3CEB54AA69EFB8955D08E1DDF188CC638739; 188828252 B; tests 286/286; analyze 0/2.
- FD1B background PASS on new clean AVD 5556: 24 samples, span 380 s (6m20), unique gaps max 20 s, state available; app background, simulated geo fixes. Screenshots F1/F2.
- Latest source commit after ack timestamp.

## Re-audit #3 (9358)
- Background PASS numeric: 24 samples, actual session 366.83 s, unique timestamps 20, interval 20 s, state available, 24/24 received_at; app background; new AVD 5556; simulated geo fixes.
- F1 VISUAL PASS; F2 PARTIAL (local "baru saja" vs peer Zara 31-32m); F3 UNVERIFIED; F4 PARTIAL (HP okay, tablet missing).
- Tickets: MFE-013/014 PARTIAL PASS; MFE-012/015/018/019/020/025/026 HOLD; Sprint NOT ACC.
- Required: APK installed identity/lifecycle/FGS/logcat evidence, locked-screen, F2 source labels, F3 runtime, F4 tablet, role/Felix/admin, permission, profiling, full AC matrix.
