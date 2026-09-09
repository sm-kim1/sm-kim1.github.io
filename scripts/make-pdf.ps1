#Requires -Version 5.1
<#
.SYNOPSIS
Create a fresh PDF from the running Jekyll preview using Windows Chrome or Edge.
.EXAMPLE
powershell -ExecutionPolicy Bypass -File scripts/make-pdf.ps1 /print/ portfolio_sangmin.pdf
.EXAMPLE
.\scripts\make-pdf.ps1 -BaseUrl http://127.0.0.1:4001 -OutputFile portfolio_sangmin.pdf
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)][string]$Page = '/print/',
    [Parameter(Position = 1)][string]$OutputFile = 'portfolio_sangmin.pdf',
    [uri]$BaseUrl = 'http://127.0.0.1:4000',
    [string]$BrowserPath,
    [ValidateRange(5, 300)][int]$TimeoutSeconds = 60
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if ($BaseUrl.Scheme -notin @('http', 'https')) { throw 'BaseUrl must use HTTP or HTTPS.' }
if (-not $Page.StartsWith('/') -or $Page.StartsWith('//')) { throw 'Page must be a path such as /print/.' }
$pageUrl = [uri]::new($BaseUrl, $Page)
try {
    $response = Invoke-WebRequest -Uri $pageUrl -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -ne 200 -or $response.Headers['Content-Type'] -notmatch 'text/html') {
        throw 'The preview did not return an HTML page.'
    }
} catch {
    throw "Cannot read $pageUrl. Start Jekyll and check -BaseUrl. $($_.Exception.Message)"
}

if (-not $BrowserPath) {
    $candidates = @()
    foreach ($app in @('chrome.exe', 'msedge.exe')) {
        foreach ($hive in @('HKCU:', 'HKLM:')) {
            $key = "$hive\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$app"
            if (Test-Path -LiteralPath $key) {
                $candidates += (Get-Item -LiteralPath $key).GetValue('')
            }
        }
    }
    foreach ($base in @($env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:LOCALAPPDATA)) {
        if ($base) {
            $candidates += Join-Path $base 'Google\Chrome\Application\chrome.exe'
            $candidates += Join-Path $base 'Microsoft\Edge\Application\msedge.exe'
        }
    }
    $BrowserPath = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } | Select-Object -First 1
}
if (-not $BrowserPath -or -not (Test-Path -LiteralPath $BrowserPath -PathType Leaf)) {
    throw 'Windows Chrome or Edge was not found. Supply -BrowserPath with its executable path.'
}
if ([IO.Path]::IsPathRooted($OutputFile)) {
    $outputPath = [IO.Path]::GetFullPath($OutputFile)
} else {
    $outputPath = [IO.Path]::GetFullPath((Join-Path $projectRoot $OutputFile))
}
if ([IO.Path]::GetExtension($outputPath) -ne '.pdf') { throw 'OutputFile must have a .pdf extension.' }
$outputDirectory = Split-Path -Parent $outputPath
if (-not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
    throw "Output directory does not exist: $outputDirectory"
}

$tempRoot = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\')
$runDirectory = Join-Path $tempRoot ('portfolio-pdf-' + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $runDirectory
$temporaryPdf = Join-Path $runDirectory 'fresh.pdf'
$profile = Join-Path $runDirectory 'profile'
$browserProcess = $null
try {
    $browserArguments = @(
        '--headless=new', '--disable-gpu', '--no-first-run', '--no-default-browser-check',
        "--user-data-dir=`"$profile`"", '--no-pdf-header-footer',
        '--run-all-compositor-stages-before-draw', '--virtual-time-budget=5000',
        "--print-to-pdf=`"$temporaryPdf`"", "`"$($pageUrl.AbsoluteUri)`""
    )
    $browserProcess = Start-Process -FilePath $BrowserPath -ArgumentList $browserArguments -PassThru -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $runDirectory 'stdout.log') -RedirectStandardError (Join-Path $runDirectory 'stderr.log')
    # Retain the process handle so Windows PowerShell 5.1 can read ExitCode after exit.
    $null = $browserProcess.Handle
    $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
    do {
        Start-Sleep -Milliseconds 250
        $browserProcess.Refresh()
        if ($browserProcess.HasExited) { break }
    } while ([DateTime]::UtcNow -lt $deadline)
    if (-not $browserProcess.HasExited) { throw "PDF generation timed out after $TimeoutSeconds seconds." }
    $browserProcess.WaitForExit()
    if ($browserProcess.ExitCode -ne 0) { throw "Browser exited with code $($browserProcess.ExitCode)." }
    if (-not (Test-Path -LiteralPath $temporaryPdf -PathType Leaf)) { throw 'The browser did not create a new PDF.' }
    $pdfBytes = [IO.File]::ReadAllBytes($temporaryPdf)
    if ($pdfBytes.Length -lt 100 -or [Text.Encoding]::ASCII.GetString($pdfBytes, 0, 5) -ne '%PDF-') {
        throw 'The new output is not a valid PDF file.'
    }
    $tail = [Text.Encoding]::ASCII.GetString($pdfBytes, [Math]::Max(0, $pdfBytes.Length - 1024), [Math]::Min(1024, $pdfBytes.Length))
    if ($tail -notmatch '%%EOF') { throw 'The new PDF is incomplete.' }
    Copy-Item -LiteralPath $temporaryPdf -Destination $outputPath -Force
    Write-Output "Created: $outputPath ($($pdfBytes.Length) bytes)"
} finally {
    if ($browserProcess -and -not $browserProcess.HasExited) {
        Stop-Process -Id $browserProcess.Id -Force -ErrorAction SilentlyContinue
        $null = $browserProcess.WaitForExit(5000)
    }
    # Only remove this invocation's GUID directory, after checking its absolute location.
    $resolvedRunDirectory = [IO.Path]::GetFullPath($runDirectory)
    if ($resolvedRunDirectory.StartsWith($tempRoot + '\', [StringComparison]::OrdinalIgnoreCase) -and
        (Split-Path -Leaf $resolvedRunDirectory) -match '^portfolio-pdf-[0-9a-f]{32}$') {
        Remove-Item -LiteralPath $resolvedRunDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }
}
