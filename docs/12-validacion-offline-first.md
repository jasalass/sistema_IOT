# Validacion offline-first (cliente en red local)

Objetivo: comprobar que el cliente mantiene control local sin internet y que la sincronizacion cloud se recupera al volver WAN.

## Precondiciones

- Edge levantado con `docker-compose.edge.yml`.
- Flow `nodered/flows/offline-first-local-control.json` importado y desplegado.
- ThingsBoard cloud operativo.
- Celular conectado al WiFi local del negocio.

## URLs de validacion

- Dashboard local: `http://<ip-edge>:1880/ui`
- Zigbee2MQTT UI: `http://<ip-edge>:8084`
- ThingsBoard cloud: `http://<ip-cloud>:8080`

## Prueba A: Operacion normal (con internet)

1. Abrir dashboard local en el celular.
2. Encender/apagar switch desde dashboard.
3. Confirmar en Zigbee2MQTT que el estado cambia.
4. Confirmar en ThingsBoard que llega telemetria.

Resultado esperado:

- Control local y cloud funcionan en paralelo.

## Prueba B: Caida de internet (WAN down)

Simular caida WAN en el edge (sin apagar LAN):

```sh
sudo ip route del default
```

Validar:

1. Dashboard local sigue accesible.
2. ON/OFF del switch sigue funcionando.
3. UI muestra estado cloud `OFFLINE` y cola creciendo.
4. ThingsBoard deja de recibir nuevos eventos durante la caida.

Resultado esperado:

- Operacion local continua.
- Sin dependencia de internet para control.

## Prueba C: Recuperacion (WAN up)

Restaurar ruta default (ejemplo):

```sh
sudo ip route add default via <gateway_lan>
```

Validar:

1. Estado cloud cambia a `ONLINE`.
2. Cola local se vacia progresivamente.
3. ThingsBoard vuelve a recibir telemetria.

Resultado esperado:

- Reconexion automatica.
- Sin perdida funcional de control local.

## Comandos utiles

```sh
docker compose -f docker-compose.edge.yml ps
docker compose -f docker-compose.edge.yml logs -f nodered
docker compose -f docker-compose.edge.yml logs -f mosquitto
docker compose -f docker-compose.edge.yml logs -f zigbee2mqtt
```
