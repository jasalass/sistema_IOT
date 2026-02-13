# Instalacion en Windows

## Objetivo

Permitir pruebas funcionales del stack en Docker Desktop.

Limitacion: Docker Desktop no pasa `COM` directo a contenedores Linux. Por eso Zigbee2MQTT en Docker solo es viable via WSL2 + usbipd.

## Modo recomendado en Windows

- Zigbee2MQTT nativo en Windows.
- Mosquitto, Node-RED, ThingsBoard, Postgres y Backup en Docker.

## 1) Preparar `.env`

```powershell
Copy-Item .env.example .env
```

## 2) Crear passwordfile MQTT

```powershell
powershell -ExecutionPolicy Bypass -File scripts\make-mqtt-pass.ps1
```

## 3) Levantar stack sin Zigbee2MQTT en Docker

```powershell
docker compose -f docker-compose.yml -f docker-compose.windows.yml up -d
```

## 4) Config Zigbee2MQTT nativo

En tu `configuration.yaml` local de Zigbee2MQTT:

```yaml
mqtt:
  server: mqtt://localhost:1883
  user: iot
  password: supersegura
```

## 5) Verificacion

```powershell
docker compose ps
docker compose logs -f mosquitto
docker compose logs -f nodered
```

## WSL2 (opcional)

Si quieres Zigbee2MQTT dentro de Docker en Windows:

1. Pasar USB a WSL2 con `usbipd`.
2. Ejecutar stack dentro de WSL2.
3. Usar `ZIGBEE_ADAPTER_HOST=/dev/serial/by-id/...`.