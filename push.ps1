$ErrorActionPreference = "Stop"
$repo = "C:\dev\bmd-sync-k7x3"
$tc   = "C:\Bookmap\Python\trade_copilot"
$desk = [Environment]::GetFolderPath("Desktop")

# 1. Ruleaza pack-ul
python "$tc\copilot_pack.py" hot

# 2. Gaseste cel mai proaspat copilot_pack.json (trade_copilot sau Desktop)
$pack = Get-ChildItem "$tc\copilot_pack.json", "$desk\copilot_pack.json" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $pack) { throw "copilot_pack.json negasit nici in $tc nici pe Desktop" }
Copy-Item $pack.FullName "$repo\copilot_pack.json" -Force
Write-Host "pack: $($pack.FullName) ($($pack.LastWriteTime.ToString('HH:mm:ss')))"

# 3. Lupele de pe Desktop (daca exista)
foreach ($f in "lupa_zi_tape.jsonl","lupa_zi_mbo.jsonl","lupa_zi_pivots.json") {
    if (Test-Path "$desk\$f") { Copy-Item "$desk\$f" "$repo\$f" -Force; Write-Host "lupa: $f" }
}

# 4. Push
Set-Location $repo
git add -A
git commit -m "pack $(Get-Date -Format 'dd.MM HH:mm:ss')" 2>$null
git push
Write-Host "PUSH OK $(Get-Date -Format 'HH:mm:ss')"