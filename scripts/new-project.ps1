# Crea la carpeta base de un nuevo SaaS bajo projects/<nombre>/
# Uso: .\scripts\new-project.ps1 mi-saas

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$safe = $Name.Trim() -replace '[^a-zA-Z0-9_-]', '-'
if (-not $safe) {
    Write-Host "ERROR: nombre invalido" -ForegroundColor Red
    exit 1
}

$dest = Join-Path $root "projects\$safe"
if (Test-Path $dest) {
    Write-Host "ERROR: ya existe $dest" -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Path $dest | Out-Null

$readme = @"
# $safe

Proyecto generado con el hub OpenCode + NVIDIA Build.

## Siguientes pasos

1. Desde la raiz del repositorio del hub, ejecuta .\start.ps1 y abre OpenCode.
2. En OpenCode, describe la app que quieres en esta carpeta (stack: Next.js 16, etc.).
3. Crea .env.local aqui para secretos del SaaS (Supabase, Stripe, etc.).

Este directorio puede tener su propio git init si quieres versionarlo aparte.
"@

Set-Content -Path (Join-Path $dest "README.md") -Value $readme -Encoding utf8

$gitignore = @"
.env
.env.local
.env.*.local
node_modules/
.next/
out/
dist/
.vercel
*.log
.DS_Store
"@

Set-Content -Path (Join-Path $dest ".gitignore") -Value $gitignore -Encoding utf8

Write-Host "OK  Creado $dest" -ForegroundColor Green
