<#
.SYNOPSIS
Safely previews and optionally removes common generated project files.

.DESCRIPTION
Default behavior is a dry run. The script lists cleanup candidates and estimates
reclaimable size, but it does not delete anything unless -Apply is provided.

Safety behavior:
- .git directories are always excluded.
- -Apply is required before deletion can occur.
- Supports PowerShell -WhatIf through ShouldProcess.
- Review the dry-run output before applying changes.

.EXAMPLE
.\safe-project-cleanup.ps1 -Path C:\Repos\SampleProject

.EXAMPLE
.\safe-project-cleanup.ps1 -Path C:\Repos\SampleProject -Apply -WhatIf

.EXAMPLE
.\safe-project-cleanup.ps1 -Path C:\Repos\SampleProject -Apply
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$Path = (Get-Location).Path,

    [Parameter()]
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath $Path).Path
$generatedDirectoryNames = @(
    "node_modules",
    ".next",
    "dist",
    "build",
    "out",
    ".cache",
    "coverage",
    "logs"
)
$tempFilePatterns = @(
    "*.log",
    "*.tmp",
    "npm-debug.log*"
)
$excludedDirectoryNames = @(".git")

function Test-IsUnderExcludedDirectory {
    param(
        [Parameter(Mandatory)]
        [string]$FullName
    )

    $relativePath = $FullName.Substring($root.Length).TrimStart("\", "/")
    if ([string]::IsNullOrWhiteSpace($relativePath)) {
        return $false
    }

    $parts = $relativePath -split '[\\/]'
    return @($parts | Where-Object { $_ -in $excludedDirectoryNames }).Count -gt 0
}

function Get-ItemSizeBytes {
    param(
        [Parameter(Mandatory)]
        [System.IO.FileSystemInfo]$Item
    )

    if ($Item -is [System.IO.FileInfo]) {
        return [int64]$Item.Length
    }

    $sum = [int64]0
    Get-ChildItem -LiteralPath $Item.FullName -Recurse -Force -File -ErrorAction SilentlyContinue |
        ForEach-Object { $sum += [int64]$_.Length }

    return $sum
}

function Format-Size {
    param([int64]$Bytes)

    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    return "$Bytes bytes"
}

$candidateMap = @{}

Get-ChildItem -LiteralPath $root -Directory -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -in $generatedDirectoryNames -and
        -not (Test-IsUnderExcludedDirectory -FullName $_.FullName)
    } |
    ForEach-Object {
        $candidateMap[$_.FullName] = [pscustomobject]@{
            Type = "Directory"
            Name = $_.Name
            FullName = $_.FullName
            SizeBytes = Get-ItemSizeBytes -Item $_
        }
    }

foreach ($pattern in $tempFilePatterns) {
    Get-ChildItem -LiteralPath $root -File -Recurse -Force -Filter $pattern -ErrorAction SilentlyContinue |
        Where-Object {
            -not (Test-IsUnderExcludedDirectory -FullName $_.FullName)
        } |
        ForEach-Object {
            $insideSelectedDirectory = $false
            foreach ($candidate in $candidateMap.Values) {
                if ($candidate.Type -eq "Directory" -and $_.FullName.StartsWith($candidate.FullName + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
                    $insideSelectedDirectory = $true
                    break
                }
            }

            if (-not $insideSelectedDirectory) {
                $candidateMap[$_.FullName] = [pscustomobject]@{
                    Type = "File"
                    Name = $_.Name
                    FullName = $_.FullName
                    SizeBytes = Get-ItemSizeBytes -Item $_
                }
            }
        }
}

$candidates = @($candidateMap.Values | Sort-Object Type, FullName)
$totalBytes = [int64](($candidates | Measure-Object -Property SizeBytes -Sum).Sum)

Write-Host "Cleanup root: $root"
Write-Host "Mode: $(if ($Apply) { 'Apply' } else { 'Dry run' })"
Write-Host "Candidates: $($candidates.Count)"
Write-Host "Estimated reclaimable size: $(Format-Size -Bytes $totalBytes)"
Write-Host ""

if ($candidates.Count -eq 0) {
    Write-Host "No cleanup candidates found."
    return
}

$candidates |
    Select-Object Type, Name, @{ Name = "Size"; Expression = { Format-Size -Bytes $_.SizeBytes } }, FullName |
    Format-Table -AutoSize

if (-not $Apply) {
    Write-Host ""
    Write-Host "Dry run only. Re-run with -Apply to remove these candidates."
    return
}

foreach ($candidate in $candidates) {
    if ($PSCmdlet.ShouldProcess($candidate.FullName, "Remove generated project item")) {
        Remove-Item -LiteralPath $candidate.FullName -Recurse -Force
    }
}

Write-Host "Cleanup complete."
