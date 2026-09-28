$ErrorActionPreference="Continue"
$T="t=cwps-yerel-9f3a7d"
function PortBul {
  foreach ($pt in 48921..48960) {
    try { $r = Invoke-RestMethod "http://127.0.0.1:$pt/api/durum?$T" -TimeoutSec 3; return $pt } catch {}
  }
  return 0
}
$p = Start-Process .\CWPS.exe -PassThru; Start-Sleep -Seconds 14
$P1 = PortBul; Write-Host ("PORT1=" + $P1)
$l = Invoke-RestMethod "http://127.0.0.1:$P1/api/lisans?$T" -TimeoutSec 30
Write-Host ("LISANS1 surum=" + $l.surum + " makine=" + $l.makine)
$mk = $l.makine
$k = (& .\CWPS-Keygen.exe $mk | Select-String "URETILEN ANAHTAR") -replace ".*: ",""
$k = $k.Trim()
Write-Host ("URETILEN=" + $k)
Set-Content -Path "lisans.anahtar" -Value ($mk + ":" + $k) -NoNewline -Encoding ascii
Stop-Process -Id $p.Id -Force; Start-Sleep -Seconds 5
$p2 = Start-Process .\CWPS.exe -PassThru; Start-Sleep -Seconds 14
$P2 = PortBul; Write-Host ("PORT2=" + $P2)
$proc = Get-Process CWPS -ErrorAction SilentlyContinue
Write-Host ("PROC2 sayisi=" + ($proc | Measure-Object).Count)
Write-Host "--- BASLA LOG ---"
$lg = Join-Path $env:TEMP "cwps_basla.log"
if (Test-Path $lg) { Get-Content $lg | Select-Object -Last 12 | ForEach-Object { Write-Host ("LOG: " + $_) } } else { Write-Host "LOG YOK" }
if ($P2 -gt 0) {
  $l2 = Invoke-RestMethod "http://127.0.0.1:$P2/api/lisans?$T" -TimeoutSec 30
  Write-Host ("LISANS2 surum=" + $l2.surum + " lisans=" + $l2.lisans)
  try { $z = Invoke-RestMethod "http://127.0.0.1:$P2/api/lfi?h=127.0.0.1&port=19090&yol=/lfi&prm=file&$T" -TimeoutSec 60
        Write-Host ("LFI-FULL => " + (($z | ConvertTo-Json -Compress -Depth 4) -replace "\s+"," ").Substring(0,[Math]::Min(200,(($z | ConvertTo-Json -Compress -Depth 4)).Length))) } catch { Write-Host ("LFI HATA: " + $_.Exception.Message) }
  Stop-Process -Id $p2.Id -Force -ErrorAction SilentlyContinue
}
