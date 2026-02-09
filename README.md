# ORKA IoT Stack (Orange Pi 3B)

100% local stack using Docker Compose:
- Mosquitto (MQTT broker)
- Zigbee2MQTT (Zigbee -> MQTT)
- Node-RED (automations)
- ThingsBoard CE + PostgreSQL (dashboards)
- Daily backups of volumes

This template is ARM-friendly and keeps all state on disk.

## Quick Start
1. Find the adapter path (host):
   ```sh
   ls -l /dev/serial/by-id/
   ```
   Copy the full path into `.env` as `ZIGBEE_ADAPTER_HOST`.

2. Make the script executable (Linux):
   ```sh
   chmod +x scripts/make-mqtt-pass.sh
   ```

3. Create the Mosquitto password file:
   ```sh
   ./scripts/make-mqtt-pass.sh
   ```

4. Start everything:
   ```sh
   docker compose up -d
   ```

5. Tail logs (first boot can take a while):
   ```sh
   docker compose logs -f zigbee2mqtt
   docker compose logs -f mosquitto
   docker compose logs -f thingsboard
   ```

6. Open UIs:
   - Zigbee2MQTT: `http://<ip>:${Z2M_UI_PORT}`
   - Node-RED: `http://<ip>:${NODERED_PORT}`
   - ThingsBoard: `http://<ip>:${TB_PORT}`

## Windows (Docker Desktop)
En Windows, Docker Desktop **no puede** pasar un puerto `COM` directamente a un contenedor Linux. Por eso:
- Si quieres Zigbee2MQTT en Docker, debes correr el stack dentro de **WSL2** y pasar el USB a WSL.
- Si quieres quedarte 100% Windows, corre Zigbee2MQTT **nativo** y solo levanta el resto con Docker.

### Opcion 1: Windows + Zigbee2MQTT nativo
1. Crear passwordfile (PowerShell):
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\make-mqtt-pass.ps1
   ```

2. Levantar el stack sin Zigbee2MQTT (usa override):
   ```powershell
   docker compose -f docker-compose.yml -f docker-compose.windows.yml up -d
   ```

3. En tu `configuration.yaml` de Zigbee2MQTT (Windows), apunta al broker:
   ```yaml
   mqtt:
     server: mqtt://localhost:1883
     user: iot
     password: supersegura
   ```

### Opcion 2: Todo en WSL2 (Zigbee2MQTT dentro de Docker)
1. Conecta el USB Zigbee a WSL2 (usbipd).
2. Dentro de WSL2, ejecuta:
   ```sh
   ./scripts/make-mqtt-pass.sh
   docker compose up -d
   ```
3. Asegura que `ZIGBEE_ADAPTER_HOST` use `/dev/serial/by-id/...`.

## CI/CD (Deploy automatico a Orange Pi)
Objetivo: cada `push` a GitHub despliega automaticamente en la Orange Pi usando un **runner self-hosted**.

### 1) Preparar la Orange Pi
1. Clona este repo en la Orange Pi (ej: `/opt/orka`).
2. Crea el archivo `.env` local desde `/.env.example` y ajusta:
   - `ZIGBEE_ADAPTER_HOST`
   - credenciales MQTT
   - `TZ`
3. Asegura que el usuario del runner tenga acceso a Docker:
   ```sh
   sudo usermod -aG docker <usuario>
   ```

### 2) Instalar runner self-hosted
En GitHub: `Settings -> Actions -> Runners -> New self-hosted runner`, elige Linux/ARM64 y sigue los comandos.
Cuando registre el runner, **agrega el label `orange-pi`**.

### 3) Workflow listo
El workflow esta en:
- `.github/workflows/deploy-orange-pi.yml`

Dispara automaticamente en `push` a `main` o `master` y ejecuta:
- `docker compose pull`
- `docker compose up -d`

Nota: el checkout usa `clean: false` para **no borrar datos locales** (volumenes y `.env`).

## Verification (MQTT pub/sub)
Use the credentials from `.env`:
```sh
# Subscribe to all Zigbee2MQTT topics
mosquitto_sub -h <host> -t "zigbee2mqtt/#" -u iot -P supersegura

# Publish a test message
mosquitto_pub -h <host> -t "zigbee2mqtt/test" -m '{"ping":1}' -u iot -P supersegura
```
If you want to run these inside the Mosquitto container:
```sh
docker compose exec mosquitto mosquitto_sub -h mosquitto -t "zigbee2mqtt/#" -u iot -P supersegura
```

## Node-RED Example Flows
Import any of these JSON files:
- `nodered/flows/z2m-sensor-log.json`: logs all Zigbee2MQTT messages to `/data/sensor.log`.
- `nodered/flows/z2m-telegram-alert.json`: sends Telegram alert if temperature > 30C.
- `nodered/flows/z2m-command-onoff.json`: ON/OFF commands to `zigbee2mqtt/<device>/set`.

After import:
- Edit the MQTT broker node and set user/pass to match `.env`.
- For Telegram flow, replace `<TELEGRAM_BOT_TOKEN>` and `<TELEGRAM_CHAT_ID>`.
- Update `zigbee2mqtt/<device>/set` with your real device name.

## Files and Persistence
- Zigbee2MQTT: `./zigbee2mqtt/data`
- Mosquitto: `./mosquitto/{data,log}` + `./mosquitto/passwordfile`
- Node-RED: `./nodered/data`
- ThingsBoard/Postgres: `tb_pgdata` volume
- Backups: `./backups`

## Zigbee2MQTT Notes
- The Zigbee network keys, channel, PAN ID are preserved in `zigbee2mqtt/data/configuration.yaml` to avoid re-pairing.
- The adapter is mapped by `/dev/serial/by-id/...` (host) to `/dev/ttyACM0` (container).
- The config uses `mqtt://mosquitto:1883` (not `localhost`).

## Backup
The `backup` service runs daily and stores archives in `./backups`.
Set schedule in `.env` with `BACKUP_CRON`.

## ARM Notes
If any image fails to pull on arm64:
- Check the manifest: `docker buildx imagetools inspect <image>`
- Pin a tag that supports arm64 or build locally

## Troubleshooting
- Zigbee2MQTT cannot open the adapter:
  - Confirm `ZIGBEE_ADAPTER_HOST` points to `/dev/serial/by-id/...`
  - Ensure `/run/udev:/run/udev:ro` is mounted
  - Check permissions: add user to `dialout`, or enable `user/group_add` in compose
- MQTT auth errors:
  - Recreate password file with `./scripts/make-mqtt-pass.sh` (Linux) or `scripts\\make-mqtt-pass.ps1` (Windows)
  - Verify `MQTT_USER/MQTT_PASS` in `.env` match the Zigbee2MQTT config
- Zigbee2MQTT UI not reachable:
  - Verify `frontend.port` in `configuration.yaml` and the compose port mapping
- ThingsBoard not ready:
  - Give it a few minutes on first boot and check `docker compose logs -f thingsboard`

## Checklist (Quick Triage)
- `docker compose ps` shows all services healthy/running
- `ls -l /dev/serial/by-id/` shows the Zigbee adapter
- `docker compose logs -f zigbee2mqtt` shows no serial errors
- MQTT pub/sub works with your credentials
- UIs load on the configured ports
