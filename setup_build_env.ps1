$setupDir = "C:\Users\denna\android-sdk-setup"
if (-not (Test-Path $setupDir)) {
    New-Item -ItemType Directory -Path $setupDir | Out-Null
}

$jdkDir = "$setupDir\jdk"
$sdkDir = "$setupDir\sdk"

# 1. Download and Extract JDK 17 if not already present
if (-not (Test-Path $jdkDir)) {
    Write-Host "Downloading JDK 17 (Eclipse Temurin)..."
    $jdkUrl = "https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse?project=jdk"
    $jdkZip = "$setupDir\jdk.zip"
    curl.exe -L -o $jdkZip $jdkUrl
    
    Write-Host "Extracting JDK 17..."
    Expand-Archive -Path $jdkZip -DestinationPath $setupDir
    
    $extractedFolder = Get-ChildItem -Path $setupDir -Directory | Where-Object { $_.Name -like "jdk-*" } | Select-Object -First 1
    if ($extractedFolder) {
        Rename-Item -Path $extractedFolder.FullName -NewName "jdk"
    }
    if (Test-Path $jdkZip) {
        Remove-Item $jdkZip -Force
    }
} else {
    Write-Host "JDK 17 already present."
}

# 2. Download and Extract Android Cmdline-Tools if not already present
if (-not (Test-Path "$sdkDir\cmdline-tools")) {
    Write-Host "Downloading Android Command Line Tools..."
    $sdkUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
    $sdkZip = "$setupDir\sdk.zip"
    curl.exe -L -o $sdkZip $sdkUrl
    
    Write-Host "Extracting Android Command Line Tools..."
    $tempSdk = "$setupDir\temp-sdk"
    Expand-Archive -Path $sdkZip -DestinationPath $tempSdk
    
    New-Item -ItemType Directory -Path "$sdkDir\cmdline-tools" -Force | Out-Null
    Move-Item -Path "$tempSdk\cmdline-tools" -Destination "$sdkDir\cmdline-tools\latest"
    if (Test-Path $tempSdk) {
        Remove-Item $tempSdk -Recurse -Force
    }
    if (Test-Path $sdkZip) {
        Remove-Item $sdkZip -Force
    }
} else {
    Write-Host "Android Command Line Tools already present."
}

# 3. Configure Env and Install Platforms / Build Tools
Write-Host "Setting environment variables..."
$env:JAVA_HOME = $jdkDir
$env:PATH = "$jdkDir\bin;" + $env:PATH

$sdkmanager = "$sdkDir\cmdline-tools\latest\bin\sdkmanager.bat"

Write-Host "Installing Android SDK platforms and build tools..."
& $sdkmanager --sdk_root=$sdkDir "platform-tools" "build-tools;34.0.0" "platforms;android-34"

# Accept Licenses
Write-Host "Accepting Android SDK licenses..."
$yes = "y`ny`ny`ny`ny`ny`ny`n"
$yes | & $sdkmanager --sdk_root=$sdkDir --licenses

# Configure Flutter
Write-Host "Configuring Flutter Android SDK..."
flutter config --android-sdk $sdkDir
