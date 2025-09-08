# PowerShell script to install Android SDK Command Line Tools
$ErrorActionPreference = "Stop"

# Set paths
$sdkPath = "C:\Android\android-sdk"
$cmdlinePath = "$sdkPath\cmdline-tools\latest"
$zipPath = "$env:TEMP\commandlinetools.zip"

# Create directory if it doesn't exist
if (!(Test-Path $cmdlinePath)) {
    New-Item -ItemType Directory -Path $cmdlinePath -Force
    Write-Host "Created directory: $cmdlinePath"
}

# Download using .NET WebClient (more reliable)
Write-Host "Downloading Android SDK Command Line Tools..."
$url = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"

try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, $zipPath)
    Write-Host "Download completed successfully"
} catch {
    Write-Host "Download failed: $($_.Exception.Message)"
    Write-Host "Trying alternative download method..."
    
    # Alternative: Use Invoke-WebRequest with retry
    $retryCount = 0
    $maxRetries = 3
    
    while ($retryCount -lt $maxRetries) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
            Write-Host "Download completed successfully on retry $($retryCount + 1)"
            break
        } catch {
            $retryCount++
            Write-Host "Download attempt $retryCount failed: $($_.Exception.Message)"
            if ($retryCount -eq $maxRetries) {
                throw "Failed to download after $maxRetries attempts"
            }
            Start-Sleep -Seconds 5
        }
    }
}

# Extract using 7-Zip if available, otherwise use built-in method
Write-Host "Extracting command line tools..."
try {
    # Try 7-Zip first
    $sevenZip = Get-Command "7z.exe" -ErrorAction SilentlyContinue
    if ($sevenZip) {
        & $sevenZip x $zipPath "-o$cmdlinePath" -y
        Write-Host "Extracted using 7-Zip"
    } else {
        # Use built-in extraction
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $cmdlinePath)
        Write-Host "Extracted using built-in method"
    }
} catch {
    Write-Host "Extraction failed: $($_.Exception.Message)"
    Write-Host "Please manually extract the zip file to: $cmdlinePath"
    Write-Host "Download location: $zipPath"
    exit 1
}

# Clean up
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

# Verify installation
$sdkmanagerPath = "$cmdlinePath\bin\sdkmanager.bat"
if (Test-Path $sdkmanagerPath) {
    Write-Host "Installation successful!"
    Write-Host "sdkmanager location: $sdkmanagerPath"
} else {
    Write-Host "Installation verification failed. sdkmanager not found at: $sdkmanagerPath"
    Write-Host "Please check the extraction and ensure the bin folder contains sdkmanager.bat"
}

Write-Host "Next steps:"
Write-Host "1. Set ANDROID_HOME environment variable: setx ANDROID_HOME `"$sdkPath`""
Write-Host "2. Add to PATH: setx PATH `"%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin`""
Write-Host "3. Restart command prompt and run: flutter doctor --android-licenses"
