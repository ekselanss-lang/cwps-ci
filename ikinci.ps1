function Temizle {
  Get-Process CWPS,CWPS-eski -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
  Get-Process msedge,chrome,firefox -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
  Remove-Item -Recurse -Force "$env:TEMP\cwps_profil" -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 4
}
function Say($etiket) {
  $penc = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'cwps_ui' -and $_.Name -notmatch 'pwsh|powershell|conhost|cmd' }
  $app  = @($penc | Where-Object { $_.CommandLine -match '--app=' })
  $duz  = @($penc | Where-Object { $_.CommandLine -notmatch '--app=' })
  Write-Host "$etiket | uygulama penceresi (--app): $($app.Count)"
  Write-Host "$etiket | YEDEK YOL (app'siz)  : $($duz.Count)"
  $duz | ForEach-Object { Write-Host ("     YEDEK>> [" + $_.Name + "] " + $_.CommandLine.Substring(0,[Math]::Min(150,$_.CommandLine.Length))) }
}
foreach ($exe in @("CWPS-eski.exe","CWPS.exe")) {
  Temizle
  Write-Host "############ $exe ############"
  $a = Start-Process ".\$exe" -PassThru
  Start-Sleep -Seconds 25
  Say "1.ACILIS $exe"
  Write-Host "-- program ACIKKEN IKINCI KEZ aciliyor --"
  $b = Start-Process ".\$exe" -PassThru
  Start-Sleep -Seconds 30
  Say "2.ACILIS $exe"
  Write-Host "$exe | 1.program canli: $(-not $a.HasExited) | 2.program canli: $(-not $b.HasExited)"
  Write-Host "$exe | msedge surec: $(@(Get-Process msedge -ErrorAction SilentlyContinue).Count)"
}
Temizle
Write-Host "TEST BITTI"
