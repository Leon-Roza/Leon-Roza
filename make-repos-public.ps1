# Script PowerShell para tornar todos os repositórios públicos
# Requer: GitHub CLI (gh) instalado e autenticado

# Cores para output
$successColor = "Green"
$errorColor = "Red"
$infoColor = "Cyan"

Write-Host "================================" -ForegroundColor $infoColor
Write-Host "GitHub Repos - Make All Public" -ForegroundColor $infoColor
Write-Host "================================" -ForegroundColor $infoColor
Write-Host ""

# Verificar se GitHub CLI está instalado
try {
    $ghVersion = gh --version
    Write-Host "✓ GitHub CLI detectado: $ghVersion" -ForegroundColor $successColor
}
catch {
    Write-Host "✗ GitHub CLI não está instalado!" -ForegroundColor $errorColor
    Write-Host "Instale em: https://cli.github.com" -ForegroundColor $infoColor
    exit 1
}

Write-Host ""
Write-Host "Buscando repositórios..." -ForegroundColor $infoColor

# Obter lista de todos os repositórios do usuário
try {
    $repos = gh repo list --limit 1000 --json name,isPrivate --jq '.[] | select(.isPrivate == true) | .name'
    $repoArray = @($repos | Where-Object { $_ -ne "" })
    
    if ($repoArray.Count -eq 0) {
        Write-Host "✓ Nenhum repositório privado encontrado!" -ForegroundColor $successColor
        Write-Host "Todos os seus repositórios já estão públicos." -ForegroundColor $successColor
        exit 0
    }
    
    Write-Host "✓ Encontrados $($repoArray.Count) repositório(s) privado(s)" -ForegroundColor $successColor
    Write-Host ""
    Write-Host "Repositórios privados:" -ForegroundColor $infoColor
    $repoArray | ForEach-Object { Write-Host "  • $_" }
    Write-Host ""
}
catch {
    Write-Host "✗ Erro ao buscar repositórios: $_" -ForegroundColor $errorColor
    exit 1
}

# Confirmar antes de prosseguir
Write-Host "Deseja tornar estes repositórios PÚBLICOS? (S/N)" -ForegroundColor $infoColor
$confirm = Read-Host

if ($confirm -ne "S" -and $confirm -ne "s") {
    Write-Host "Operação cancelada." -ForegroundColor $infoColor
    exit 0
}

Write-Host ""
Write-Host "Processando..." -ForegroundColor $infoColor
Write-Host ""

$successCount = 0
$errorCount = 0

# Fazer cada repositório público
foreach ($repo in $repoArray) {
    try {
        Write-Host "Alterando: $repo" -ForegroundColor $infoColor -NoNewline
        
        # Usar GitHub CLI para mudar visibilidade
        gh repo edit $repo --visibility public
        
        Write-Host " ✓" -ForegroundColor $successColor
        $successCount++
    }
    catch {
        Write-Host " ✗ Erro: $_" -ForegroundColor $errorColor
        $errorCount++
    }
}

Write-Host ""
Write-Host "================================" -ForegroundColor $infoColor
Write-Host "Resumo:" -ForegroundColor $infoColor
Write-Host "  Sucesso: $successCount" -ForegroundColor $successColor
Write-Host "  Erros: $errorCount" -ForegroundColor $errorColor
Write-Host "================================" -ForegroundColor $infoColor
