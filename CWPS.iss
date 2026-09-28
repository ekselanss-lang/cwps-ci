; CYBERWOLF SECURITY 9.9 — Inno Setup
#define SURUM "9.9"
[Setup]
AppName=CYBERWOLF SECURITY
AppVersion={#SURUM}
AppPublisher=CYBERWOLF SEC
DefaultDirName={autopf}\CYBERWOLF SECURITY
DefaultGroupName=CYBERWOLF SECURITY
OutputBaseFilename=CWPS-Setup
Compression=lzma2/ultra64
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
WizardStyle=modern
SetupIconFile=icon.ico
UninstallDisplayName=CYBERWOLF SECURITY {#SURUM}
DisableProgramGroupPage=yes

[Languages]
Name: "tr"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "en"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "masaustu"; Description: "Masaüstü kısayolu oluştur"; GroupDescription: "Kısayollar:"
Name: "duvar"; Description: "Defender'a klasör istisnası ekle (önerilir)"; GroupDescription: "Güvenlik:"

[Files]
Source: "CWPS.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "OKU-BENI.txt"; DestDir: "{app}"; Flags: ignoreversion isreadme
Source: "araclar\*"; DestDir: "{app}\araclar"; Flags: ignoreversion recursesubdirs
Source: "listeler\*"; DestDir: "{app}\listeler"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\CYBERWOLF SECURITY"; Filename: "{app}\CWPS.exe"
Name: "{group}\Kaldır"; Filename: "{uninstallexe}"
Name: "{autodesktop}\CYBERWOLF SECURITY"; Filename: "{app}\CWPS.exe"; Tasks: masaustu

[Run]
Filename: "{app}\CWPS.exe"; Description: "CYBERWOLF SECURITY başlat"; Flags: nowait postinstall skipifsilent
