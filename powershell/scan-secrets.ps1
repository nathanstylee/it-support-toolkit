<#
.SYNOPSIS
Scans files for common secret-like patterns before publishing or sharing.

.DESCRIPTION
This is a generic example for support and internal tools workflows. It uses
ripgrep when available and falls back to Select-String when ripgrep is not
installed. Findings should be reviewed by a person because pattern scans can
produce false positives.

.EXAMPLE
.\scan-secrets.ps1 -Path C:\Repos\SampleProject

.EXAMPLE
.\scan-secrets.ps1 -Path C:\Repos\SampleProject -AdditionalExclude ".venv"
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$Path = (Get-Location).Path,

    [Parameter()]
    [string[]]$AdditionalExclude = @()
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath $Path).Path
$excludedDirectories = @(
    "node_modules",
    ".next",
    "dist",
    "build",
    "logs",
    ".git"
) + $AdditionalExclude

$patterns = @(
    "(^|[^A-Za-z0-9_$])PASSWORD\s*=",
    "(^|[^A-Za-z0-9_$])API[_-]?KEY\s*=",
    "(^|[^A-Za-z0-9_$])ConnectionString\s*=",
    "PRIVATE\s+KEY",
    "Bearer\s+[A-Za-z0-9._~+/=-]{20,}"
)

function Test-IsExcludedPath {
    param(
        [Parameter(Mandatory)]
        [string]$FullName
    )

    $relativePath = $FullName.Substring($root.Length).TrimStart("\", "/")
    if ([string]::IsNullOrWhiteSpace($relativePath)) {
        return $false
    }

    $parts = $relativePath -split '[\\/]'
    return @($parts | Where-Object { $_ -in $excludedDirectories }).Count -gt 0
}

$rg = Get-Command rg -ErrorAction SilentlyContinue
$findings = @()
$useFallback = $false

if ($rg) {
    $rgArgs = @(
        "--hidden",
        "--line-number",
        "--color", "never",
        "--ignore-case"
    )

    foreach ($directory in $excludedDirectories) {
        $rgArgs += "--glob"
        $rgArgs += "!$directory/**"
    }

    foreach ($pattern in $patterns) {
        $rgArgs += "-e"
        $rgArgs += $pattern
    }

    $rgArgs += $root
    try {
        $output = & $rg.Path @rgArgs 2>&1
        $rgExitCode = $LASTEXITCODE

        if ($rgExitCode -gt 1) {
            Write-Warning "ripgrep failed with exit code $rgExitCode. Falling back to Select-String."
            $useFallback = $true
        }
        elseif ($output) {
            $findings = @($output)
        }
    }
    catch {
        Write-Warning "ripgrep was found but could not be started. Falling back to Select-String."
        $useFallback = $true
    }
}
else {
    $useFallback = $true
}

if ($useFallback) {
    $files = Get-ChildItem -LiteralPath $root -File -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { -not (Test-IsExcludedPath -FullName $_.FullName) }

    foreach ($file in $files) {
        foreach ($pattern in $patterns) {
            $matches = Select-String -LiteralPath $file.FullName -Pattern $pattern -CaseSensitive:$false -ErrorAction SilentlyContinue
            foreach ($match in $matches) {
                $findings += "{0}:{1}:{2}" -f $file.FullName, $match.LineNumber, $match.Line.Trim()
            }
        }
    }
}

if ($findings.Count -gt 0) {
    Write-Host "Possible secrets found. Review each result before publishing:" -ForegroundColor Yellow
    $findings | ForEach-Object { Write-Host $_ }
    exit 1
}

Write-Host "No common secret patterns found."
exit 0
