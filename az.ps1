$ErrorActionPreference = "Continue"
Start-Process python -ArgumentList "vuln.py" -WindowStyle Hidden
Start-Sleep -Seconds 5
$p = Start-Process .\CWPS.exe -PassThru
Start-Sleep -Seconds 14
# ---- LISANS OLUSTUR (FULL mod testi) ✓ ----
function PortBul { foreach ($pt in 48921..48960) { try { Invoke-RestMethod "http://127.0.0.1:$pt/api/durum?t=cwps-yerel-9f3a7d" -TimeoutSec 3 | Out-Null; return $pt } catch {} } return 0 }
$PF = PortBul
$li = Invoke-RestMethod "http://127.0.0.1:$PF/api/lisans?t=cwps-yerel-9f3a7d" -TimeoutSec 20
$kk = (& .\CWPS-Keygen.exe $li.makine | Select-String "URETILEN ANAHTAR") -replace ".*: ",""
Set-Content -Path "lisans.anahtar" -Value ($li.makine + ":" + $kk.Trim()) -NoNewline -Encoding ascii
Stop-Process -Id $p.Id -Force; Start-Sleep -Seconds 5
$p = Start-Process .\CWPS.exe -PassThru
Start-Sleep -Seconds 14
$L2 = Invoke-RestMethod "http://127.0.0.1:(PortBul)/api/lisans?t=cwps-yerel-9f3a7d" -TimeoutSec 20
Write-Host ("MOD=" + $L2.surum)
$T = "t=cwps-yerel-9f3a7d"
$liste = @(
 @{u="durum";p=""}, @{u="tani";p=""}, @{u="tara";p="?h=127.0.0.1&p1=1&p2=200&th=64"}, @{u="cve";p="?urun=apache"},
 @{u="dizin";p="?h=127.0.0.1&port=19090&limit=40"}, @{u="altalan";p="?h=cyberwolfsec.com&limit=40"},
 @{u="webguv";p="?h=127.0.0.1&port=19090"}, @{u="kimlik";p="?h=127.0.0.1&port=19090&yol=/login"},
 @{u="kimliksiz";p="?h=127.0.0.1"}, @{u="ssl";p="?h=cyberwolfsec.com"}, @{u="tersdns";p="?ip=8.8.8.8"},
 @{u="whois";p="?h=cyberwolfsec.com"}, @{u="stres";p="?h=127.0.0.1&adet=20&isci=4"}, @{u="smb";p="?h=127.0.0.1"},
 @{u="snmp";p="?h=127.0.0.1"}, @{u="altag";p="?h=127.0.0.1"}, @{u="metod";p="?h=127.0.0.1&port=19090"},
 @{u="sayfa";p="?h=127.0.0.1&port=19090&yol=/"}, @{u="rapor";p="?h=127.0.0.1"}, @{u="zafiyet";p="?h=127.0.0.1&port=19090&yol=/sqli&prm=id"},
 @{u="crawler";p="?h=127.0.0.1&port=19090&limit=20"}, @{u="yonlendirme";p="?h=127.0.0.1&port=19090&yol=/"},
 @{u="csrf";p="?h=127.0.0.1&port=19090"}, @{u="api";p="?h=127.0.0.1&port=19090"}, @{u="bulut";p="?h=cyberwolfsec.com"},
 @{u="cms";p="?h=127.0.0.1&port=19090"}, @{u="intruder";p="?h=127.0.0.1&port=19090&yol=/login&prm=user"},
 @{u="sql";p="?h=127.0.0.1&port=19090&yol=/sqli&prm=id"}, @{u="modul";p=""},
 @{u="modulcalistir";p="?modul=cms_tara&h=127.0.0.1&port=19090"}, @{u="yuk";p="?tur=ps1&lhost=127.0.0.1&lport=4444"},
 @{u="raporpdf";p="?h=127.0.0.1"}, @{u="lfi";p="?h=127.0.0.1&port=19090&yol=/lfi&prm=file"},
 @{u="cmdenj";p="?h=127.0.0.1&port=19090&yol=/cmd&prm=cmd"}, @{u="sqli";p="?h=127.0.0.1&port=19090&yol=/sqli&prm=id"},
 @{u="varsayilan";p="?h=127.0.0.1&port=19090&yol=/login"}, @{u="esveri";p="?h=127.0.0.1&port=9200"},
 @{u="redisveri";p="?h=127.0.0.1"}, @{u="ftpveri";p="?h=127.0.0.1"}, @{u="ham";p="?h=127.0.0.1&port=19090&yol=/"},
 @{u="zincir";p="?h=127.0.0.1&port=19090"}, @{u="kanit";p="?h=127.0.0.1"}, @{u="harici";p="?arac=nmap&h=127.0.0.1"},
 @{u="dinleyici";p="?durum=basla&lport=4545"}, @{u="exploit";p="?h=127.0.0.1&urun=apache"}, @{u="gonder";p="?h=127.0.0.1&port=19090&yol=/lfi&prm=file"},
 @{u="proxy";p="?h=127.0.0.1&port=19090&yol=/"}
)
$ok=0; $bos=0; $hata=0
foreach ($x in $liste) {
  $ayrac = "?"
  if ($x.p -like "*?*") { $ayrac = "&" }
  $u = "http://127.0.0.1:48921/api/" + $x.u + $x.p + $ayrac + $T
  try {
    $r = Invoke-WebRequest $u -TimeoutSec 100 -UseBasicParsing
    if ($r.Content.Length -lt 12) { Write-Host ("BOS  " + $x.u + " -> " + $r.Content); $bos++ }
    else { Write-Host ("TAMAM " + $x.u + " (" + $r.Content.Length + "b)"); $ok++ }
  } catch { Write-Host ("HATA " + $x.u + " -> " + $_.Exception.Message); $hata++ }
}
Write-Host ("OZET: TAMAM=$ok BOS=$bos HATA=$hata")
Write-Host "--- KUCUK CEVAPLARIN ICERIGI ---"
$sup = @("modulcalistir|?modul=cms_tara&h=127.0.0.1&port=19090","cms|?h=127.0.0.1&port=19090","api|?h=127.0.0.1&port=19090","kimliksiz|?h=127.0.0.1","ftpveri|?h=127.0.0.1","dizin|?h=127.0.0.1&port=19090&limit=40","yonlendirme|?h=127.0.0.1&port=19090&yol=/")
foreach ($s in $sup) {
  $pr = $s.Split("|"); $u = "http://127.0.0.1:48921/api/" + $pr[0] + $pr[1] + "&" + $T
  try { $r = Invoke-WebRequest $u -TimeoutSec 90 -UseBasicParsing; Write-Host ("ICERIK " + $pr[0] + " => " + $r.Content.Substring(0,[Math]::Min(260,$r.Content.Length))) } catch {}
}
Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
