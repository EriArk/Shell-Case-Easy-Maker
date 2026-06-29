[CmdletBinding()]
param(
    [string]$VcpkgRoot,
    [string]$Triplet = "x64-windows",
    [switch]$InstallOpenCascade,
    [switch]$SetUserEnvironment,
    [switch]$PlanOnly
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
        throw "Refusing to use '$fullPath' because it is outside '$fullParent'."
    }
}

function Get-CommandPath {
    param([Parameter(Mandatory = $true)][string]$Name)

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $command) {
        return $null
    }

    return $command.Source
}

function Invoke-LoggedCommand {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$Arguments = @(),
        [string]$WorkingDirectory
    )

    Write-Host ""
    Write-Host "> $FilePath $($Arguments -join ' ')"
    if ([string]::IsNullOrWhiteSpace($WorkingDirectory)) {
        & $FilePath @Arguments
    }
    else {
        Push-Location $WorkingDirectory
        try {
            & $FilePath @Arguments
        }
        finally {
            Pop-Location
        }
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code $LASTEXITCODE`: $FilePath"
    }
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$externalRoot = Join-Path $repoRoot "external"
if ([string]::IsNullOrWhiteSpace($VcpkgRoot)) {
    $VcpkgRoot = Join-Path $externalRoot "vcpkg"
}

$vcpkgRootFull = Get-FullPath $VcpkgRoot
$manifestRoot = Join-Path $repoRoot "occt_worker\native"
$manifestPath = Join-Path $manifestRoot "vcpkg.json"
$readinessScript = Join-Path $repoRoot "tools\check_occt_windows_readiness.ps1"
$vcpkgExe = Join-Path $vcpkgRootFull "vcpkg.exe"
$bootstrapBat = Join-Path $vcpkgRootFull "bootstrap-vcpkg.bat"

Assert-ChildPath -Path $vcpkgRootFull -Parent $externalRoot

$installStep = "Skipped. Add -InstallOpenCascade to restore the opencascade manifest dependency."
if ($InstallOpenCascade) {
    $installStep = "Run vcpkg manifest install from $manifestRoot for $Triplet."
}

$plan = [ordered]@{
    schema = "shell_case.occt.vcpkg_bootstrap"
    version = 1
    vcpkgRoot = $vcpkgRootFull
    triplet = $Triplet
    installOpenCascade = [bool]$InstallOpenCascade
    setUserEnvironment = [bool]$SetUserEnvironment
    steps = @(
        "Create $externalRoot if needed.",
        "Clone https://github.com/microsoft/vcpkg.git into $vcpkgRootFull if missing.",
        "Run bootstrap-vcpkg.bat -disableMetrics if vcpkg.exe is missing.",
        "Set VCPKG_ROOT for this process.",
        $installStep,
        "Run tools\check_occt_windows_readiness.ps1 for a final JSON status."
    )
}

if ($PlanOnly) {
    $plan | ConvertTo-Json -Depth 6
    return
}

$gitPath = Get-CommandPath "git"
if (-not $gitPath) {
    throw "Git is required to clone vcpkg."
}

New-Item -ItemType Directory -Force -Path $externalRoot | Out-Null

if (-not (Test-Path -LiteralPath $vcpkgRootFull -PathType Container)) {
    Invoke-LoggedCommand -FilePath $gitPath -Arguments @(
        "clone",
        "https://github.com/microsoft/vcpkg.git",
        $vcpkgRootFull
    )
}
elseif (-not (Test-Path -LiteralPath $bootstrapBat -PathType Leaf)) {
    throw "Existing VcpkgRoot '$vcpkgRootFull' does not look like a vcpkg checkout."
}
else {
    Write-Host "Using existing vcpkg checkout:"
    Write-Host $vcpkgRootFull
}

if (-not (Test-Path -LiteralPath $vcpkgExe -PathType Leaf)) {
    Invoke-LoggedCommand -FilePath $bootstrapBat -Arguments @("-disableMetrics") -WorkingDirectory $vcpkgRootFull
}
else {
    Write-Host "vcpkg is already bootstrapped:"
    Write-Host $vcpkgExe
}

$env:VCPKG_ROOT = $vcpkgRootFull
if ($SetUserEnvironment) {
    [Environment]::SetEnvironmentVariable("VCPKG_ROOT", $vcpkgRootFull, "User")
    Write-Host "User VCPKG_ROOT set to:"
    Write-Host $vcpkgRootFull
}

if ($InstallOpenCascade) {
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        throw "Expected vcpkg manifest was not found: $manifestPath"
    }

    Invoke-LoggedCommand -FilePath $vcpkgExe -Arguments @(
        "install",
        "--triplet=$Triplet",
        "--clean-after-build"
    ) -WorkingDirectory $manifestRoot
}
else {
    Write-Host "OpenCASCADE manifest restore skipped. Add -InstallOpenCascade when a large dependency restore is expected."
}

Write-Host ""
Write-Host "Readiness:"
& $readinessScript -Triplet $Triplet

Write-Host ""
Write-Host "Next OCCT worker build:"
Write-Host "powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_occt_worker_occt.ps1 -AllowVcpkgInstall"
