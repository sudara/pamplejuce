#define Version Trim(FileRead(FileOpen("..\VERSION")))
#define Year GetDateTimeString("yyyy","","")

[Setup]
AppName=Pamplejuce
AppCopyright=Copyright (C) {#Year} Melatonin
AppPublisher=Melatonin
AppVersion={#MyAppVersion}

[Files]
Source: "..\Builds\Pamplejuce_artefacts\Release\VST3\Pamplejuce.vst3\*.*"; DestDir: "{commoncf64}\VST3\Pamplejuce.vst3\"; Check: Is64BitInstallMode; Flags: overwritereadonly ignoreversion; Attribs: hidden system;
