# Login dan Registrasi Google Asli — Android Lokal

## Status pekerjaan yang benar-benar terverifikasi

- APK baru berhasil dibangun dan dipasang ke emulator `emulator-5554` tanpa menghapus data aplikasi.
- Tombol login/daftar Google sudah memakai SDK resmi `google_sign_in` 7.2.0, bukan modal akun buatan atau login akun dummy.
- SDK mengambil ID token Google, lalu mengirimnya ke `POST /api/v1/auth/google`.
- Backend membuat akun jemaah dan session bila Google subject baru, atau login ke akun tertaut bila subject sudah ada. Email/password account tidak ditautkan otomatis.
- Migrasi khusus `google_sub` sudah diterapkan ke MySQL lokal atas izin pengguna. Kolom dan unique index terbukti ada, jumlah akun tetap 4 sebelum/sesudah migrasi; migrasi OTP/SOS lain tidak dijalankan.
- Pengujian ulang Hermes: 43 Flutter tests lulus, `flutter analyze` tidak menemukan masalah; 22 tes backend Google lulus (149 assertions).
- APK debug terverifikasi dengan sertifikat yang sama sebelum dan sesudah build baru.
- Uji emulator membuka layar Google asli: top activity berasal dari `com.google.android.gms/.auth.uiflows.addaccount.WrapperControlledActivity`. Di layar muncul `Choose an account` dan `Add another account` karena belum ada akun yang dapat dipilih.
- Pengguna memilih melanjutkan login akun/consent nanti. Jadi login/registrasi Google end-to-end dengan akun asli BELUM dinyatakan berhasil.

## Kenapa sebelumnya gagal

Versi UI sebelumnya membuka pilihan akun buatan aplikasi, kemudian mengirim email/password akun dummy ke endpoint password login. Tidak ada SDK Google, ID token, atau token exchange. Selain itu migrasi Google di database utama masih Pending. Client ID/secret yang tersedia tidak pernah membuat alur palsu tersebut menjadi OAuth asli.

Alur sekarang:

`Tombol Google -> Google Play Services resmi -> ID token -> backend verifikasi RS256/audience/expiry -> session aplikasi`.

Desain halaman tetap dipertahankan. Mock/fake hanya dipakai pada tes otomatis, bukan alur runtime Google.

## Dua identitas yang harus cocok

1. Web OAuth client: server/audience untuk ID token backend. Aplikasi memakai public web ID berikut sebagai `serverClientId`:

`405719934940-bel9ujgn18jgaiuhpivk17e9und4872a.apps.googleusercontent.com`

2. Android OAuth client: pendaftaran package APK dan sertifikat penandatangan pada project Google Cloud yang sama.

Data aktual APK debug emulator:

- Package/application ID: `com.example.mobile_project_doa_ibu`
- SHA-1: `56:FF:65:C0:D3:A6:63:E2:18:2A:DC:AB:DA:46:A9:6A:72:20:AF:83`
- SHA-256: `6057741d1c71515a488cc7ffc42debc5002ecf28af53a5630246ae37dd275092`

Nilai tersebut berasal dari `apksigner verify --print-certs` terhadap APK aktual. Bukan nilai contoh.

File credential kedua yang diberikan memakai root JSON `installed`. Nama root JSON saja tidak cukup untuk memastikan tipe client dan pasangan package/SHA-nya. Periksa tipe di Console, jangan menyimpulkan perlu membuat client baru hanya dari nama file atau root JSON.

## Langkah Google Cloud Console untuk pemilik project

