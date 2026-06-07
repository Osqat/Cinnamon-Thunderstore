# Package-Thunderstore.ps1
# Builds the Thunderstore GUI-only Cinnamon package and writes dist/Cinnamon-<version>.zip.
# Usage: .\Package-Thunderstore.ps1 [-NoBuild]

param([switch]$NoBuild)

$ErrorActionPreference = "Stop"
$root    = $PSScriptRoot
$tsDir   = "$root\thunderstore"
$distDir = "$root\dist"

if (-not $NoBuild) {
    Write-Host "Building Thunderstore DLL..."
    & dotnet build "$root\Cinnamon.csproj" -c Release --nologo -v quiet
    if ($LASTEXITCODE -ne 0) { throw "Build failed." }
}

$pluginDll = "$root\plugins\Cinnamon.dll"
$dllVer = [System.Reflection.AssemblyName]::GetAssemblyName($pluginDll).Version.ToString(3)
$manifest = Get-Content "$tsDir\manifest.json" -Raw | ConvertFrom-Json
$tsVer = [string]$manifest.version_number
if ([string]::IsNullOrWhiteSpace($tsVer)) { $tsVer = $dllVer }

Write-Host "Packaging Thunderstore v$tsVer (DLL v$dllVer)..."

$missingIcon = -not (Test-Path "$tsDir\icon.png")
if ($missingIcon) {
    Write-Warning "thunderstore\icon.png not found - Thunderstore requires a 256x256 PNG icon. Add one before uploading."
}

$stage = "$distDir\_stage"
Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory "$stage\BepInEx\plugins\Cinnamon" -Force | Out-Null

Copy-Item $pluginDll "$stage\BepInEx\plugins\Cinnamon\"
if (-not $missingIcon) { Copy-Item "$tsDir\icon.png" $stage\ }
Copy-Item "$tsDir\README.md" $stage\

$manifest.version_number = $tsVer
$manifestJson = $manifest | ConvertTo-Json -Depth 5
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText("$stage\manifest.json", $manifestJson, $utf8NoBom)

New-Item -ItemType Directory $distDir -Force | Out-Null
$zipPath = "$distDir\Cinnamon-$tsVer.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    $files = Get-ChildItem -LiteralPath $stage -Recurse -File
    foreach ($file in $files) {
        $relative = $file.FullName.Substring($stage.Length + 1).Replace('\', '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $relative) | Out-Null
    }
}
finally {
    $zip.Dispose()
}

Remove-Item $stage -Recurse -Force

Write-Host ""
Write-Host "Done: $zipPath"
Write-Host ""
Write-Host "Zip contents:"
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
try {
    $zip.Entries | ForEach-Object { Write-Host ('  ' + $_.FullName) }
}
finally {
    $zip.Dispose()
}
