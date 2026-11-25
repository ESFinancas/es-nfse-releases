# Instalador do ES NFS-e (baixado pelo "Instalar ES NFS-e.cmd").
# Instala em %LOCALAPPDATA%\ESNFSe (sem precisar de administrador), com os dados
# separados do programa: atualizacoes nunca tocam em dados\.
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'
$repo = 'ESFinancas/es-nfse-releases'

Write-Host ''
Write-Host '  ES NFS-e  -  Everton Sousa Contabilidade' -ForegroundColor Yellow
Write-Host '  Instalando o emissor de NFS-e Padrao Nacional...' -ForegroundColor Cyan
Write-Host ''

$raw = "https://raw.githubusercontent.com/$repo/main"
$r = Invoke-RestMethod -Uri "$raw/latest.json?t=$([DateTime]::UtcNow.Ticks)" -Headers @{ 'User-Agent' = 'ES-NFSe'; 'Cache-Control' = 'no-cache' }
$versao = $r.versao
$urlZip = "$raw/$($r.pacote)"
Write-Host "  Versao $versao"

$base = Join-Path $env:LOCALAPPDATA 'ESNFSe'
New-Item -ItemType Directory -Force -Path $base | Out-Null
$zip = Join-Path $env:TEMP "es-nfse-$versao.zip"
Write-Host '  Baixando o programa...'
Invoke-WebRequest -Uri $urlZip -OutFile $zip -UseBasicParsing
$app = Join-Path $base 'app'
$novo = Join-Path $base 'app-novo'
if (Test-Path $novo) { Remove-Item $novo -Recurse -Force }
Expand-Archive -Path $zip -DestinationPath $novo -Force
$pidArq = Join-Path $base 'servidor.pid'
if (Test-Path $pidArq) { Stop-Process -Id ([int](Get-Content $pidArq)) -Force -ErrorAction SilentlyContinue; Start-Sleep 1 }
if (Test-Path $app) { Remove-Item $app -Recurse -Force }
Rename-Item $novo 'app'
Remove-Item $zip -Force -ErrorAction SilentlyContinue

. (Join-Path $app 'instalador\comum.ps1')
Migrar-Dados-Antigos
if (-not (Node-Exe)) { Write-Host '  Instalando Node.js (uma unica vez)...'; Instalar-Node | Out-Null }
Criar-Atalhos
Registrar "Instalacao concluida: versao $versao"
Write-Host ''
Write-Host '  Pronto! Atalho "ES NFS-e" criado na Area de Trabalho e no Menu Iniciar.' -ForegroundColor Green
Write-Host '  Abrindo o sistema...'
Start-Process (Join-Path $env:WINDIR 'System32\wscript.exe') -ArgumentList "`"$(Join-Path $app 'instalador\iniciar-oculto.vbs')`""
Start-Sleep 3
