$env:JAVA_HOME = "C:\Users\denna\android-sdk-setup\jdk"
$env:PATH = "C:\Users\denna\android-sdk-setup\jdk\bin;" + $env:PATH
$sdkmanager = "C:\Users\denna\android-sdk-setup\sdk\cmdline-tools\latest\bin\sdkmanager.bat"
& $sdkmanager --sdk_root="C:\Users\denna\android-sdk-setup\sdk" "platforms;android-36"
