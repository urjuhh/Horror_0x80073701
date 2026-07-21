$registryBase = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages"
$servicingRoot = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing"

$supersededNames = @()
$supersededPaths = @()

# Group packages by base name (before last dot)
$packageKeys = Get-ChildItem -Path $registryBase | Select-Object -ExpandProperty PSChildName
$grouped = $packageKeys | Group-Object {
    $lastDot = $_.LastIndexOf('.')
    if ($lastDot -gt 0) { $_.Substring(0, $lastDot) } else { $_ }
}

foreach ($group in $grouped) {
    $versions = $group.Group | ForEach-Object {
        $build = $_.Substring($_.LastIndexOf('.') + 1)
        if ($build -match '^\d+$') {
            [PSCustomObject]@{
                Name = $_
                Build = [int]$build
                Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\$_"
            }
        }
    }
    $maxBuild = ($versions | Sort-Object Build -Descending | Select-Object -First 1).Build
    $superseded = $versions | Where-Object { $_.Build -lt $maxBuild }
    $supersededNames += $superseded.Name
    $supersededPaths += $superseded.Path
}

# Write superseded keys to file
$supersededPaths | Sort-Object | Out-File -FilePath "superseded_keys.txt" -Encoding ascii

# Search for matching value names only (not key names)
$supersededValuePaths = @()
Get-ChildItem -Path $servicingRoot -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $props = Get-ItemProperty -Path $_.PSPath
        foreach ($name in $props.PSObject.Properties.Name) {
            if ($supersededNames -contains $name) {
                $cleanPath = $_.Name -replace '^HKEY_LOCAL_MACHINE', 'HKLM:'
                $supersededValuePaths += "$cleanPath\$name"
            }
        }
    } catch {}
}

# Write matching values to file
$supersededValuePaths | Sort-Object | Out-File -FilePath "superseded_values.txt" -Encoding ascii
