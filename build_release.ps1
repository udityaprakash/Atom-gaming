
# Generate dynamic version
$now = Get-Date

$day = $now.Day
$month = $now.Month
$time = $now.ToString("HHmm")

$version = "0.$day.$month.$time"

# Generate Android build number
$buildNumber = [int]([DateTimeOffset]::Now.ToUnixTimeSeconds() / 60)

Write-Host "================================"
Write-Host "Version      : $version"
Write-Host "Build Number : $buildNumber"
Write-Host "================================"

# Install dependencies
flutter pub get

if ($LASTEXITCODE -ne 0) {
    throw "Flutter pub get failed."
}

# Build split APKs
flutter build apk --release --split-per-abi `
    --build-name="$version" `
    --build-number="$buildNumber" `
    --dart-define=APP_VERSION="$version"

if ($LASTEXITCODE -ne 0) {
    throw "Flutter APK build failed."
}

Write-Host "`nBuild completed successfully!"
Write-Host "APK location: build/app/outputs/flutter-apk/"
