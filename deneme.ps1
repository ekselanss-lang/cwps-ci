$ErrorActionPreference="Continue"
$T="t=cwps-yerel-9f3a7d"
$OK=0; $HATA=0
function Sonuc($ad,$beklenen,$gelen){
  $g="$gelen"
  if($g -match $beklenen){ Write-Host ("PASS  " + $ad + "  =>  " + $g.Substring(0,[Math]::Min(120,$g.Length))); $script:OK++ }
  else { Write-Host ("FAIL  " + $ad + "  =>  " + $g.Substring(0,[Math]::Min(200,$g.Length))); $script:HATA++ } }
function PortBul { foreach ($pt in 48921..48960) { try { $r=Invoke-RestMethod "http://127.0.0.1:$pt/api/durum?$T" -TimeoutSec 3; return $pt } catch {} } return 0 }
function Lisans { return (Invoke-RestMethod "http://127.0.0.1:$P1/api/lisans?$T" -TimeoutSec 20) }
function TF { return "$env:APPDATA\CyberWolfSec\kurulum.dat" }
function TFSil { Remove-Item -Force (TF) -ErrorAction SilentlyContinue }
function RegSil { Remove-Item -Path "HKCU:\Software\CyberWolfSec" -Recurse -Force -ErrorAction SilentlyContinue }
function RegYaz($v) { New-Item -Path "HKCU:\Software\CyberWolfSec" -Force | Out-Null; Set-ItemProperty -Path "HKCU:\Software\CyberWolfSec" -Name deneme_baslangic -Value "$v" }
function Simdi { return [int]([double]::Parse((Get-Date -UFormat %s))) }

# temiz baslangic
RegSil; TFSil; Remove-Item -Force "$env:APPDATA\CyberWolfSec\lisans.anahtar" -ErrorAction SilentlyContinue
$p=Start-Process .\CWPS.exe -PassThru; Start-Sleep -Seconds 15
$P1=PortBul; Write-Host ("PORT=" + $P1)
if($P1 -eq 0){ Write-Host "FAIL motor ayaga kalkmadi"; exit 1 }

Write-Host "======== 1) TEMIZ KURULUM -> 15 GUN DENEME ========"
$l=Lisans; Sonuc "1a mod DENEME" "DENEME" $l.mod
Sonuc "1b kalan 15" "15" $l.deneme_kalan
Sonuc "1c deneme_gun 0" '"deneme_gun":0' ($l | ConvertTo-Json -Compress)

Write-Host "======== 2) BOZUK DOSYA (cop deger) -> 15 GUN KALMALI ========"
Set-Content -Path (TF) -Value "bozuk-cop-veri" -NoNewline -Encoding ascii
RegSil
$l=Lisans; Sonuc "2a bozuk dosya DENEME" "DENEME" $l.mod
Sonuc "2b kalan 15" "15" $l.deneme_kalan

Write-Host "======== 3) ESKI FORMAT DEGER (15) -> 15 GUN KALMALI ========"
Set-Content -Path (TF) -Value "15" -NoNewline -Encoding ascii
RegSil
$l=Lisans; Sonuc "3a eski format DENEME" "DENEME" $l.mod
Sonuc "3b kalan 15" "15" $l.deneme_kalan

Write-Host "======== 4) GELECEK TARIH -> 15 GUN KALMALI ========"
Set-Content -Path (TF) -Value ((Simdi) + (30*86400)) -NoNewline -Encoding ascii
RegSil
$l=Lisans; Sonuc "4a gelecek tarih DENEME" "DENEME" $l.mod
Sonuc "4b kalan 15" "15" $l.deneme_kalan

Write-Host "======== 5) DOSYA 8 GUN ONCE -> 7 GUN KALMALI ========"
Set-Content -Path (TF) -Value ((Simdi) - (8*86400) - 3600) -NoNewline -Encoding ascii
RegSil
$l=Lisans; Sonuc "5a DENEME" "DENEME" $l.mod
Sonuc "5b kalan 7" "7" $l.deneme_kalan

Write-Host "======== 6) GERCEK DOLUM (16 gun once) -> DEMO ========"
Set-Content -Path (TF) -Value ((Simdi) - (16*86400)) -NoNewline -Encoding ascii
RegYaz ((Simdi) - (16*86400))
$l=Lisans; Sonuc "6a mod DEMO" "DEMO" $l.mod
Sonuc "6b kalan 0" "0" $l.deneme_kalan

Write-Host "======== 7) DOSYA SILINDI, KAYIT DEFTERI ESKI -> DEMO (kalici) ========"
TFSil
$l=Lisans; Sonuc "7a dosyasiz DEMO" "DEMO" $l.mod

Write-Host "======== 8) HER SEY SILINDI -> YENIDEN 15 GUN ========"
RegSil; TFSil
$l=Lisans; Sonuc "8a sifirdan DENEME" "DENEME" $l.mod
Sonuc "8b kalan 15" "15" $l.deneme_kalan

Write-Host "======== 9) DENEMEDE SOMURU ACIK ========"
Start-Process python -ArgumentList "vuln.py" -WindowStyle Hidden | Out-Null; Start-Sleep -Seconds 4
try { $z=Invoke-RestMethod "http://127.0.0.1:$P1/api/lfi?h=127.0.0.1&port=19090&yol=/lfi&prm=file&$T" -TimeoutSec 60
      Sonuc "9a somuru calisiyor" "root:" (($z|ConvertTo-Json -Compress -Depth 4)) } catch { Sonuc "9a somuru" "root:" $_.Exception.Message }

Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
Get-Process CWPS -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host ("====== SONUC: PASS=" + $OK + " FAIL=" + $HATA + " ======")
if($HATA -gt 0){ exit 1 }
