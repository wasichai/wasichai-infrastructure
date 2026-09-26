# wasichai-infrastructure

Local infrastructure for [wasichai](https://github.com/wasichai/wasichai) apps and its sample repositories
([simple-sample](https://github.com/wasichai/simple-sample), [documents-sample](https://github.com/wasichai/documents-sample),
[gis-sample](https://github.com/wasichai/gis-sample), [full-sample](https://github.com/wasichai/full-sample)):
PostgreSQL 18 with PostGIS 3.6 and pgvector, GeoServer, and a plain PostgreSQL. The wasichai libraries do not
depend on this repository; it is one ready-made way to get what they need on a laptop.

| Service | Profile | Image | Host port | Container |
|---|---|---|---|---|
| `postgres` | (default) | built from `docker/postgres` (`postgis/postgis:18-3.6` + pgvector) | `${WASICHAI_PG_PORT:-5432}` | `wasichai-postgres` |
| `geoserver` | `gis` | `docker.osgeo.org/geoserver:3.0.1`, admin `admin` / `geoserver` | 8081 | `wasichai-geoserver` |
| `postgres-plain` | `core` | `postgres:18`, no PostGIS | 5433 | `wasichai-postgres-plain` |

User, password and default database are `wasichai` everywhere. The `postgres` image creates the extensions
`postgis`, `pgcrypto` and `vector` and the schemas `wasichai` and `app_data` on its first start
(`docker/postgres/init/01-extensions.sql`, baked into the image so a remote docker daemon behaves the same).

## Use

```bash
WASICHAI_PG_PORT=5434 docker compose -f docker/compose.yml up -d                 # postgres
WASICHAI_PG_PORT=5434 docker compose -f docker/compose.yml --profile gis up -d   # + geoserver
docker compose -f docker/compose.yml --profile core up -d postgres-plain         # plain postgres on 5433
```

Pick a free host port with `WASICHAI_PG_PORT`: 5432 is often another PostgreSQL's, and no sample defaults to it.
Give the app the same port as `WASICHAI_DB_PORT`.

## What the samples expect

| Sample | Database | Create it (once) | Server env |
|---|---|---|---|
| simple-sample | `wasichai` on `postgres-plain` | nothing to do | none (it defaults to 5433) |
| documents-sample | `wasichai_documents` on `postgres` | `docker exec wasichai-postgres createdb -U wasichai wasichai_documents` | `WASICHAI_DB_PORT=<WASICHAI_PG_PORT>` |
| gis-sample | `wasichai_gis` on `postgres` | `docker exec wasichai-postgres createdb -U wasichai wasichai_gis` | `WASICHAI_DB_PORT=<WASICHAI_PG_PORT>` |
| full-sample | `wasichai_full` on `postgres` | `docker exec wasichai-postgres createdb -U wasichai wasichai_full` | `WASICHAI_DB_PORT=<WASICHAI_PG_PORT>` |

One database per sample: the samples install different modules, and one cannot read the field types another left
in a shared database.

GeoServer reaches PostgreSQL over the compose network, as host `postgres`, port 5432 (the container's port,
whatever `WASICHAI_PG_PORT` is). An app that publishes layers to it sets
`WASICHAI_GEOSERVER_ENABLED=true`, `WASICHAI_GIS_GEOSERVER_DATASTORE_HOST=postgres` and
`WASICHAI_GIS_GEOSERVER_DATASTORE_DATABASE=<its database>`; wasichai's defaults (`localhost`, `wasichai`) do not
know about this network. CORS is on for local development, because the layers screen previews WMS tiles straight
from GeoServer.

## Local secrets

`.local/` is git-ignored and holds machine-local secrets (`.local/secrets.env`: tokens used to set up the
repositories' secrets, and API keys such as `ANTHROPIC_API_KEY` for the assistant). Load them into a shell with
`set -a; source .local/secrets.env; set +a`. Never commit anything under `.local/`.
