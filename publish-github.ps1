# 変更をGitHubへpushして、GitHub Pagesに反映する

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

git add -A

$staged = git diff --cached --name-only
if (-not $staged) {
    Write-Host "変更はありません。公開はスキップします。"
    exit 0
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
git commit -m "写真を更新 ($timestamp)"
git push

Write-Host ""
Write-Host "公開処理を実行しました。数分後に https://mee1215r.github.io/portfolio-site/ に反映されます。"
