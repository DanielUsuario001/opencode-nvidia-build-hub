# start.ps1  -  Launcher para OpenCode + NVIDIA Build (Windows PowerShell)
#
# Carga .env, exporta variables a la sesion actual y arranca opencode.
#
# Uso:   .\start.ps1
#        .\start.ps1 -Model nvidia-gptoss/120b
#        .\start.ps1 -Test          # prueba la API con scripts/test_nvidia.py

param(
    [string]$Model = "",
    [switch]$Test
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

function Test-PlausibleSecret {
    param(
        [string]$Name,
        [string]$Value
    )
    if (-not $Value) { return $false }
    if ($Name -like "NVIDIA_API_KEY*") {
        return $Value -match '^nvapi-[A-Za-z0-9_-]{24,}$'
    }
    if ($Name -like "GOOGLE*") {
        return $Value -match '^AIzaSy[A-Za-z0-9_-]{30,}$'
    }
    if ($Name -like "BRAVE*") {
        return $Value.Length -ge 20 -and $Value -match '^[A-Za-z0-9_-]+$'
    }
    return $false
}

# 1) Cargar .env
$envFile = Join-Path $root ".env"
if (-not (Test-Path $envFile)) {
    Write-Host "ERROR: no existe .env. Copia .env.example a .env y rellena tus claves." -ForegroundColor Red
    exit 1
}

$loadedKeys = @()
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
    $name, $value = $_.Split('=', 2)
    $name = $name.Trim()
    $value = $value.Trim().Trim('"').Trim("'")
    if (-not $name) { return }
    Set-Item -Path "Env:$name" -Value $value
    if (Test-PlausibleSecret -Name $name -Value $value) {
        $loadedKeys += $name
    }
}

if ($loadedKeys.Count -eq 0) {
    Write-Host "ERROR: no hay ninguna API key reconocible en .env." -ForegroundColor Red
    Write-Host "      NVIDIA: nvapi- + al menos 24 caracteres (ej. build.nvidia.com)." -ForegroundColor DarkYellow
    Write-Host "      Google: clave que empiece por AIzaSy (Gemini)." -ForegroundColor DarkYellow
    Write-Host "      Brave: al menos 20 caracteres alfanumericos." -ForegroundColor DarkYellow
    Write-Host "      Copia .env.example a .env y rellena al menos la clave del modelo por defecto (ver README)." -ForegroundColor DarkYellow
    exit 1
}

Write-Host "OK  Claves detectadas:" -ForegroundColor Green
foreach ($k in $loadedKeys) {
    $v = (Get-Item "Env:$k").Value
    $tail = $v.Substring([Math]::Max(0, $v.Length - 6))
    Write-Host "      $k = ...$tail" -ForegroundColor DarkGray
}

# 2) Modo test
if ($Test) {
    $req = Join-Path $root "scripts\requirements.txt"
    $tst = Join-Path $root "scripts\test_nvidia.py"
    if (-not (Test-Path $req) -or -not (Test-Path $tst)) {
        Write-Host "ERROR: faltan scripts\requirements.txt o scripts\test_nvidia.py" -ForegroundColor Red
        exit 1
    }
    Write-Host "`nProbando la API con Python..." -ForegroundColor Cyan
    if (-not (Test-Path ".venv")) {
        python -m venv .venv
    }
    & .\.venv\Scripts\Activate.ps1
    pip install -q -r scripts/requirements.txt
    python scripts/test_nvidia.py
    exit $LASTEXITCODE
}

# 3) Verificar que opencode este instalado
$opencodeCmd = Get-Command opencode -ErrorAction SilentlyContinue
if (-not $opencodeCmd) {
    Write-Host "OpenCode no esta instalado. Instalando con npm..." -ForegroundColor Yellow
    $npmCmd = Get-Command npm -ErrorAction SilentlyContinue
    if (-not $npmCmd) {
        Write-Host "ERROR: necesitas Node.js + npm. Instalalos desde https://nodejs.org" -ForegroundColor Red
        exit 1
    }
    npm install -g opencode-ai
}

# 4) Lanzar OpenCode
Write-Host "`nLanzando OpenCode..." -ForegroundColor Cyan
if ($Model) {
    opencode --model $Model
} else {
    opencode
}
