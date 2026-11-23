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
