# ORKA IoT Stack (Local)

Plantilla para levantar un stack IoT 100% local con Docker Compose:

- Mosquitto (broker MQTT)
- Zigbee2MQTT (Zigbee -> MQTT)
- Node-RED (automatizacion)
- ThingsBoard CE + PostgreSQL (visualizacion, reglas, almacenamiento)
- Backup diario de volumenes

Este repositorio esta preparado para correr en Orange Pi (ARM64) y tambien tiene modo de prueba en Windows.

## Documentacion

- `docs/README.md`
- `docs/01-arquitectura.md`
- `docs/02-instalacion-orange-pi.md`
- `docs/03-instalacion-windows.md`
- `docs/04-operacion.md`
- `docs/05-thingsboard-nodered.md`
- `docs/06-cicd-orange-pi-runner.md`
- `docs/07-backup-restore.md`
- `docs/08-troubleshooting.md`

## Inicio rapido (Orange Pi)

1. Crear `.env` desde el ejemplo:
```sh
cp .env.example .env
```

2. Detectar adaptador Zigbee y actualizar `ZIGBEE_ADAPTER_HOST`:
```sh
ls -l /dev/serial/by-id/
```

3. Crear carpetas runtime y permisos base:
```sh
mkdir -p mosquitto/data mosquitto/log nodered/data backups
sudo chown -R 1883:1883 mosquitto/data mosquitto/log
sudo chown -R 1000:1000 nodered/data backups
```

4. Crear `mosquitto/passwordfile`:
```sh
chmod +x scripts/make-mqtt-pass.sh
./scripts/make-mqtt-pass.sh
sudo chown 1883:1883 mosquitto/passwordfile
sudo chmod 640 mosquitto/passwordfile
```

5. Levantar stack:
```sh
docker compose up -d
```

6. Ver estado:
```sh
docker compose ps
docker compose logs -f zigbee2mqtt
docker compose logs -f mosquitto
```

## Inicio rapido (Windows)

Para Windows sin WSL2 USB passthrough, usar Zigbee2MQTT nativo y Docker para el resto:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\make-mqtt-pass.ps1
docker compose -f docker-compose.yml -f docker-compose.windows.yml up -d
```

Configura Zigbee2MQTT nativo para publicar a:

```yaml
mqtt:
  server: mqtt://localhost:1883
  user: iot
  password: supersegura
```

## URLs

- Zigbee2MQTT UI: `http://<ip>:8084`
- Node-RED: `http://<ip>:1880`
- ThingsBoard: `http://<ip>:8080`

## CI/CD

Hay workflow listo en `.github/workflows/deploy-orange-pi.yml` para deploy automatico con runner self-hosted etiquetado `orange-pi`.

Detalle completo en `docs/06-cicd-orange-pi-runner.md`.

## Notas de seguridad

- No subir `.env` ni `mosquitto/passwordfile`.
- Cambiar credenciales por defecto antes de produccion.
- Mantener respaldo de `zigbee2mqtt/data/configuration.yaml` para no perder red Zigbee.