# Load paths from files
$supersededKeys = Get-Content -Path ".\superseded_keys.txt"
$supersededValues = Get-Content -Path ".\superseded_values.txt"


# Delete registry values
foreach ($valuePath in $supersededValues) {
    $lastBackslash = $valuePath.LastIndexOf('\')
    if ($lastBackslash -gt 0) {
        $parentKey = $valuePath.Substring(0, $lastBackslash)
        $valueName = $valuePath.Substring($lastBackslash + 1)
        try {
#            Remove-ItemProperty -Path "Registry::$parentKey" -Name $valueName -Force -ErrorAction Stop
            Write-Host "Deleted value: $valuePath"
        } catch {
            Write-Warning "Failed to delete value: $valuePath - $_"
        }
    }
}

# Delete registry keys
foreach ($keyPath in $supersededKeys) {
    try {
#        Remove-Item -Path "Registry::$keyPath" -Recurse -Force -ErrorAction Stop
        Write-Host "Deleted key: $keyPath"
    } catch {
        Write-Warning "Failed to delete key: $keyPath - $_"
    }
}
