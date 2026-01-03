# Fix flutter_vibrate build.gradle file
$buildGradlePath = "C:\Users\shahi\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_vibrate-1.3.0\android\build.gradle"

# Read the original file
$lines = Get-Content $buildGradlePath

# Find and fix the corrupted line
$fixedLines = @()
$namespaceAdded = $false

foreach ($line in $lines) {
    # Skip corrupted lines with backtick-n
    if ($line -match '`n') {
        Write-Host "Skipping corrupted line: $line"
        continue
    }
    
    $fixedLines += $line
    
    # Add namespace after 'android {' line if not already added
    if ($line -match '^\s*android\s*\{' -and -not $namespaceAdded) {
        $fixedLines += '    namespace "com.benjaminabel.flutter_vibrate"'
        $namespaceAdded = $true
        Write-Host "Added namespace after 'android {'"
    }
}

# Write the fixed content back
Set-Content -Path $buildGradlePath -Value $fixedLines

Write-Host "`nFixed! Now run: flutter build apk --release"
