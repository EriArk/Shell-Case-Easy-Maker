[CmdletBinding()]
param(
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

function Get-FullPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return [System.IO.Path]::GetFullPath($Path)
}

function Assert-ChildPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Parent
    )

    $fullPath = Get-FullPath $Path
    $fullParent = Get-FullPath $Parent
    if (-not $fullParent.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $fullParent = $fullParent + [System.IO.Path]::DirectorySeparatorChar
    }

    if (-not $fullPath.StartsWith($fullParent, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to modify '$fullPath' because it is outside '$fullParent'."
    }
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$sourceDir = Join-Path $repoRoot "build\windows\x64\runner\Release"
$releaseRoot = Join-Path $repoRoot "releases"
$targetDir = Join-Path $releaseRoot "latest\windows"
$exePath = Join-Path $targetDir "shell_case_easy_maker.exe"

Assert-ChildPath -Path $releaseRoot -Parent $repoRoot
Assert-ChildPath -Path $targetDir -Parent $releaseRoot

Push-Location $repoRoot
try {
    if (-not $SkipBuild) {
        flutter build windows --release
    }

    if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
        throw "Flutter release bundle not found: $sourceDir"
    }

    if (Test-Path -LiteralPath $targetDir) {
        Assert-ChildPath -Path $targetDir -Parent $releaseRoot
        Remove-Item -LiteralPath $targetDir -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    Get-ChildItem -LiteralPath $sourceDir -Force |
        Copy-Item -Destination $targetDir -Recurse -Force

    if (-not (Test-Path -LiteralPath $exePath -PathType Leaf)) {
        throw "Expected executable was not copied: $exePath"
    }

    Write-Host ""
    Write-Host "Latest Windows bundle:"
    Write-Host $targetDir
    Write-Host ""
    Write-Host "Open:"
    Write-Host $exePath
}
finally {
    Pop-Location
}
