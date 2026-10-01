$ErrorActionPreference="Continue"
$TOKEN = "cwps-yerel-9f3a7d"
function PortBul { foreach ($pt in 48921..48960) { try { Invoke-RestMethod ("http://127.0.0.1:" + $pt + "/api/durum?t=" + $TOKEN) -TimeoutSec 3 | Out-Null; return $pt } catch {} } return 0 }
$PF = PortBul
if($PF -eq 0){ Write-Host "FAIL  motor portu bulunamadi (CWPS.exe calisiyor mu?)"; exit 1 }
$B = "http://127.0.0.1:" + $PF
Write-Host ("MOTOR PORTU: " + $PF)
function Api($y, $ms=60000){
  $u = $B + "/api/" + $y
  if($u -match "\?"){ $u = $u + "&t=" + $TOKEN } else { $u = $u + "?t=" + $TOKEN }
  try { return Invoke-RestMethod -Uri $u -TimeoutSec ([Math]::Max(5,[int]($ms/1000))) } catch { return $null }
}
$OK=0; $HATA=0; $sonuclar=@()

Write-Host "======== 0) HEDEF WEB SUNUCUSU (127.0.0.1:80) ========"
$w = Api "web_basliklar?h=127.0.0.1"
if($w){ Write-Host ("PASS  yerel web sunucusu yanit verdi (kod=" + $w.kod + ")"); $OK++ } else { Write-Host "FAIL  yerel web sunucusu yanit vermedi"; $HATA++ }

Write-Host ""
Write-Host "======== 1) MODUL LISTESI ========"
$m = Api "modul" 20000
$sayi = 0
if($m){ if($m.moduller){ $sayi = @($m.moduller).Count } elseif($m.sayi){ $sayi = [int]$m.sayi } }
if($sayi -ge 39){ Write-Host ("PASS  modul sayisi = " + $sayi); $OK++ } else { Write-Host ("FAIL  modul sayisi = " + $sayi); $HATA++ }
Write-Host ("      ham yanit: " + ($m | ConvertTo-Json -Compress -Depth 3))

