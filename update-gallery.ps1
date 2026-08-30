# images/landscape, images/nature, images/food の中身を読み取り、
# index.html のギャラリー部分(<!-- AUTO-GENERATED:xxx:START -->〜END の間)を自動で書き直す

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$indexPath = Join-Path $root "index.html"
$categories = @("landscape", "nature", "food")
$extensions = @(".jpg", ".jpeg", ".png", ".webp", ".gif")

$html = Get-Content -Path $indexPath -Raw -Encoding UTF8

foreach ($category in $categories) {
    $folder = Join-Path $root "images\$category"
    if (-not (Test-Path $folder)) {
        Write-Host "スキップ: images/$category フォルダが見つかりません"
        continue
    }

    $files = Get-ChildItem -Path $folder -File |
        Where-Object { $extensions -contains $_.Extension.ToLower() } |
        Sort-Object LastWriteTime

    $lines = foreach ($file in $files) {
        '        <img src="images/{0}/{1}" alt="作品写真" loading="lazy">' -f $category, $file.Name
    }
    $block = $lines -join "`r`n"

    $startMarker = "<!-- AUTO-GENERATED:${category}:START -->"
    $endMarker = "<!-- AUTO-GENERATED:${category}:END -->"
    $pattern = [regex]::Escape($startMarker) + "(.*?)" + [regex]::Escape($endMarker)
    $replacement = "$startMarker`r`n$block`r`n        $endMarker"

    $regexOptions = [System.Text.RegularExpressions.RegexOptions]::Singleline
    if (-not [regex]::IsMatch($html, $pattern, $regexOptions)) {
        Write-Host "警告: images/$category 用のマーカーが index.html に見つかりませんでした"
        continue
    }

    $html = [regex]::Replace($html, $pattern, { param($m) $replacement }, $regexOptions)
    Write-Host "$category : $($files.Count) 枚を反映しました"
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($indexPath, $html, $utf8NoBom)

Write-Host ""
Write-Host "index.html を更新しました。"
