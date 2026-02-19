# Instalacion edge (Orange Pi/Raspberry Pi)

Esta guia despliega el stack edge por sitio usando `docker-compose.edge.yml`.

## Prerrequisitos

- Linux arm64 o amd64.
- Docker + Docker Compose plugin.
- Usuario con acceso a Docker.
- Adaptador Zigbee USB (si usas Zigbee2MQTT).

## 1) Clonar y preparar entorno

```sh
git clone <repo_url>
cd "nuevo ORKA"
cp .env.edge.example .env
```

Editar `.env`:

- `TZ`
- `MQTT_USER`, `MQTT_PASS`
- `TB_CLOUD_HOST`, `TB_CLOUD_MQTT_PORT`, `TB_GATEWAY_TOKEN`
- `ZIGBEE_ADAPTER_HOST`
- `EDGE_SWITCH_DEVICE`, `EDGE_SENSOR_DEVICE`

## 2) Detectar adaptador Zigbee

```sh
ls -l /dev/serial/by-id/
```

Pegar ese valor exacto en `ZIGBEE_ADAPTER_HOST`.

## 3) Crear carpetas runtime y permisos

```sh
mkdir -p mosquitto/data mosquitto/log nodered/data backups/edge
sudo chown -R 1883:1883 mosquitto/data mosquitto/log
sudo chown -R 1000:1000 nodered/data backups/edge
```

Si `mosquitto/passwordfile` existe como directorio por error:

```sh
sudo rm -rf mosquitto/passwordfile
```

## 4) Crear passwordfile MQTT

```sh
chmod +x scripts/make-mqtt-pass.sh
./scripts/make-mqtt-pass.sh
sudo chown 1883:1883 mosquitto/passwordfile
sudo chmod 640 mosquitto/passwordfile
```

## 5) Levantar edge

```sh
docker compose -f docker-compose.edge.yml up -d --build
docker compose -f docker-compose.edge.yml ps
```

## 6) Logs utiles

```sh
docker compose -f docker-compose.edge.yml logs -f mosquitto
docker compose -f docker-compose.edge.yml logs -f zigbee2mqtt
docker compose -f docker-compose.edge.yml logs -f nodered
```

## 7) URLs locales

- Zigbee2MQTT: `http://<ip-edge>:8084`
- Node-RED editor: `http://<ip-edge>:1880`
- Node-RED dashboard: `http://<ip-edge>:1880/ui`

## 8) Importar flujo offline-first

Archivo:

- `nodered/flows/offline-first-local-control.json`

Pasos:

1. Abrir Node-RED editor (`http://<ip-edge>:1880`).
2. `Menu -> Import`.
3. Importar `nodered/flows/offline-first-local-control.json`.
4. En el config node MQTT local, definir usuario/password de Mosquitto.
5. En el config node MQTT cloud, definir usuario = token gateway ThingsBoard.
6. `Deploy`.
