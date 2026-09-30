$ErrorActionPreference="Continue"
$T="t=cwps-yerel-9f3a7d"
$OK=0; $HATA=0
function Sonuc($ad,$beklenen,$gelen){
  $g="$gelen"
  if($g -match $beklenen){ Write-Host ("PASS  " + $ad + "  =>  " + $g.Substring(0,[Math]::Min(180,$g.Length))); $script:OK++ }
  else { Write-Host ("FAIL  " + $ad + "  =>  " + $g.Substring(0,[Math]::Min(220,$g.Length))); $script:HATA++ } }
function PortBul { foreach ($pt in 48921..48960) { try { $r=Invoke-RestMethod "http://127.0.0.1:$pt/api/durum?$T" -TimeoutSec 3; return $pt } catch {} } return 0 }

# ---- temiz kurulum (deneme sayaci sifir) ----
Remove-Item -Recurse -Force "$env:APPDATA\CyberWolfSec" -ErrorAction SilentlyContinue
Remove-Item -Force .\lisans.anahtar -ErrorAction SilentlyContinue
Start-Process python -ArgumentList "vuln.py" -WindowStyle Hidden
Start-Sleep -Seconds 5

$p=Start-Process .\CWPS.exe -PassThru
Start-Sleep -Seconds 15
$P1=PortBul
Write-Host ("PORT=" + $P1)
if($P1 -eq 0){ Write-Host "FAIL  motor ayaga kalkmadi"; exit 1 }

Write-Host "======== 1) ILK 15 GUN = FULL DENEME ========"
$l=Invoke-RestMethod "http://127.0.0.1:$P1/api/lisans?$T" -TimeoutSec 30
Write-Host ("1 | surum=" + $l.surum + " mod=" + $l.mod + " kalan=" + $l.deneme_kalan + " makine=" + $l.makine)
Sonuc "1a deneme modu FULL"  "FULL"  $l.surum
Sonuc "1b mod DENEME"        "DENEME" $l.mod
try { $z=Invoke-RestMethod "http://127.0.0.1:$P1/api/lfi?h=127.0.0.1&port=19090&yol=/lfi&prm=file&$T" -TimeoutSec 60
      $s=($z|ConvertTo-Json -Compress -Depth 4); Sonuc "1c somuru DENEMEDE ACIK" "root:" $s } catch { Sonuc "1c somuru" "root:" $_.Exception.Message }

Write-Host "======== 2) 15 GUN DOLDU -> OTOMATIK DEMO ========"
$eski=[int]([double]::Parse((Get-Date -UFormat %s))) - (16*86400)
Set-Content -Path "$env:APPDATA\CyberWolfSec\kurulum.dat" -Value $eski -NoNewline -Encoding ascii
$l2=Invoke-RestMethod "http://127.0.0.1:$P1/api/lisans?$T" -TimeoutSec 30
Write-Host ("2 | surum=" + $l2.surum + " mod=" + $l2.mod + " kalan=" + $l2.deneme_kalan + " bitti=" + $l2.deneme_bitti)
Sonuc "2a mod DEMO"          "DEMO"  $l2.mod
Sonuc "2b surum DEMO"        "DEMO"  $l2.surum
Sonuc "2c deneme bitti"      "true"  $l2.deneme_bitti
try { $z=Invoke-RestMethod "http://127.0.0.1:$P1/api/lfi?h=127.0.0.1&port=19090&yol=/lfi&prm=file&$T" -TimeoutSec 60
      $s=($z|ConvertTo-Json -Compress -Depth 4); Sonuc "2d somuru KILITLI" "LISANS GEREKLI" $s } catch { Sonuc "2d somuru" "LISANS GEREKLI" $_.Exception.Message }
try { $z=Invoke-RestMethod "http://127.0.0.1:$P1/api/raporpdf?$T" -TimeoutSec 60
      $s=($z|ConvertTo-Json -Compress -Depth 4); Sonuc "2e PDF KILITLI" "FULL-SURUMDE" $s } catch { Sonuc "2e PDF" "FULL-SURUMDE" $_.Exception.Message }
