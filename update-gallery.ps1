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

    $startMarker = "<!-- AUTO-GENERATED:${category}:START -->"
    $endMarker = "<!-- AUTO-GENERATED:${category}:END -->"
    $pattern = [regex]::Escape($startMarker) + "(.*?)" + [regex]::Escape($endMarker)
    $regexOptions = [System.Text.RegularExpressions.RegexOptions]::Singleline
    $blockMatch = [regex]::Match($html, $pattern, $regexOptions)
    if (-not $blockMatch.Success) {
        Write-Host "警告: images/$category 用のマーカーが index.html に見つかりませんでした"
        continue
    }

    # 並び順は「今の index.html の順番」を守り、フォルダに増えた写真だけを一番下に足す
    # (写真の更新日時はカメラの撮影日のままのことがあり、日時では「追加した順」にならないため)
    $existingNames = @([regex]::Matches($blockMatch.Groups[1].Value, 'src="images/' + [regex]::Escape($category) + '/([^"]+)"') |
        ForEach-Object { $_.Groups[1].Value })

    $allFiles = @(Get-ChildItem -Path $folder -File |
        Where-Object { $extensions -contains $_.Extension.ToLower() })

    $keptFiles = foreach ($name in $existingNames) {
        $allFiles | Where-Object { $_.Name -eq $name } | Select-Object -First 1
    }
    $newFiles = $allFiles |
        Where-Object { $existingNames -notcontains $_.Name } |
        Sort-Object CreationTime, Name
    $files = @($keptFiles) + @($newFiles)

    $lines = foreach ($file in $files) {
        # ファイル名に -stamp が付いた切手風の写真には class="stamp" を付ける(白フチに影をつけるため)
        $class = if ($file.BaseName -like '*-stamp') { ' class="stamp"' } else { '' }
        '        <img src="images/{0}/{1}"{2} alt="作品写真" loading="lazy">' -f $category, $file.Name, $class
    }
    $block = $lines -join "`r`n"

    $replacement = "$startMarker`r`n$block`r`n        $endMarker"

    $html =[regex]::Replace($html, $pattern, { param($m) $replacement }, $regexOptions)
    Write-Host "$category : $($files.Count) 枚を反映しました"
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($indexPath, $html, $utf8NoBom)

Write-Host ""
Write-Host "index.html を更新しました。"
