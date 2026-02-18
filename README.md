# ORKA IoT Stack

Plantilla para desplegar IoT en modo centralizado:

- Cloud: ThingsBoard CE + PostgreSQL + backup
- Edge (por sitio): Mosquitto + Zigbee2MQTT + Node-RED + backup

Tambien se mantiene el compose monolitico para laboratorio local.

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
- `docs/09-instalacion-azure-vm.md`
- `docs/10-arquitectura-cloud-edge.md`
- `docs/11-instalacion-edge.md`

## Modos de despliegue

- `docker-compose.cloud.yml`: stack central en nube (Azure VM u otra Linux VM).
- `docker-compose.edge.yml`: stack por sitio en Orange Pi/Raspberry Pi.
- `docker-compose.yml`: stack monolitico legacy (todo en un solo host).

## Inicio rapido (Cloud)

1. Crear `.env` cloud:
```sh
cp .env.cloud.example .env
```

2. Levantar ThingsBoard + PostgreSQL:
```sh
docker compose -f docker-compose.cloud.yml up -d
```

3. Verificar estado:
```sh
docker compose -f docker-compose.cloud.yml ps
docker compose -f docker-compose.cloud.yml logs -f thingsboard
```

## Inicio rapido (Edge)

1. Crear `.env` edge:
```sh
cp .env.edge.example .env
```

2. Detectar adaptador Zigbee y actualizar `ZIGBEE_ADAPTER_HOST`:
```sh
ls -l /dev/serial/by-id/
```

3. Crear carpetas runtime y permisos base:
```sh
mkdir -p mosquitto/data mosquitto/log nodered/data backups/edge
sudo chown -R 1883:1883 mosquitto/data mosquitto/log
sudo chown -R 1000:1000 nodered/data backups/edge
```

4. Crear `mosquitto/passwordfile`:
```sh
chmod +x scripts/make-mqtt-pass.sh
./scripts/make-mqtt-pass.sh
sudo chown 1883:1883 mosquitto/passwordfile
sudo chmod 640 mosquitto/passwordfile
```

5. Levantar edge:
```sh
docker compose -f docker-compose.edge.yml up -d
```

6. Ver estado:
```sh
docker compose -f docker-compose.edge.yml ps
docker compose -f docker-compose.edge.yml logs -f zigbee2mqtt
docker compose -f docker-compose.edge.yml logs -f mosquitto
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

## Inicio rapido (Azure VM)

Para despliegue cloud en Ubuntu por SSH:

```sh
cp .env.cloud.example .env
docker compose -f docker-compose.cloud.yml up -d
```

Guia completa: `docs/09-instalacion-azure-vm.md`

## URLs

- ThingsBoard (cloud): `http://<ip-cloud>:8080`
- Node-RED (edge): `http://<ip-edge>:1880`
- Zigbee2MQTT UI (edge): `http://<ip-edge>:8084`

## CI/CD

Hay workflow listo en `.github/workflows/deploy-orange-pi.yml` para deploy automatico con runner self-hosted etiquetado `orange-pi`.

Detalle completo en `docs/06-cicd-orange-pi-runner.md`.

## Notas de seguridad

- No subir `.env` ni `mosquitto/passwordfile`.
- Cambiar credenciales por defecto antes de produccion.
- Mantener respaldo de `zigbee2mqtt/data/configuration.yaml` para no perder red Zigbee.
