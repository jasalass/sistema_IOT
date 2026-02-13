# Troubleshooting

## 1) Mosquitto en restart loop

Sintoma:

- `Error: Unable to open log file /mosquitto/log/mosquitto.log`
- `Unable to open pwfile`

Checks:

```sh
ls -ld mosquitto/passwordfile
ls -ld mosquitto/log mosquitto/data
docker compose logs --tail=100 mosquitto
```

Fix:

```sh
docker compose stop mosquitto
docker compose rm -f mosquitto
sudo rm -rf mosquitto/passwordfile
sudo bash scripts/make-mqtt-pass.sh
sudo chown 1883:1883 mosquitto/passwordfile mosquitto/log mosquitto/data
sudo chmod 640 mosquitto/passwordfile
docker compose up -d mosquitto
```

## 2) `passwordfile` es directorio

Sintoma:

- `file mosquitto/passwordfile` devuelve `directory`

Causa:

- bind mount previo creo ruta como carpeta.

Fix:

- borrar carpeta
- recrear archivo con script
- recrear contenedor

## 3) Backup reinicia con error cron

Sintoma:

- `failed to parse int from '"0'`

Causa:

- cron expression con comillas extra.

Fix:

- usar `BACKUP_CRON_EXPRESSION=${BACKUP_CRON:-0 2 * * *}`

## 4) Zigbee2MQTT no abre adaptador

Checks:

```sh
ls -l /dev/serial/by-id/
ls -l /dev/ttyACM* /dev/ttyUSB* 2>/dev/null
docker compose logs --tail=100 zigbee2mqtt
```

Fix:

- usar `ZIGBEE_ADAPTER_HOST=/dev/serial/by-id/...`
- confirmar mount `/run/udev:/run/udev:ro`
- revisar permisos `dialout`

## 5) Windows: comando queda en `>>`

Causa:

- PowerShell en multiline por backtick o comillas abiertas.

Fix:

- `Ctrl + C`
- volver a ejecutar en una sola linea

## 6) ThingsBoard RPC timeout en widget switch

Checks:

- function RPC con 2 salidas
- salida 2 conectada a `TB RPC response`
- broker de respuesta apuntando a `thingsboard:1883` con token gateway

Fix adicional:

- para estado inicial, usar `Obtener serie temporal` key `state` + converter a boolean

## 7) Zigbee2MQTT error `Invalid message 'undefined'`

Causa:

- Node-RED publica payload vacio a `zigbee2mqtt/<device>/set`.

Fix:

- validar `params` antes de publicar
- manejar `getState` sin publicar a Zigbee

## 8) Node-RED no muestra archivos en Import -> Local

Causa:

- JSON fuera de `/data` del contenedor o cache UI.

Fix:

```sh
mkdir -p nodered/data/flows
cp nodered/flows/*.json nodered/data/flows/
docker compose restart nodered
```

Alternativa: importar por Portapapeles.