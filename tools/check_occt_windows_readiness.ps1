[CmdletBinding()]
param(
    [string]$Triplet = "x64-windows",
    [switch]$RequireOcct
)

$ErrorActionPreference = "Stop"

function Get-CommandPath {
    param([Parameter(Mandatory = $true)][string]$Name)

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $command) {
        return $null
    }

    return $command.Source
}

function Test-FilePath {
    param([AllowNull()][string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $false
    }

    return Test-Path -LiteralPath $Path -PathType Leaf
}

function Get-FirstExistingFile {
    param([AllowEmptyCollection()][string[]]$Candidates = @())

    foreach ($candidate in $Candidates) {
        if (Test-FilePath $candidate) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }

    return $null
}

function Add-ConfigCandidate {
    param(
        [Parameter(Mandatory = $true)][System.Collections.Generic.List[string]]$Candidates,
        [AllowNull()][string]$Path
    )

    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        $Candidates.Add($Path)
    }
}

$cmakePath = Get-CommandPath "cmake"
$vcpkgPath = Get-CommandPath "vcpkg"
$vcpkgRoot = $env:VCPKG_ROOT
$openCascadeDir = $env:OpenCASCADE_DIR
$casRoot = $env:CASROOT

$vcpkgToolchain = $null
if (-not [string]::IsNullOrWhiteSpace($vcpkgRoot)) {
    $vcpkgToolchain = Join-Path $vcpkgRoot "scripts\buildsystems\vcpkg.cmake"
}

$configCandidates = [System.Collections.Generic.List[string]]::new()
if (-not [string]::IsNullOrWhiteSpace($openCascadeDir)) {
    Add-ConfigCandidate -Candidates $configCandidates -Path (Join-Path $openCascadeDir "OpenCASCADEConfig.cmake")
    Add-ConfigCandidate -Candidates $configCandidates -Path $openCascadeDir
}

if (-not [string]::IsNullOrWhiteSpace($casRoot)) {
    Add-ConfigCandidate -Candidates $configCandidates -Path (Join-Path $casRoot "cmake\OpenCASCADEConfig.cmake")
    Add-ConfigCandidate -Candidates $configCandidates -Path (Join-Path $casRoot "lib\cmake\opencascade\OpenCASCADEConfig.cmake")
    Add-ConfigCandidate -Candidates $configCandidates -Path (Join-Path $casRoot "lib\cmake\OpenCASCADE\OpenCASCADEConfig.cmake")
}

if (-not [string]::IsNullOrWhiteSpace($vcpkgRoot)) {
    Add-ConfigCandidate -Candidates $configCandidates -Path (Join-Path $vcpkgRoot "installed\$Triplet\share\opencascade\OpenCASCADEConfig.cmake")
    Add-ConfigCandidate -Candidates $configCandidates -Path (Join-Path $vcpkgRoot "installed\$Triplet\share\OpenCASCADE\OpenCASCADEConfig.cmake")
    Add-ConfigCandidate -Candidates $configCandidates -Path (Join-Path $vcpkgRoot "installed\$Triplet\share\occt\OpenCASCADEConfig.cmake")
}

$openCascadeConfig = Get-FirstExistingFile -Candidates $configCandidates.ToArray()
$ready = -not [string]::IsNullOrWhiteSpace($openCascadeConfig)
$vcpkgToolchainFound = Test-FilePath $vcpkgToolchain

$recommendedNext = @()
if (-not $cmakePath) {
    $recommendedNext += "Install CMake and make it available on PATH."
}
if (-not $vcpkgPath -and [string]::IsNullOrWhiteSpace($vcpkgRoot)) {
    $recommendedNext += "Install vcpkg or set VCPKG_ROOT to an existing vcpkg checkout."
}
if (-not $ready) {
    $recommendedNext += "Install OpenCASCADE for the $Triplet triplet or set OpenCASCADE_DIR/CASROOT to an installed OCCT package."
    $recommendedNext += "Recommended developer path: vcpkg install opencascade:$Triplet, then configure the native worker with the vcpkg toolchain."
}
if ($ready) {
    $recommendedNext += "OCCT package config was found. The next native slice can add an opt-in OCCT-linked target."
}

$summary = [ordered]@{
    schema = "shell_case.occt.windows_readiness"
    version = 1
    ready = $ready
    triplet = $Triplet
    cmake = [ordered]@{
        found = -not [string]::IsNullOrWhiteSpace($cmakePath)
        path = $cmakePath
    }
    vcpkg = [ordered]@{
        found = -not [string]::IsNullOrWhiteSpace($vcpkgPath)
        path = $vcpkgPath
        root = $vcpkgRoot
        toolchain = $vcpkgToolchain
        toolchainFound = $vcpkgToolchainFound
    }
    opencascade = [ordered]@{
        configFound = $ready
        configPath = $openCascadeConfig
        openCascadeDir = $openCascadeDir
        casRoot = $casRoot
        checkedConfigCandidates = $configCandidates.ToArray()
    }
    recommendedNext = $recommendedNext
}

$summary | ConvertTo-Json -Depth 8

if ($RequireOcct -and -not $ready) {
    exit 2
}
