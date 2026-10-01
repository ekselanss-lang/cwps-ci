$ErrorActionPreference="Continue"
$OK=0; $HATA=0
function Sonuc($ad,$beklenen,$gelen){
  $g="$gelen"
  if($g -match $beklenen){ Write-Host ("PASS  " + $ad + "  =>  " + $g.Substring(0,[Math]::Min(120,$g.Length))); $script:OK++ }
  else { Write-Host ("FAIL  " + $ad + "  =>  " + $g.Substring(0,[Math]::Min(200,$g.Length))); $script:HATA++ } }

Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class P {
  [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern IntPtr FindWindow(string c, string n);
  [DllImport("user32.dll")] public static extern IntPtr GetDlgItem(IntPtr h, int id);
  [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern IntPtr SendMessage(IntPtr h, uint m, IntPtr w, string l);
  [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern IntPtr SendMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  public static string Metin(IntPtr h){ StringBuilder sb=new StringBuilder(512); GetWindowText(h,sb,512); return sb.ToString(); }
}
"@

Write-Host "======== 1) DOSYA VAR MI ========"
Sonuc "1a CWPS-Keygen.exe var" "True" (Test-Path .\CWPS-Keygen.exe)
if(Test-Path .\CWPS-Keygen.exe){ Write-Host ("     boyut: " + (Get-Item .\CWPS-Keygen.exe).Length + " bayt") }

Write-Host "======== 2) KOMUT SATIRI MODU ========"
$k=(& .\CWPS-Keygen.exe FF0FAD7B-7C1436DF | Out-String).Trim()
Sonuc "2a CLI anahtar" "^MPAT9-2W2GC-M4Y4K-ZT5HB$" $k
$k2=(& .\CWPS-Keygen.exe 1234ABCD-5678EF90 | Out-String).Trim()
Sonuc "2b CLI anahtar 2" "^ZCJW9-U94QN-MGFGV-7M6D8$" $k2

Write-Host "======== 3) GORSEL ARAYUZ ACILIYOR MU ========"
$p=Start-Process .\CWPS-Keygen.exe -PassThru
Start-Sleep -Seconds 5
Sonuc "3a pencere aciliyor (process canli)" "True" (-not $p.HasExited)
$h=[P]::FindWindow("CWKeygen", $null)
if($h -eq [IntPtr]::Zero){ $h=[P]::FindWindow($null, "CYBERWOLF SECURITY - LISANS URETICI") }
if($h -eq [IntPtr]::Zero){ $mh=(Get-Process -Id $p.Id).MainWindowHandle; if($mh -ne 0){ $h=[IntPtr]$mh; Write-Host ("     MainWindowHandle ile bulundu: " + $mh) } }
Write-Host ("     pencere tutamaci: " + $h + " | MainWindowHandle: " + (Get-Process -Id $p.Id).MainWindowHandle)
Sonuc "3b pencere var" "True" ($h -ne [IntPtr]::Zero)
if($h -eq [IntPtr]::Zero){ Write-Host "FAIL gorsel arayuz penceresi olusmadi"; $HATA++; }
else {
  Sonuc "3c pencere gorunur" "True" ([P]::IsWindowVisible($h))
  $giris=[P]::GetDlgItem($h,101); $sonuc=[P]::GetDlgItem($h,103); $durum=[P]::GetDlgItem($h,106)
  Write-Host ("     giris kutusu: " + $giris + " | sonuc kutusu: " + $sonuc + " | durum: " + $durum)
  Sonuc "3d makine kodu kutusu var" "True" ($giris -ne [IntPtr]::Zero)
  Sonuc "3e sonuc kutusu var" "True" ($sonuc -ne [IntPtr]::Zero)

  Write-Host "======== 4) KUTUYA YAZ + BUTONA BAS ========"
  Remove-Item -Force "$env:TEMP\cwps_lisans_son.txt" -ErrorAction SilentlyContinue
  [void][P]::SendMessage($giris, 0x000C, [IntPtr]::Zero, "FF0FAD7B-7C1436DF")   # WM_SETTEXT
  Start-Sleep -Milliseconds 300
  [void][P]::SendMessage($h, 0x0111, [IntPtr]102, [IntPtr]::Zero)               # WM_COMMAND ID_URET
  Start-Sleep -Milliseconds 900
  $dosya="$env:TEMP\cwps_lisans_son.txt"
  $ic = if(Test-Path $dosya){ (Get-Content $dosya -Raw).Trim() } else { "DOSYA YOK" }
  Write-Host ("     keygen dosyasi: " + $ic)
  Sonuc "4b GUI ANAHTAR URETTI (dosyaya yazdi)" "^FF0FAD7B-7C1436DF:MPAT9-2W2GC-M4Y4K-ZT5HB$" $ic
  Write-Host ("     durum satiri: " + [P]::Metin($durum))

  Write-Host "======== 5) BOS KOD UYARISI ========"
  [void][P]::SendMessage($giris, 0x000C, [IntPtr]::Zero, "")
  [void][P]::SendMessage($h, 0x0111, [IntPtr]102, [IntPtr]::Zero)
  Start-Sleep -Milliseconds 500
  Sonuc "5a bos kod uyarisi" "Once musteri makine kodunu girin" ([P]::Metin($durum))

  Write-Host "======== 6) BOZUK KOD UYARISI ========"
  Remove-Item -Force "$env:TEMP\cwps_lisans_son.txt" -ErrorAction SilentlyContinue
  [void][P]::SendMessage($giris, 0x000C, [IntPtr]::Zero, "ABC")
  [void][P]::SendMessage($h, 0x0111, [IntPtr]102, [IntPtr]::Zero)
  Start-Sleep -Milliseconds 600
  Sonuc "6a bozuk kod UYARI veriyor" "bicimi hatali" ([P]::Metin($durum))
  Sonuc "6b bozuk koddan anahtar URETILMEDI" "False" (Test-Path "$env:TEMP\cwps_lisans_son.txt")
  Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
}

Write-Host "======== 7) SATICI KURULUMUNDA KEYGEN VAR MI ========"
if(Test-Path ".\CWPS-Setup-9.9-SATICI.exe"){
  Start-Process ".\CWPS-Setup-9.9-SATICI.exe" -ArgumentList "/VERYSILENT","/SUPPRESSMSGBOXES","/NORESTART","/DIR=C:\KW-TEST" -Wait
  Start-Sleep -Seconds 3
  Sonuc "7a satici kurulumunda CWPS-Keygen.exe" "True" (Test-Path "C:\KW-TEST\CWPS-Keygen.exe")
  Sonuc "7b satici kurulumunda CWPS.exe" "True" (Test-Path "C:\KW-TEST\CWPS.exe")
  if(Test-Path "C:\KW-TEST\unins000.exe"){ Start-Process "C:\KW-TEST\unins000.exe" -ArgumentList "/VERYSILENT","/SUPPRESSMSGBOXES" -Wait }
} else { Write-Host "ATLANDI - SATICI kurulum paketi bu is akisinda yok (kurulum is akisinda test ediliyor)" }

Write-Host ("====== SONUC: PASS=" + $OK + " FAIL=" + $HATA + " ======")
if($HATA -gt 0){ exit 1 }