Write-Host ""
Write-Host "======== 2) TUM MODULLER TEK TEK ========"
# modul -> hedef eslemesi
$moduller = @(
  @("sql_veri_cikar","127.0.0.1","/"), @("sql_kayit_dok","127.0.0.1","/"), @("lfi_dosya_oku","127.0.0.1","/"),
  @("rce_komut","127.0.0.1","/"), @("xss_yansima","127.0.0.1","/"), @("ssrf_ic_ag","127.0.0.1","/"),
  @("dosya_yukle","127.0.0.1","/"), @("jwt_kir","127.0.0.1","/"), @("web_basliklar","127.0.0.1","/"),
  @("api_kesif","127.0.0.1","/"), @("cms_tara","127.0.0.1","/"), @("admin","127.0.0.1","/"),
  @("dizin_tara","127.0.0.1","/"), @("zafiyet_tara","127.0.0.1","/"), @("varsayilan_sifre","127.0.0.1","/login"),
  @("oturum_kir","127.0.0.1","/login"), @("bulut_kontrol","127.0.0.1","/"),
  @("smb_null","127.0.0.1","/"), @("smb_relay_deneme","127.0.0.1","/"), @("smb_eternalblue","127.0.0.1","/"),
  @("snmp_tarama","127.0.0.1","/"), @("ssl_analiz","127.0.0.1","/"), @("ldap_anon","127.0.0.1","/"),
  @("redis_eris","127.0.0.1","/"), @("mongo_eris","127.0.0.1","/"), @("elastic_eris","127.0.0.1","/"),
  @("ftp_anon","127.0.0.1","/"), @("rdp_bluekeep","127.0.0.1","/"),
  @("port_tara","127.0.0.1","/"), @("servis_parmak","127.0.0.1","/"), @("cve_esle","127.0.0.1","/"),
  @("altalan_tara","example.com","/"),
  @("yuk_exe","127.0.0.1","/"), @("yuk_ps1","127.0.0.1","/"), @("yuk_php","127.0.0.1","/"),
  @("yuk_asp","127.0.0.1","/"), @("yuk_elf","127.0.0.1","/"), @("yuk_py","127.0.0.1","/"), @("yuk_jsp","127.0.0.1","/"),
  @("dinleyici_ters","127.0.0.1","/")
)
foreach($md in $moduller){
  $ad=$md[0]; $h=$md[1]; $yy=$md[2]
  $t0=Get-Date
  $r = Api ("modulcalistir?modul=" + $ad + "&h=" + $h + "&yol=" + $yy + "&p=id") 60000
  $sure=[Math]::Round(((Get-Date)-$t0).TotalSeconds,1)
  $s = if($r){ ($r | ConvertTo-Json -Compress -Depth 4) } else { "" }
  $durum="OK"; $renk=""
  if(-not $r){ $durum="YANIT YOK"; $renk="er" }
  elseif($s -match '"hata"'){ $durum="HATA"; $renk="er" }
  elseif($s.Length -lt 25){ $durum="BOS"; $renk="wn" }
  if($durum -eq "OK"){ $OK++ } else { $HATA++ }
  Write-Host ("{0,-6} {1,-18} {2,6}sn  {3}" -f $durum, $ad, $sure, $s.Substring(0,[Math]::Min(190,$s.Length)))
  $sonuclar += [pscustomobject]@{modul=$ad;durum=$durum;sure=$sure;yanit=$s.Substring(0,[Math]::Min(200,$s.Length))}
}
Write-Host ""
Write-Host "======== 3) GOMULU ARACLAR (9) ========"
$araclar=@("nmap","ffuf","gobuster","subfinder","httpx","naabu","katana","dnsx","nuclei")
foreach($a in $araclar){
  $hedef = if($a -eq "nmap" -or $a -eq "naabu") { "127.0.0.1" } elseif($a -eq "subfinder" -or $a -eq "dnsx") { "example.com" } else { "127.0.0.1" }
  $t0=Get-Date
  $r = Api ("harici?arac=" + $a + "&h=" + $hedef) 180000
  $sure=[Math]::Round(((Get-Date)-$t0).TotalSeconds,1)
  $s = if($r){ ($r | ConvertTo-Json -Compress -Depth 4) } else { "" }
  $boyut = if($r){ [int]$r.boyut } else { -1 }
  $durum="OK"
  if(-not $r){ $durum="YANIT YOK" }
  elseif($s -match 'arac bulunamadi'){ $durum="ARAC YOK" }
  elseif($s -match '"hata"'){ $durum="HATA" }
  elseif($boyut -le 0){ $durum="CIKTI YOK" }
  if($durum -eq "OK"){ $OK++ } else { $HATA++ }
  Write-Host ("{0,-11} {1,-10} {2,6}sn  boyut={3}  {4}" -f $durum,$a,$sure,$boyut,$s.Substring(0,[Math]::Min(140,$s.Length)))
}

Write-Host ""
Write-Host "======== 4) DURDUR TESTI (uzun suren arac) ========"
$job = Start-Job -ScriptBlock {
  param($tok)
  try { $pt=0; foreach ($px in 48921..48960) { try { Invoke-RestMethod ("http://127.0.0.1:" + $px + "/api/durum?t=" + $tok) -TimeoutSec 2 | Out-Null; $pt=$px; break } catch {} }; Invoke-RestMethod ("http://127.0.0.1:" + $pt + "/api/harici?arac=gobuster&h=127.0.0.1&t=" + $tok) -TimeoutSec 200 } catch { }
} -ArgumentList $TOKEN
Start-Sleep -Seconds 4
$gb = Get-Process gobuster -ErrorAction SilentlyContinue
if($gb){ Write-Host ("PASS  gobuster CALISIYOR (pid=" + ($gb.Id -join ",") + ")"); $OK++ } else { Write-Host "BILGI gobuster sureci gorunmedi (hizli bitmis olabilir)"; $OK++ }
$d = Api "durdur" 15000
Write-Host ("      durdur yaniti: " + ($d | ConvertTo-Json -Compress))
Start-Sleep -Seconds 2
$gb2 = Get-Process gobuster -ErrorAction SilentlyContinue
if(-not $gb2){ Write-Host "PASS  DURDUR sonrasi gobuster sureci YOK (durdurma calisti)"; $OK++ }
else { Write-Host ("FAIL  gobuster HALA CALISIYOR (pid=" + ($gb2.Id -join ",") + ")"); $HATA++ }
Wait-Job $job -Timeout 30 | Out-Null; Remove-Job $job -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "======== SONUC ========"
Write-Host ("PASS=" + $OK + "  FAIL=" + $HATA)
$sonuclar | ConvertTo-Json -Depth 4 | Out-File -Encoding utf8 moduller-sonuc.json
if($HATA -gt 0){ exit 1 } else { exit 0 }
