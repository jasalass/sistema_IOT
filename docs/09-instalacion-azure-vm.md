# Instalacion en Azure VM (Ubuntu + SSH)

Esta guia despliega solo el stack cloud en una VM Linux de Azure con Docker Compose.

## Alcance y nota importante

- En Azure VM no existe passthrough USB directo para el coordinador Zigbee.
- El despliegue cloud levanta ThingsBoard + PostgreSQL.
- Los servicios Zigbee2MQTT/Mosquitto/Node-RED van en cada edge (Orange Pi/Raspberry Pi).
- Para este modo se usa `docker-compose.cloud.yml`.

## 1) Preparar VM

Recomendado:

- Ubuntu 22.04 o 24.04 LTS.
- 2 vCPU y 4 GB RAM minimo (4 vCPU y 8 GB recomendado para ThingsBoard con carga real).
- Disco SSD suficiente para `tb_pgdata` y backups.

## 2) Instalar Docker Engine + Compose plugin

```sh
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg git
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"
```

Cierra y abre tu sesion SSH para aplicar el grupo `docker`.

## 3) Clonar y configurar proyecto

```sh
git clone <repo_url>
cd "nuevo ORKA"
cp .env.cloud.example .env
```

Editar `.env` y cambiar al menos:

- `TB_DB`
- `TB_DB_USER`
- `TB_DB_PASS`
- `TZ`

## 4) Crear ruta de backup cloud

```sh
mkdir -p backups/cloud
```

## 5) Levantar stack cloud

```sh
docker compose -f docker-compose.cloud.yml up -d
docker compose -f docker-compose.cloud.yml ps
```

Logs utiles:

```sh
docker compose -f docker-compose.cloud.yml logs -f postgres
docker compose -f docker-compose.cloud.yml logs -f thingsboard
```

## 6) Reglas de red en Azure (NSG)

Abrir solo lo necesario:

- `22/tcp` (SSH) desde tu IP de administracion.
- `8080/tcp` (ThingsBoard) desde IPs permitidas.
- `1883/tcp` (MQTT ThingsBoard) solo si recibiras datos MQTT directos desde edge.

## 7) URL de acceso

- ThingsBoard: `http://<public-ip-o-dns>:8080`
