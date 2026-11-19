# build-apk.ps1 -- build APK Doa Ibu di Windows (PowerShell 5.1 kompatibel)
#
# Pakai:
#   powershell -ExecutionPolicy Bypass -File .\scripts\build-apk.ps1
#
# Prasyarat (sekali):
#   1. Flutter SDK 3.47.9 stable: https://docs.flutter.dev/get-started/install/windows
#   2. Android Studio (ikut memasang Android SDK + platform-tools)
#   3. Jalankan `flutter doctor --android-licenses` lalu setujui semua
#
# Hasil: build\app\outputs\flutter-apk\app-release.apk

param(
    [string]$ApiBaseUrl = 'https://doaibu.sangcakapuniverse.my.id/api/v1'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host "== Cek toolchain ==" -ForegroundColor Cyan
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutter) {
    Write-Host "Flutter tidak ditemukan di PATH. Pasang Flutter SDK lalu buka terminal baru." -ForegroundColor Red
    exit 1
}
flutter --version
flutter doctor

Write-Host "== flutter pub get ==" -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) { Write-Host "pub get gagal" -ForegroundColor Red; exit 1 }

Write-Host "== Build APK release ==" -ForegroundColor Cyan
Write-Host "API_BASE_URL = $ApiBaseUrl"
flutter build apk --release "--dart-define=API_BASE_URL=$ApiBaseUrl"
if ($LASTEXITCODE -ne 0) { Write-Host "build gagal" -ForegroundColor Red; exit 1 }

$apk = Join-Path $root 'build\app\outputs\flutter-apk\app-release.apk'
if (Test-Path $apk) {
    $size = (Get-Item $apk).Length / 1MB
    Write-Host ("APK siap: {0} ({1:N2} MB)" -f $apk, $size) -ForegroundColor Green
} else {
    Write-Host "APK tidak ditemukan setelah build." -ForegroundColor Red
    exit 1
}
