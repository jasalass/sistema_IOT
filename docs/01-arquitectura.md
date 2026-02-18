# Arquitectura

> Nota: este documento describe el modo monolitico (`docker-compose.yml`).
> Para el modo recomendado cloud + multi-edge, revisar `docs/10-arquitectura-cloud-edge.md`.

## Componentes

- `mosquitto`: broker MQTT central con auth (`allow_anonymous false`).
- `zigbee2mqtt`: puente Zigbee -> MQTT.
- `nodered`: flujos de automatizacion, transformacion y puente a ThingsBoard.
- `postgres`: base de datos de ThingsBoard.
- `thingsboard`: UI, reglas y telemetria.
- `backup`: respaldo diario de volumenes y bind mounts.

## Topologia de red

Todos los contenedores comparten la red Docker `iot_net`.

- Zigbee2MQTT publica en `mqtt://mosquitto:1883`
- Node-RED consume y publica en `mosquitto`
- Node-RED publica hacia ThingsBoard en `thingsboard:1883` (modo gateway)

Regla clave: dentro de Docker no usar `localhost` para comunicacion entre servicios.

## Flujo de datos

1. Dispositivo Zigbee -> coordinador USB.
2. Zigbee2MQTT -> topic `zigbee2mqtt/<friendly_name>`.
3. Node-RED:
   - Suscribe `zigbee2mqtt/#`
   - Filtra `bridge` y `.../set`
   - Envia telemetria a ThingsBoard (topic `v1/gateway/telemetry`)
4. ThingsBoard crea/actualiza dispositivos y guarda telemetria.

## Persistencia

- Zigbee2MQTT: `./zigbee2mqtt/data`
- Mosquitto: `./mosquitto/data`, `./mosquitto/log`, `./mosquitto/passwordfile`
- Node-RED: `./nodered/data`
- PostgreSQL: volumen `tb_pgdata`
- Backups: `./backups`

## Zigbee: identidad de red

Para no re-pairing, preservar en `zigbee2mqtt/data/configuration.yaml`:

- `advanced.channel`
- `advanced.network_key`
- `advanced.pan_id`
- `advanced.ext_pan_id`

Tambien mantener mapeo por `by-id`:

- host: `/dev/serial/by-id/...`
- contenedor: `/dev/ttyACM0`
