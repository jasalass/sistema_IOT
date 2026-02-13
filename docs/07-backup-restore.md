# Backup y restore

## Servicio de backup

Contenedor: `offen/docker-volume-backup` (`service: backup`).

Variables en `.env`:

- `BACKUP_CRON` (ej: `0 2 * * *`)
- `BACKUP_RETENTION_DAYS` (ej: `7`)

Destino:

- `./backups`

Origenes:

- volumen `tb_pgdata`
- `./zigbee2mqtt/data`
- `./nodered/data`
- `./mosquitto/data`

## Verificar backup activo

```sh
docker compose ps
docker compose logs --tail=100 backup
```

Log esperado:

- `Successfully scheduled backup from environment with expression ...`

## Problema conocido: cron parse error

Si aparece error tipo:

- `failed to parse int from '"0'`

Revisar `docker-compose.yml`: `BACKUP_CRON_EXPRESSION` no debe llevar comillas extra.

## Validar archivos generados

```sh
ls -lh backups
```

## Restore (procedimiento base)

1. Detener stack:
```sh
docker compose down
```

2. Respaldar estado actual antes de restaurar:
```sh
mv backups backups.before-restore-$(date +%F-%H%M)
mkdir -p backups
```

3. Inspeccionar contenido del archivo a restaurar:
```sh
tar -tzf backups/<archivo>.tar.gz | head
```

4. Restaurar bind mounts segun estructura del tar.
5. Restaurar volumen `tb_pgdata` con contenedor temporal si corresponde.
6. Levantar stack y validar integridad.

Nota: probar restore primero en entorno de prueba.