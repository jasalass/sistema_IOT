# ThingsBoard + Node-RED

## Roles de login

- `sysadmin@thingsboard.org` / `sysadmin`: administracion global.
- `tenant@thingsboard.org` / `tenant`: gestion de dispositivos, dashboards y gateways.

Para telemetria y dashboards usar `tenant`.

## Opcion recomendada: Node-RED como gateway MQTT

Ventaja: auto-creacion de dispositivos desde Zigbee2MQTT sin token por dispositivo.

En modo cloud + edge:

- Entrada Zigbee desde broker local edge (`mosquitto:1883`).
- Salida a ThingsBoard cloud (`<TB_CLOUD_HOST>:<TB_CLOUD_MQTT_PORT>`).

### Flujo de telemetria

- Entrada: `zigbee2mqtt/#`
- Ignorar:
  - `zigbee2mqtt/bridge/...`
  - `zigbee2mqtt/<device>/set`
- Salida a ThingsBoard:
  - Topic: `v1/gateway/telemetry`
  - Broker: `TB_CLOUD_HOST:TB_CLOUD_MQTT_PORT`
  - Usuario: token del Gateway

### Cache de estado

Guardar ultimo `state` por dispositivo en `flow context` (`z2m_state`) para responder RPC `getState`.

## RPC ON/OFF (dashboard -> Zigbee)

Flujo RPC en Node-RED:

- Entrada: `v1/gateway/rpc`
- Parseo:
  - `device`
  - `data.id`
  - `data.method`
  - `data.params`
- Si `method=getState`:
  - responder estado desde cache
  - no publicar a Zigbee2MQTT
- Si comando `setState`:
  - publicar a `zigbee2mqtt/<device>/set`
  - responder ACK a `v1/gateway/rpc`

## Config de widget tipo switch

### Comando

- Accion: `Ejecutar RPC`
- Metodo: `setState`
- Parametros ON: `{"state":"ON"}`
- Parametros OFF: `{"state":"OFF"}`

### Estado inicial recomendado

Usar telemetria (no `getState` RPC) para evitar timeout visual.

- Accion: `Obtener serie temporal`
- Key: `state`
- Convertidor (funcion):

```js
if (!data || data.length === 0) return false;
return (data[0].value || '').toString().toUpperCase() === 'ON';
```

## Validacion

1. En `Devices -> <Switch> -> Latest telemetry` debe existir `state`.
2. Al presionar ON/OFF, debe publicarse `zigbee2mqtt/<device>/set`.
3. No debe aparecer `Invalid message 'undefined'` en Zigbee2MQTT.

## Causas tipicas de timeout RPC

- Nodo function con 1 salida (sin respuesta a TB).
- Broker de respuesta apuntando a `mosquitto` en vez del broker MQTT de ThingsBoard cloud.
- `getState` sin manejo y `params` nulo.
- Widget esperando booleano pero recibiendo string `ON/OFF` sin converter.