try { $z=Invoke-RestMethod "http://127.0.0.1:$P1/api/modul?m=rce_komut&h=127.0.0.1&$T" -TimeoutSec 60
      $s=($z|ConvertTo-Json -Compress -Depth 4); Sonuc "2f modul KILITLI" "FULL surumde aktif" $s } catch { Sonuc "2f modul" "FULL surumde aktif" $_.Exception.Message }

Write-Host "======== 3) YANLIS ANAHTAR REDDEDILMELI ========"
try { $y=Invoke-RestMethod "http://127.0.0.1:$P1/api/lisansyukle?k=AAAAA-BBBBB-CCCCC-DDDDD&$T" -TimeoutSec 30
      $s=($y|ConvertTo-Json -Compress -Depth 4); Sonuc "3a yanlis anahtar reddedildi" '"gecerli":false' $s
      Sonuc "3b hata mesaji" "GECERSIZ ANAHTAR" $s } catch { Sonuc "3a yanlis anahtar" '"gecerli":false' $_.Exception.Message }
Sonuc "3c lisans.anahtar YAZILMADI" "False" (Test-Path .\lisans.anahtar)

Write-Host "======== 4) DOGRU ANAHTAR (keygen CLI) ========"
$mk=$l2.makine
$k=(& .\CWPS-Keygen.exe $mk | Out-String).Trim()
Write-Host ("4 | keygen CLI: " + $mk + " -> " + $k)
Sonuc "4a anahtar bicimi" "^[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}$" $k
try { $y2=Invoke-RestMethod "http://127.0.0.1:$P1/api/lisansyukle?k=$k&$T" -TimeoutSec 30
      $s=($y2|ConvertTo-Json -Compress -Depth 4); Sonuc "4b anahtar kabul edildi" '"gecerli":true' $s } catch { Sonuc "4b anahtar kabulu" '"gecerli":true' $_.Exception.Message }
$l3=Invoke-RestMethod "http://127.0.0.1:$P1/api/lisans?$T" -TimeoutSec 30
Write-Host ("4 | surum=" + $l3.surum + " mod=" + $l3.mod + " lisans=" + $l3.lisans)
Sonuc "4c FULL aktif"  "FULL" $l3.mod
Sonuc "4d lisans gecerli" "gecerli" $l3.lisans
Sonuc "4e lisans.anahtar yazildi" "True" (Test-Path .\lisans.anahtar)
try { $z=Invoke-RestMethod "http://127.0.0.1:$P1/api/lfi?h=127.0.0.1&port=19090&yol=/lfi&prm=file&$T" -TimeoutSec 60
      $s=($z|ConvertTo-Json -Compress -Depth 4); Sonuc "4f somuru FULL'de ACIK" "root:" $s } catch { Sonuc "4f somuru" "root:" $_.Exception.Message }
try { $z=Invoke-RestMethod "http://127.0.0.1:$P1/api/raporpdf?$T" -TimeoutSec 60
      $s=($z|ConvertTo-Json -Compress -Depth 4); Sonuc "4g PDF FULL'de ACIK" "rapor|pdf|ok|dosya" $s } catch { Sonuc "4g PDF" "rapor" $_.Exception.Message }

# ---- 5) yeniden baslat: lisans KALICI mi ----
Write-Host "======== 5) YENIDEN BASLATMA (lisans kalici mi) ========"
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 5
$p3=Start-Process .\CWPS.exe -PassThru; Start-Sleep -Seconds 15
$P3=PortBul; Write-Host ("PORT3=" + $P3)
$l4=Invoke-RestMethod "http://127.0.0.1:$P3/api/lisans?$T" -TimeoutSec 30
Sonuc "5 lisans yeniden acilista gecerli" "FULL" $l4.mod
Stop-Process -Id $p3.Id -Force -ErrorAction SilentlyContinue

Write-Host ("====== SONUC: PASS=" + $OK + " FAIL=" + $HATA + " ======")
if($HATA -gt 0){ exit 1 }
