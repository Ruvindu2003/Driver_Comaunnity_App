# PowerShell script to download Android SDK Command Line Tools
$url = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$outputPath = "commandlinetools-win.zip"
$extractPath = "C:\Android\android-sdk\cmdline-tools\latest"

Write-Host "Downloading Android SDK Command Line Tools..."
Invoke-WebRequest -Uri $url -OutFile $outputPath

Write-Host "Extracting to $extractPath..."
if (Test-Path $extractPath) {
    Remove-Item $extractPath -Recurse -Force
}
New-Item -ItemType Directory -Path $extractPath -Force

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($outputPath, $extractPath)

Write-Host "Cleaning up..."
Remove-Item $outputPath

Write-Host "Command line tools installed successfully!"
Write-Host "Location: $extractPath"
