#!/usr/bin/env sh
set -eu

ENV_FILE="${1:-.env}"
MOSQ_DIR="${MOSQ_DIR:-./mosquitto}"
PASSFILE="$MOSQ_DIR/passwordfile"

MQTT_USER="${MQTT_USER:-}"
MQTT_PASS="${MQTT_PASS:-}"

if [ -z "$MQTT_USER" ] || [ -z "$MQTT_PASS" ]; then
  if [ -f "$ENV_FILE" ]; then
    MQTT_USER=$(grep -E '^MQTT_USER=' "$ENV_FILE" | tail -n1 | cut -d= -f2- || true)
    MQTT_PASS=$(grep -E '^MQTT_PASS=' "$ENV_FILE" | tail -n1 | cut -d= -f2- || true)
  fi
fi

if [ -z "$MQTT_USER" ] || [ -z "$MQTT_PASS" ]; then
  echo "Missing MQTT_USER or MQTT_PASS. Provide env vars or ensure they exist in $ENV_FILE." >&2
  exit 1
fi

if [ ! -d "$MOSQ_DIR" ]; then
  echo "Missing directory: $MOSQ_DIR" >&2
  exit 1
fi

umask 077
mkdir -p "$MOSQ_DIR"

# Create password file using the mosquitto image
# Writes to ./mosquitto/passwordfile on the host

docker run --rm \
  -v "$(pwd)/$MOSQ_DIR:/mosquitto" \
  eclipse-mosquitto:2 \
  mosquitto_passwd -b -c /mosquitto/passwordfile "$MQTT_USER" "$MQTT_PASS"

chmod 600 "$PASSFILE" || true

echo "Password file created at $PASSFILE"
