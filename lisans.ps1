$ErrorActionPreference="Continue"
$T="t=cwps-yerel-9f3a7d"
$p = Start-Process .\CWPS.exe -PassThru; Start-Sleep -Seconds 14
$l = Invoke-RestMethod "http://127.0.0.1:48921/api/lisans?$T" -TimeoutSec 30
Write-Host ("LISANS1 surum=" + $l.surum + " makine=" + $l.makine)
$mk = $l.makine
$k = & .\CWPS-Keygen.exe $mk | Select-String "URETILEN ANAHTAR" | ForEach-Object { ($_ -split ":")[1].Trim() }
Write-Host ("URETILEN=" + $k)
Set-Content -Path "lisans.anahtar" -Value ($mk + ":" + $k) -NoNewline -Encoding ascii
Stop-Process -Id $p.Id -Force; Start-Sleep -Seconds 3
$p2 = Start-Process .\CWPS.exe -PassThru; Start-Sleep -Seconds 14
$l2 = Invoke-RestMethod "http://127.0.0.1:48921/api/lisans?$T" -TimeoutSec 30
Write-Host ("LISANS2 surum=" + $l2.surum + " lisans=" + $l2.lisans)
$z = Invoke-RestMethod "http://127.0.0.1:48921/api/lfi?h=127.0.0.1&port=19090&yol=/lfi&prm=file&$T" -TimeoutSec 60
Write-Host ("LFI FULL TEST => " + ($z | ConvertTo-Json -Compress -Depth 3).Substring(0,[Math]::Min(180,($z | ConvertTo-Json -Compress -Depth 3).Length)))
Stop-Process -Id $p2.Id -Force -ErrorAction SilentlyContinue
