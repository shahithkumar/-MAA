# Fix flutter_vibrate AndroidManifest.xml
$manifestPath = "C:\Users\shahi\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_vibrate-1.3.0\android\src\main\AndroidManifest.xml"

# Read the file
$content = Get-Content $manifestPath -Raw

# Remove the package attribute from the manifest tag
$newContent = $content -replace 'package="[^"]*"\s*', ''

# Write back
Set-Content -Path $manifestPath -Value $newContent

Write-Host "Fixed AndroidManifest.xml - removed package attribute!"
Write-Host "Now run: flutter build apk --release"
