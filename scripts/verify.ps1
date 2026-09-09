$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$serverRoot = Join-Path $projectRoot "cj-platform-server"
$webRoot = Join-Path $projectRoot "cj-platform-web"

function Test-JavaHome([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $false
    }

    return Test-Path -LiteralPath (Join-Path $Path "bin\java.exe") -PathType Leaf
}

if (-not (Test-JavaHome $env:JAVA_HOME)) {
    Get-Command java -ErrorAction Stop | Out-Null
    $javaSettings = (& cmd.exe /d /c "java -XshowSettings:properties -version 2>&1") | Out-String
    $javaHomeMatch = [regex]::Match($javaSettings, "(?m)^\s*java\.home\s*=\s*(.+?)\s*$")
    if (-not $javaHomeMatch.Success) {
        throw "Unable to determine JAVA_HOME from the installed Java runtime."
    }

    $detectedJavaHome = $javaHomeMatch.Groups[1].Value.Trim()
    if (-not (Test-JavaHome $detectedJavaHome)) {
        throw "Detected JAVA_HOME does not contain bin\java.exe: $detectedJavaHome"
    }

    $env:JAVA_HOME = (Resolve-Path -LiteralPath $detectedJavaHome).Path
}

Write-Host "Using JAVA_HOME=$env:JAVA_HOME"

Write-Host "[1/4] Running backend tests"
Push-Location $serverRoot
try {
    & ".\mvnw.cmd" test
    if ($LASTEXITCODE -ne 0) { throw "Backend tests failed with exit code $LASTEXITCODE" }
}
finally {
    Pop-Location
}

Write-Host "[2/4] Installing locked frontend dependencies"
& pnpm --dir $webRoot install --frozen-lockfile
if ($LASTEXITCODE -ne 0) { throw "Frontend dependency installation failed with exit code $LASTEXITCODE" }

Write-Host "[3/4] Running frontend tests, type checks and build"
& pnpm --dir $webRoot test
if ($LASTEXITCODE -ne 0) { throw "Frontend tests failed with exit code $LASTEXITCODE" }
& pnpm --dir $webRoot typecheck
if ($LASTEXITCODE -ne 0) { throw "Frontend type check failed with exit code $LASTEXITCODE" }
& pnpm --dir $webRoot build:admin
if ($LASTEXITCODE -ne 0) { throw "Frontend build failed with exit code $LASTEXITCODE" }

Write-Host "[4/4] Validating Docker Compose when Docker is available"
if (Get-Command docker -ErrorAction SilentlyContinue) {
    & docker compose -f (Join-Path $projectRoot "docker-compose.yml") config --quiet
    if ($LASTEXITCODE -ne 0) { throw "Docker Compose validation failed with exit code $LASTEXITCODE" }
}
else {
    Write-Warning "Docker CLI is not installed; Compose runtime validation was skipped."
}

Write-Host "Verification completed successfully."
