[CmdletBinding()]
param(
    [switch]$SkipBuild,
    [switch]$NativeOcct,
    [switch]$SkipNativeOcctBuild
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
$nativeWorkerBuildScript = Join-Path $repoRoot "tools\build_occt_worker_occt.ps1"
$nativeWorkerSourceDir = Join-Path $repoRoot "build\occt_worker_native_occt\Release"
$nativeWorkerSourceExe = Join-Path $nativeWorkerSourceDir "occt_worker_native_occt.exe"
$nativeWorkerTargetDir = Join-Path $targetDir "occt_worker\native"
$nativeWorkerTargetExe = Join-Path $nativeWorkerTargetDir "occt_worker_native_occt.exe"

Assert-ChildPath -Path $releaseRoot -Parent $repoRoot
Assert-ChildPath -Path $targetDir -Parent $releaseRoot
Assert-ChildPath -Path $nativeWorkerTargetDir -Parent $targetDir

Push-Location $repoRoot
try {
    if ($NativeOcct -and -not $SkipNativeOcctBuild) {
        & $nativeWorkerBuildScript -AllowVcpkgInstall
    }

    if (-not $SkipBuild) {
        $flutterBuildArgs = @("build", "windows", "--release")
        if ($NativeOcct) {
            $flutterBuildArgs += "--dart-define=SHELL_CASE_GEOMETRY_BACKEND=native_occt"
        }

        flutter @flutterBuildArgs
    }

    if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
        throw "Flutter release bundle not found: $sourceDir"
    }

    if ($NativeOcct -and -not (Test-Path -LiteralPath $nativeWorkerSourceExe -PathType Leaf)) {
        throw "Native OCCT worker executable not found: $nativeWorkerSourceExe"
    }

    if (Test-Path -LiteralPath $targetDir) {
        Assert-ChildPath -Path $targetDir -Parent $releaseRoot
        Remove-Item -LiteralPath $targetDir -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    Get-ChildItem -LiteralPath $sourceDir -Force |
        Copy-Item -Destination $targetDir -Recurse -Force

    if ($NativeOcct) {
        New-Item -ItemType Directory -Force -Path $nativeWorkerTargetDir | Out-Null
        Get-ChildItem -LiteralPath $nativeWorkerSourceDir -Force |
            Copy-Item -Destination $nativeWorkerTargetDir -Recurse -Force

        if (-not (Test-Path -LiteralPath $nativeWorkerTargetExe -PathType Leaf)) {
            throw "Expected native OCCT worker executable was not copied: $nativeWorkerTargetExe"
        }
    }

    if (-not (Test-Path -LiteralPath $exePath -PathType Leaf)) {
        throw "Expected executable was not copied: $exePath"
    }

    Write-Host ""
    Write-Host "Latest Windows bundle:"
    Write-Host $targetDir
    if ($NativeOcct) {
        Write-Host ""
        Write-Host "Native OCCT worker:"
        Write-Host $nativeWorkerTargetExe
    }
    Write-Host ""
    Write-Host "Open:"
    Write-Host $exePath
}
finally {
    Pop-Location
}
