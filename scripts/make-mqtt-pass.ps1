$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$envPath = Join-Path $root ".env"
$mosqDir = Join-Path $root "mosquitto"
$passFile = Join-Path $mosqDir "passwordfile"

if (-not (Test-Path $envPath)) {
  throw "No existe .env en $root"
}

$envLines = Get-Content $envPath
$MQTT_USER = ($envLines | Where-Object { $_ -like 'MQTT_USER=*' } | Select-Object -Last 1) -replace '^MQTT_USER=', ''
$MQTT_PASS = ($envLines | Where-Object { $_ -like 'MQTT_PASS=*' } | Select-Object -Last 1) -replace '^MQTT_PASS=', ''

if ([string]::IsNullOrWhiteSpace($MQTT_USER) -or [string]::IsNullOrWhiteSpace($MQTT_PASS)) {
  throw "MQTT_USER o MQTT_PASS vacio en .env"
}

if (-not (Test-Path $mosqDir)) {
  New-Item -ItemType Directory -Force -Path $mosqDir | Out-Null
}

Write-Host "Creando passwordfile en $passFile ..."

$volume = "{0}:/mosquitto" -f $mosqDir

docker run --rm -v $volume eclipse-mosquitto:2 mosquitto_passwd -b -c /mosquitto/passwordfile $MQTT_USER $MQTT_PASS

if (-not (Test-Path $passFile)) {
  throw "No se creo el passwordfile"
}

Write-Host "OK: passwordfile creado"