1. Buka https://console.cloud.google.com/auth/clients lalu login sendiri memakai akun yang memiliki akses project. Jangan mengirim password/OTP ke chat.
2. Pilih project yang sama dengan Web client di atas. Kedua ID yang diberikan memiliki project-number prefix `405719934940`. Jangan membuat project baru yang tidak terkait.
3. Buka Google Auth Platform -> Clients. Pada tampilan Console lain, pintasan bisa berada di APIs & Services -> Credentials -> OAuth 2.0 Client IDs.
4. Periksa client yang sudah ada, termasuk ID `405719934940-ti56lniv6av7r7os3a8nlfbdtbinh83o.apps.googleusercontent.com`.
5. Jika application type client tersebut Android, periksa Package name dan SHA-1. Bila cocok persis dengan data APK di atas, client itu bisa digunakan; tidak perlu duplikat.
6. Jika belum ada Android client yang cocok: pilih Create client / Create credentials -> OAuth client ID -> Application type Android. Nama bebas, misalnya `Doa Ibu Android Debug`.
7. Isi Package name dan SHA-1 persis seperti di atas, lalu simpan. Jangan menaruh Web client secret di aplikasi Flutter.
8. Jika project menampilkan pengaturan Audience dengan status Testing, tambahkan akun Google yang akan dipakai login sebagai test user bila diperlukan. Gunakan akun uji, bukan akun orang lain tanpa izin.
9. Tunggu konfigurasi diterapkan Google, lalu jalankan ulang aplikasi dan tekan tombol Google. `serverClientId` di aplikasi tetap Web client ID; tidak diganti menjadi Android client ID.

Tidak perlu mengubah GitHub. Tidak perlu memasang client secret pada APK. Integrasi ini memakai public serverClientId secara eksplisit, sehingga tidak mewajibkan file google-services.json untuk inisialisasi yang dipilih.

## Melanjutkan pengujian emulator

1. APK baru sudah terpasang di emulator yang sedang berjalan. Jika layar Google masih terbuka, lanjutkan `Add another account`.
2. Masukkan akun Google dan selesaikan password/2FA/consent sendiri. Jangan kirim password, OTP, access token, atau ID token ke chat/log.
3. Setelah proses Google selesai, aplikasi seharusnya kembali dan mengirim token asli ke backend.
4. Untuk Google subject yang belum terdaftar, backend membuat akun jemaah sekaligus login. Logout lalu login Google lagi seharusnya memakai akun yang sama, bukan duplikat.
5. Jika email sudah pernah didaftarkan dengan password dan belum ditautkan, backend memberi konflik 409 yang aman. UI penautan dari profil belum dibuat pada lingkup ini; jangan mengakali konflik dengan auto-link email atau akun dummy.
6. Jika gagal, catat pesan/kode error aman dan tahapnya: layar Google, kembali ke aplikasi, atau respons backend. Jangan menyalin token/secret.

Batas penting: Android CredentialManager kadang melaporkan konfigurasi tidak cocok sebagai cancellation; SDK tidak selalu dapat membedakannya dari pengguna membatalkan. Konfirmasi package/SHA/project/serverClientId di Console lebih dapat dipercaya daripada menebak dari pesan generik.

## Menjalankan pemeriksaan lokal

Dari folder `C:/TubesProtein/mobile_project_doa_ibu`:

- `flutter test`
- `flutter analyze`
- `flutter --no-version-check build apk --debug --no-pub`

APK yang berhasil dibuat:

`C:/TubesProtein/mobile_project_doa_ibu/build/app/outputs/flutter-apk/app-debug.apk`

Backend Google test (PHP 8.4):

`C:/php84/php.exe vendor/phpunit/phpunit/phpunit --filter GoogleLoginApiTest`

Jalankan perintah backend dari `C:/TubesProtein/Project-travel-doa-ibu`.

## Di luar perubahan Google ini

Fallback simulasi pada alur lupa-password/OTP Flutter ditemukan, tetapi tidak diubah dalam persetujuan khusus Google ini. Keberhasilan tes backend OTP sebelumnya bukan bukti layar OTP Flutter telah tersambung dengan benar. Pengiriman OTP ke inbox tetap memerlukan SMTP.

Referensi resmi:

- https://pub.dev/packages/google_sign_in
- https://pub.dev/packages/google_sign_in_android#integration
- https://developers.google.com/android/guides/client-auth
