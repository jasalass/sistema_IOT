# Instalacion en Orange Pi

> Nota: este documento corresponde al modo monolitico (`docker-compose.yml`).
> Para modo edge recomendado, usar `docs/11-instalacion-edge.md`.

## Prerrequisitos

- Orange Pi con Linux (arm64).
- Docker + Docker Compose plugin.
- Usuario con acceso a Docker.
- Adaptador Zigbee conectado por USB.

## 1) Clonar y preparar entorno

```sh
git clone <repo_url>
cd sistema_IOT
cp .env.example .env
```

Editar `.env`:

- `TZ`
- `MQTT_USER`, `MQTT_PASS`
- `TB_DB`, `TB_DB_USER`, `TB_DB_PASS`
- `ZIGBEE_ADAPTER_HOST`

## 2) Detectar adaptador Zigbee

```sh
ls -l /dev/serial/by-id/
```

Ejemplo:

`/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_...`

Pegar ese valor exacto en `ZIGBEE_ADAPTER_HOST`.

## 3) Crear carpetas runtime y permisos

```sh
mkdir -p mosquitto/data mosquitto/log nodered/data backups
sudo chown -R 1883:1883 mosquitto/data mosquitto/log
sudo chown -R 1000:1000 nodered/data backups
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

Validar que sea archivo:

```sh
file mosquitto/passwordfile
```

## 5) Levantar stack

```sh
docker compose up -d
```

## 6) Verificar estado

```sh
docker compose ps
docker compose logs -f mosquitto
docker compose logs -f zigbee2mqtt
docker compose logs -f thingsboard
```

## 7) Verificar conectividad MQTT

```sh
docker compose exec mosquitto mosquitto_sub -h mosquitto -t 'zigbee2mqtt/#' -u iot -P supersegura -v -C 1
```

## 8) URLs

- Zigbee2MQTT: `http://<ip>:8084`
- Node-RED: `http://<ip>:1880`
- ThingsBoard: `http://<ip>:8080`

## Notas

- Primer arranque de ThingsBoard puede tardar varios minutos.
- Si Zigbee2MQTT no abre el puerto USB, revisar grupo `dialout`.
- `configuration.yaml` debe quedar en `zigbee2mqtt/data/` y con escritura para el contenedor.
