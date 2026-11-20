param([string]$Device = 'RZ8N21QT2EY', [int]$Port = 8080)
$ErrorActionPreference = 'Stop'
& D:/Android/Sdk/platform-tools/adb.exe -s $Device reverse "tcp:$Port" "tcp:$Port"
if ($LASTEXITCODE -ne 0) { throw 'Telefonul nu poate fi conectat prin USB.' }
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
  & D:/flutter/bin/flutter.bat run -d $Device "--dart-define=API_BASE_URL=http://127.0.0.1:$Port/api/v1"
} finally { Pop-Location }
