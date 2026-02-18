# Operacion diaria

Para modo separado, usa siempre `-f docker-compose.cloud.yml` o `-f docker-compose.edge.yml`.

## Comandos base

```sh
# Estado
docker compose -f docker-compose.edge.yml ps
docker compose -f docker-compose.cloud.yml ps

# Levantar/actualizar
docker compose -f docker-compose.edge.yml up -d
docker compose -f docker-compose.cloud.yml up -d

# Reiniciar servicio
docker compose -f docker-compose.edge.yml restart mosquitto

# Detener stack
docker compose -f docker-compose.edge.yml down
docker compose -f docker-compose.cloud.yml down
```

## Logs utiles

```sh
docker compose -f docker-compose.edge.yml logs -f zigbee2mqtt
docker compose -f docker-compose.edge.yml logs -f mosquitto
docker compose -f docker-compose.edge.yml logs -f nodered
docker compose -f docker-compose.cloud.yml logs -f thingsboard
docker compose -f docker-compose.cloud.yml logs -f backup
```

## Pruebas MQTT

```sh
# Escuchar una publicacion
mosquitto_sub -h <host> -t 'zigbee2mqtt/#' -u <user> -P <pass> -v -C 1

# Publicar prueba
mosquitto_pub -h <host> -t 'zigbee2mqtt/test' -m '{"ping":1}' -u <user> -P <pass>
```

## Node-RED

### Importar flows de ejemplo

Archivos:

- `nodered/flows/z2m-sensor-log.json`
- `nodered/flows/z2m-telegram-alert.json`
- `nodered/flows/z2m-command-onoff.json`

Importar por:

- Portapapeles (recomendado)
- Local (requiere que los JSON esten dentro de `/data` del contenedor)

### Config minima despues de importar

- Broker Mosquitto: `mosquitto:1883`
- Credenciales MQTT desde `.env`
- Ajustar topics por `friendly_name` real

## Actualizacion de stack

```sh
git pull
docker compose -f docker-compose.edge.yml pull
docker compose -f docker-compose.cloud.yml pull
docker compose -f docker-compose.edge.yml up -d
docker compose -f docker-compose.cloud.yml up -d
```

## Verificacion funcional rapida

1. Zigbee2MQTT publica telemetria.
2. Node-RED muestra mensajes en debug.
3. ThingsBoard muestra `Latest telemetry` por dispositivo.
4. Backup queda `Up` y sin errores de parseo cron.
