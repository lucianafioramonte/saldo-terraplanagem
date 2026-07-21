# ============================================================
# Sincroniza os arquivos .xlsx da pasta de origem (OneDrive)
# com o repositorio GitHub local e envia (push) automaticamente.
#
# CONFIGURACAO NECESSARIA ANTES DE USAR (leia o README.txt):
#   1) Ter o Git instalado
#   2) Ja ter clonado o repositorio uma vez manualmente
#   3) Ajustar as duas variaveis abaixo: source e repoPath
# ============================================================

# Pasta onde os arquivos semanais sao gerados (ajuste se mudar)
$source = "C:\Users\lucianaboas\OneDrive - Construtora Tripoloni\Planejamento\09 - Secao Tecnica\03 - Volumes dos trechos"

# Pasta onde o repositorio GitHub foi clonado no seu PC
$repoPath = "C:\GitHub\saldo-terraplanagem"

# Subpasta dentro do repositorio onde os arquivos ficam guardados
$destData = Join-Path $repoPath "data"

# --- Nao precisa mexer daqui pra baixo ---

if (!(Test-Path $repoPath)) {
    Write-Host "ERRO: pasta do repositorio nao encontrada em $repoPath"
    Write-Host "Clone o repositorio primeiro com o comando git clone"
    exit 1
}

if (!(Test-Path $destData)) {
    New-Item -ItemType Directory -Path $destData | Out-Null
}

# Copia apenas arquivos .xlsx da pasta de origem
Copy-Item -Path (Join-Path $source "*.xlsx") -Destination $destData -Force

Set-Location $repoPath

# Garante que a branch se chama main
git branch -M main

# Traz atualizacoes remotas, se existirem (ignora erro se repo remoto ainda vazio)
git pull origin main --quiet 2>$null

git add data

$changes = git status --porcelain
if ([string]::IsNullOrWhiteSpace($changes)) {
    Write-Host "Nenhum arquivo novo ou alterado. Nada para enviar."
    exit 0
}

$dataAtual = Get-Date -Format "yyyy-MM-dd HH:mm"
$commitMsg = "Atualizacao automatica - " + $dataAtual
git commit -m "$commitMsg"
git push -u origin main

Write-Host "Sincronizacao concluida:"
Write-Host $commitMsg
