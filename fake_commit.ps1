# Fake Git Commit Progress Bar Script
$commitMessage = "Goodbye 2025, thanks for the lessons."

# Commit komutunu ekrana yaz
Write-Host "git commit -m `"$commitMessage`"" -ForegroundColor Cyan

Write-Host ""

# Progress bar animasyonu
$maxSteps = 20
$filled = "="
$empty = "-"

for ($i = 1; $i -le $maxSteps; $i++) {
    $percent = [math]::Floor(($i / $maxSteps) * 100)
    $barLength = $i
    $bar = $filled * $barLength + $empty * ($maxSteps - $barLength)
    Write-Host -NoNewline "`r[$bar] $percent%"
    Start-Sleep -Milliseconds 75
}

Write-Host ""
Write-Host ""

# Commit tamamlandı mesajları
Write-Host "[main 1a2b3c4d] $commitMessage" -ForegroundColor Green
Write-Host " 1 file changed, 1 insertion(+)" -ForegroundColor Yellow
