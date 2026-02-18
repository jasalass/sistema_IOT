# Arquitectura cloud + multi-edge

Objetivo: centralizar visualizacion y gestion en la nube, manteniendo operacion local en cada sitio.

## Componentes

- Cloud:
  - `thingsboard` + `postgres`
- Edge (por sitio):
  - `mosquitto`
  - `zigbee2mqtt` (si hay red Zigbee)
  - `nodered`

## Flujo recomendado

1. Dispositivos Zigbee -> `zigbee2mqtt` -> `mosquitto` local.
2. Dispositivos Wi-Fi/ESP32 -> `mosquitto` local.
3. `nodered` en edge transforma y envia telemetria a ThingsBoard cloud.
4. Comandos desde ThingsBoard bajan al edge via MQTT y Node-RED.

## Por que no dejar Zigbee2MQTT en la nube

- Zigbee depende de un coordinador USB fisico.
- En Azure VM no hay passthrough USB directo para ese caso.
- Zigbee2MQTT debe quedar en edge, cerca de la red Zigbee.

## Opcion ESP32 como gateway Zigbee

Es posible en escenarios especificos, pero no reemplaza bien un edge Linux completo en despliegues multi-sitio:

- Bueno para bajo costo y pocos dispositivos.
- Malo para reglas complejas, persistencia, colas y mantenimiento remoto.
- Para operar varios sitios, Orange Pi con Docker es mas robusto.

Dos variantes:

- ESP32 con Zigbee nativo (por ejemplo ESP32-H2/C6) con firmware propio:
  - Puede actuar como coordinator/router/end-device.
  - Requiere desarrollo y mantenimiento de tu propio bridge a MQTT.
- Orange Pi + dongle Zigbee + Zigbee2MQTT:
  - Menor esfuerzo de software.
  - Mayor compatibilidad de dispositivos y mejor observabilidad operacional.

## Criterio practico

- 1 sitio pequeno y simple: todo local en Orange Pi puede bastar.
- Varios sitios + monitoreo central: cloud + edge es mejor.
- Requisito de continuidad local si cae Internet: cloud + edge con logica local es obligatorio.
