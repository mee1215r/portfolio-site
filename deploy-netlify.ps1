# index.html / style.css / script.js / images フォルダをZIPにまとめて
# Netlifyへ直接アップロード(ドラッグ&ドロップと同じ結果になる)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$secretPath = Join-Path $root "netlify-secret.local.ps1"

if (-not (Test-Path $secretPath)) {
    Write-Host "エラー: netlify-secret.local.ps1 が見つかりません。Site IDとトークンを設定してください。"
    exit 1
}

. $secretPath

if (-not $env:NETLIFY_SITE_ID -or -not $env:NETLIFY_TOKEN) {
    Write-Host "エラー: Site IDまたはトークンが設定されていません。"
    exit 1
}

$zipPath = Join-Path $env:TEMP "portfolio-site-deploy.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

# Compress-ArchiveはZIP内のパス区切りに \ を使ってしまい、Netlify(Linux)側で
# フォルダとして認識されないため、System.IO.Compressionで / 区切りのエントリ名を指定して作る
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$relativePaths = @("index.html", "style.css", "script.js")
$relativePaths += Get-ChildItem -Path (Join-Path $root "images") -Recurse -File | ForEach-Object {
    $_.FullName.Substring($root.Length + 1)
}

$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($relPath in $relativePaths) {
        $fullPath = Join-Path $root $relPath
        $entryName = $relPath -replace '\\', '/'
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $fullPath, $entryName, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
} finally {
    $zip.Dispose()
}

Write-Host "Netlifyへアップロード中..."
$headers = @{ Authorization = "Bearer $($env:NETLIFY_TOKEN)" }
$response = Invoke-RestMethod -Uri "https://api.netlify.com/api/v1/sites/$($env:NETLIFY_SITE_ID)/deploys" `
    -Method Post -Headers $headers -ContentType "application/zip" -InFile $zipPath

Remove-Item $zipPath -Force

Write-Host ""
Write-Host "公開が完了しました！"
if ($response.deploy_ssl_url) {
    Write-Host "URL: $($response.deploy_ssl_url)"
}
