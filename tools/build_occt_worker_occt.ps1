[CmdletBinding()]
param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",
    [string]$Triplet = "x64-windows",
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
$buildDir = Join-Path $buildRoot "occt_worker_native_occt"
$readinessScript = Join-Path $repoRoot "tools\check_occt_windows_readiness.ps1"

Assert-ChildPath -Path $buildRoot -Parent $repoRoot
Assert-ChildPath -Path $buildDir -Parent $buildRoot

$readinessOutput = & $readinessScript -Triplet $Triplet
$readinessText = $readinessOutput -join [Environment]::NewLine
Write-Host $readinessText
$readiness = $readinessText | ConvertFrom-Json
if (-not $readiness.ready) {
    [Console]::Error.WriteLine("OCCT is not ready for '$Triplet'. Configure vcpkg/OpenCASCADE_DIR/CASROOT and rerun the readiness check.")
    exit 2
}

if ($Clean -and (Test-Path -LiteralPath $buildDir)) {
    Assert-ChildPath -Path $buildDir -Parent $buildRoot
    Remove-Item -LiteralPath $buildDir -Recurse -Force
}

$cmakeConfigureArgs = @(
    "-S", $sourceDir,
    "-B", $buildDir,
    "-DSHELL_CASE_ENABLE_OCCT=ON"
)

if ($readiness.vcpkg.toolchainFound) {
    $cmakeConfigureArgs += "-DCMAKE_TOOLCHAIN_FILE=$($readiness.vcpkg.toolchain)"
}

if ($readiness.opencascade.configPath) {
    $openCascadeDir = Split-Path -Parent $readiness.opencascade.configPath
    $cmakeConfigureArgs += "-DOpenCASCADE_DIR=$openCascadeDir"
}

Push-Location $repoRoot
try {
    cmake @cmakeConfigureArgs
    cmake --build $buildDir --config $Configuration --target occt_worker_native_occt

    $exeCandidates = @(
        (Join-Path $buildDir "$Configuration\occt_worker_native_occt.exe"),
        (Join-Path $buildDir "occt_worker_native_occt.exe")
    )
    $exePath = $exeCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    if (-not $exePath) {
        throw "Expected OCCT worker executable was not found in '$buildDir'."
    }

    Write-Host ""
    Write-Host "OCCT worker:"
    Write-Host $exePath
    Write-Host ""
    Write-Host "Capabilities:"
    Write-Host "$exePath --capabilities"
}
finally {
    Pop-Location
}
