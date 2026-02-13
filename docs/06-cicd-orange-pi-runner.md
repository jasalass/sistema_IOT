# CI/CD con GitHub Actions y Orange Pi

## Workflow actual

Archivo: `.github/workflows/deploy-orange-pi.yml`

Trigger:

- push a `main` o `master`

Job:

- Runner: `self-hosted` con label `orange-pi`
- Pasos:
  - checkout (`clean: false`)
  - `docker info`
  - `docker compose pull`
  - `docker compose up -d`
  - `docker compose ps`

## Setup del runner

1. En GitHub repo: `Settings -> Actions -> Runners -> New self-hosted runner`.
2. Elegir Linux ARM64.
3. Configurar en Orange Pi:

```sh
mkdir -p ~/actions-runner
cd ~/actions-runner
# ejecutar comandos entregados por GitHub
./config.sh --labels orange-pi
```

4. Instalar como servicio:

```sh
sudo ./svc.sh install
sudo ./svc.sh start
```

## Prerrequisitos del runner

- Docker daemon corriendo.
- Usuario del runner en grupo `docker`.
- `.env` presente en workspace del repo.
- `mosquitto/passwordfile` valido en workspace.

## Verificacion runner

```sh
sudo systemctl status actions.runner.<org>-<repo>.<runnername>.service --no-pager
docker ps
```

## Errores comunes

- Job no arranca:
  - falta label `orange-pi`
- `Cannot connect to the Docker daemon`:
  - daemon caido o usuario sin permisos
- deploy rompe Mosquitto:
  - `passwordfile` mal tipo (directorio) o permisos invalidos