; ============================================================================
;  CYBERWOLF SECURITY 9.9  —  PROFESYONEL KURULUM (Inno Setup 6)
;  ---------------------------------------------------------------------------
;  Musteri surumu : iscc CWPS.iss
;  Satici surumu  : iscc /DSATICI CWPS.iss        (anahtar uretici DAHIL)
;  Output         : Output\CWPS-Setup-9.9.exe  /  Output\CWPS-Setup-9.9-SATICI.exe
; ============================================================================
#define SURUM     "9.9"
#define YAYINCI   "CyberWolfSec"
#define URL       "https://cyberwolfsec.com"

#ifdef SATICI
  #define SURUM_EK  "-SATICI"
  #define AD_EK     " - SATICI"
  #define APPID     "{{8F3C1B42-6A7E-4D19-9C2B-71A55E30D9C2}"
#else
  #define SURUM_EK  ""
  #define AD_EK     ""
  #define APPID     "{{8F3C1B42-6A7E-4D19-9C2B-71A55E30D9C1}"
#endif

[Setup]
AppId={#APPID}
AppName=CYBERWOLF SECURITY
AppVersion={#SURUM}
AppVerName=CYBERWOLF SECURITY {#SURUM}
AppPublisher={#YAYINCI}
AppPublisherURL={#URL}
AppSupportURL={#URL}
AppUpdatesURL={#URL}
AppCopyright=© 2026 {#YAYINCI}
DefaultDirName={autopf}\CYBERWOLF SECURITY
DefaultGroupName=CYBERWOLF SECURITY
DisableProgramGroupPage=yes
AllowNoIcons=yes
LicenseFile=LISANS.txt
InfoBeforeFile=OKU-BENI.txt
OutputDir=Output
OutputBaseFilename=CWPS-Setup-{#SURUM}{#SURUM_EK}
SetupIconFile=cw_icon.ico
UninstallDisplayIcon={app}\CWPS.exe
UninstallDisplayName=CYBERWOLF SECURITY {#SURUM}
VersionInfoVersion={#SURUM}.0.0
VersionInfoDescription=CYBERWOLF SECURITY {#SURUM} Kurulum Paketi
VersionInfoCompany={#YAYINCI}
VersionInfoProductName=CYBERWOLF SECURITY
VersionInfoProductVersion={#SURUM}
Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
WizardStyle=modern
SetupLogging=yes
CloseApplications=yes
RestartApplications=no
MinVersion=10.0
DisableDirPage=no
DisableReadyPage=no

[Languages]
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "baslatmenu"; Description: "Başlat menüsüne ekle";           GroupDescription: "Kısayollar:"; Flags: checkedonce
Name: "masaustu";   Description: "Masaüstüne ekle";                 GroupDescription: "Kısayollar:"; Flags: checkedonce
Name: "duvar";    Description: "Windows Defender'a program klasörünü istisna ekle (yanlış alarmı önler — yönetici gerekir)"; GroupDescription: "Güvenlik:"; Flags: unchecked

[Dirs]
; Program klasori KULLANICI tarafindan yazilabilir olmali:
; lisans.anahtar, rapor.pdf ve payloadlar/ bu klasore yaziliyor.
Name: "{app}";                                Permissions: users-modify
Name: "{app}\payloadlar";                     Permissions: users-modify
Name: "{app}\raporlar";                       Permissions: users-modify

[Files]
Source: "CWPS.exe";            DestDir: "{app}"; Flags: ignoreversion
Source: "LISANS.txt";          DestDir: "{app}"; Flags: ignoreversion
Source: "OKU-BENI.txt";        DestDir: "{app}"; Flags: ignoreversion
Source: "araclar\*.exe";       DestDir: "{app}\araclar"; Flags: ignoreversion
Source: "araclar\*.dll";       DestDir: "{app}\araclar"; Flags: ignoreversion skipifsourcedoesntexist
Source: "araclar\*.dat";       DestDir: "{app}\araclar"; Flags: ignoreversion skipifsourcedoesntexist
Source: "listeler\*";          DestDir: "{app}\listeler"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
#ifdef SATICI
Source: "CWPS-Keygen.exe";     DestDir: "{app}"; Flags: ignoreversion
#endif

[Icons]
Name: "{autoprograms}\CYBERWOLF SECURITY";                  Filename: "{app}\CWPS.exe"; WorkingDir: "{app}"; Tasks: baslatmenu
Name: "{autoprograms}\Kaldır (Uninstall)";                  Filename: "{uninstallexe}"
Name: "{autodesktop}\CYBERWOLF SECURITY";                   Filename: "{app}\CWPS.exe"; WorkingDir: "{app}"; Tasks: masaustu

[Registry]
; Windows'ta "CWPS.exe" yazinca calismasi icin (App Paths)
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\App Paths\CWPS.exe"; ValueType: string; ValueName: ""; ValueData: "{app}\CWPS.exe"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\App Paths\CWPS.exe"; ValueType: string; ValueName: "Path"; ValueData: "{app}"; Flags: uninsdeletekey

[Run]
Filename: "{app}\CWPS.exe"; Description: "CYBERWOLF SECURITY'i şimdi başlat"; Flags: nowait postinstall skipifsilent
Filename: "{app}\OKU-BENI.txt"; Description: "Kullanım kılavuzunu aç"; Flags: shellexec postinstall unchecked skipifsilent
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -Command ""try {{ Add-MpPreference -ExclusionPath '{app}' -ErrorAction Stop; Write-Host 'Defender istisnasi eklendi' }} catch {{ Write-Host 'Defender istisnasi eklenemedi (yonetici gerekli)' }}"""; StatusMsg: "Windows Defender istisnası ekleniyor..."; Flags: runhidden; Tasks: duvar

[UninstallRun]
; Kaldirmadan ONCE calisan program zorla kapatilir (dosya kilitli kalmasin) ✓
Filename: "{sys}\taskkill.exe"; Parameters: "/F /IM CWPS.exe /T";        Flags: runhidden; RunOnceId: "cwpsKapat"
Filename: "{sys}\taskkill.exe"; Parameters: "/F /IM CWPS-Keygen.exe /T"; Flags: runhidden; RunOnceId: "keygenKapat"

[UninstallDelete]
; Programin CALISIRKEN urettigi dosyalar (kurulumda yoktu) — kaldirmada temizlensin
Type: filesandordirs; Name: "{app}\payloadlar"
Type: files;          Name: "{app}\rapor.pdf"
Type: filesandordirs; Name: "{app}\raporlar"
Type: filesandordirs; Name: "{tmp}\cwps_profil"
Type: files;          Name: "{tmp}\cwps_ui.html"
Type: files;          Name: "{tmp}\cwps_basla.log"
Type: files;          Name: "{app}\cwps_basla.log"
Type: filesandordirs; Name: "{app}\listeler"
Type: files;          Name: "{app}\cwps-test*.txt"
Type: files;          Name: "{app}\rapor.pdf"
Type: filesandordirs; Name: "{app}\locale"
Type: filesandordirs; Name: "{app}\locales"
Type: filesandordirs; Name: "{app}\nselib"
Type: filesandordirs; Name: "{app}\scripts"
Type: files;          Name: "{app}\cw-parolalar.txt"
; EN SON: klasorun tamami temizlensin (baska uretilmis dosya kalmasin) ✓
Type: filesandordirs; Name: "{app}"
; NOT: lisans.anahtar BILEREK silinmiyor (%APPDATA%\CyberWolfSec altinda) — yeniden kurulumda FULL surum kalsin.

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;

// KURULUMDAN ONCE calisan program zorla kapatilir (dosya kilitli kalip kurulum TAKILMASIN) ✓
var KapatSonuc: Integer;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Exec(ExpandConstant('{sys}\taskkill.exe'), '/F /IM CWPS.exe /T', '', SW_HIDE, ewWaitUntilTerminated, KapatSonuc);
  Exec(ExpandConstant('{sys}\taskkill.exe'), '/F /IM CWPS-Keygen.exe /T', '', SW_HIDE, ewWaitUntilTerminated, KapatSonuc);
  Sleep(800);
  Result := '';
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // NOT: Burada MsgBox KULLANILMAZ — sessiz kurulumda ekran bekleyip kurulumu kilitliyordu ✗
    // Satici bilgisi OKU-BENI.txt ve 3-KEYGEN/OKU-BENI-KEYGEN.txt icinde yazili ✓
  end;
end;
