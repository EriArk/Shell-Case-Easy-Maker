[CmdletBinding()]
param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",
    [switch]$Clean
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
$sourceDir = Join-Path $repoRoot "occt_worker\native"
$buildRoot = Join-Path $repoRoot "build"
$buildDir = Join-Path $buildRoot "occt_worker_native"

Assert-ChildPath -Path $buildRoot -Parent $repoRoot
Assert-ChildPath -Path $buildDir -Parent $buildRoot

if ($Clean -and (Test-Path -LiteralPath $buildDir)) {
    Assert-ChildPath -Path $buildDir -Parent $buildRoot
    Remove-Item -LiteralPath $buildDir -Recurse -Force
}

Push-Location $repoRoot
try {
    cmake -S $sourceDir -B $buildDir
    cmake --build $buildDir --config $Configuration --target occt_worker_native_stub

    $exeCandidates = @(
        (Join-Path $buildDir "$Configuration\occt_worker_native_stub.exe"),
        (Join-Path $buildDir "occt_worker_native_stub.exe")
    )
    $exePath = $exeCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    if (-not $exePath) {
        throw "Expected native worker stub executable was not found in '$buildDir'."
    }

    Write-Host ""
    Write-Host "Native worker stub:"
    Write-Host $exePath
    Write-Host ""
    Write-Host "Capabilities:"
    Write-Host "$exePath --capabilities"
}
finally {
    Pop-Location
}
