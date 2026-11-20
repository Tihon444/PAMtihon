param([int]$Port = 8080)
$ErrorActionPreference = 'Stop'
python (Join-Path $PSScriptRoot 'server.py') --port $Port
