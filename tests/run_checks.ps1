param(
    [Parameter(Mandatory = $true)]
    [string]$Godot
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = (Get-Command $Godot -ErrorAction Stop).Source
$checkDirectory = Join-Path $projectRoot '.godot/checks'
New-Item -ItemType Directory -Force -Path $checkDirectory | Out-Null
$previousAppData = $env:APPDATA

function Invoke-GodotCheck([string]$Name, [string[]]$EngineArguments) {
    $outputPath = Join-Path $checkDirectory "$Name.log"
    $errorPath = Join-Path $checkDirectory "$Name-errors.log"
    $process = Start-Process -FilePath $enginePath -ArgumentList $EngineArguments -WorkingDirectory $projectRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput $outputPath -RedirectStandardError $errorPath
    if (-not $process.WaitForExit(60000)) {
        $process.Kill()
        $process.WaitForExit()
        throw "$Name exceeded 60 seconds."
    }
    Get-Content -LiteralPath $outputPath
    Get-Content -LiteralPath $errorPath
    if ($process.ExitCode -ne 0) {
        throw "$Name failed with exit code $($process.ExitCode)."
    }
    # Godot can return 0 despite script/resource errors. Treat all diagnostics
    # except the known sandbox certificate-store failure as failed validation.
    $diagnostics = (Get-Content -LiteralPath $outputPath -Raw) + "`n" + (Get-Content -LiteralPath $errorPath -Raw)
    $unexpected = $diagnostics -replace '(?m)^ERROR: Failed to read the root certificate store\.\r?\n\s+at: get_system_ca_certificates[^\r\n]*\r?\n?', ''
    if ($unexpected -match '(?m)(SCRIPT ERROR:|ERROR:|WARNING:)') {
        throw "$Name reported engine diagnostics; inspect $errorPath."
    }
    if ($diagnostics -match 'Failed to read the root certificate store') {
        Write-Warning "${Name}: Windows certificate store could not be read (environment limitation)."
    }
}

try {
    # Keep test-generated user data inside the repository's ignored cache.
    $env:APPDATA = Join-Path $checkDirectory 'user_data'
    New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null
    Invoke-GodotCheck 'version' @('--version')
    $version = (Get-Content (Join-Path $checkDirectory 'version.log') -Raw).Trim()
    if ($version -notmatch '^4\.6\.3\.') {
        Write-Warning "Target version is 4.6.3; checks are running with $version."
    }
    Invoke-GodotCheck 'import' @('--headless', '--path', '.', '--editor', '--import')
    Invoke-GodotCheck 'startup' @('--headless', '--path', '.', '--quit-after', '120')
    Invoke-GodotCheck 'fps' @('--headless', '--path', '.', '--script', 'res://tests/fps_checks.gd')
    Invoke-GodotCheck 'weapon' @('--headless', '--path', '.', '--script', 'res://tests/weapon_checks.gd')
    Invoke-GodotCheck 'arms-startup' @('--headless', '--path', '.', 'res://scenes/previews/arms_preview.tscn', '--quit-after', '120')
    Invoke-GodotCheck 'arms' @('--headless', '--path', '.', '--script', 'res://tests/arms_import_checks.gd')
    Invoke-GodotCheck 'weapon-preview' @('--headless', '--path', '.', 'res://scenes/previews/weapon_asset_preview.tscn', '--quit-after', '120')
    Invoke-GodotCheck 'weapon-assets' @('--headless', '--path', '.', '--script', 'res://tests/weapon_asset_checks.gd')
    Invoke-GodotCheck 'foundation-polish' @('--headless', '--path', '.', '--script', 'res://tests/foundation_polish_checks.gd')
    Write-Output 'All checks completed. Review any environment warnings above.'
}
finally {
    $env:APPDATA = $previousAppData
}

