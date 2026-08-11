# Project Overview — iot-tofu / boot-back

An IoT platform for Raspberry Pi CM4 boards mounted on a "Tofu" carrier board. The repo combines three layers:

- **Boot-Back** (`src/`) — the backend API, a [LoopBack 4](https://loopback.io/doc/en/lb4/) (TypeScript) application. Runs on x86-64 for development and arm64 (the Tofu Pi) in production.
- **IoT OS / pxetools** (`rpi/`) — shell/Python scripts that turn the Tofu board into a PXE boot server for other RPis on the local LAN, plus per-sensor install scripts (`htu21`, `vl53l1x`, `ws281x`) for Home Assistant integrations.
- **Home-Assistant frontend** (`region/`) — Home Assistant config/compose setup that runs as a container on the RPis.

The companion configuration website (`iot-tofu-site`, Next.js/Tailwind on Vercel) lives in a **separate repo** and only talks to this backend over `NEXT_PUBLIC_API_URL`.

## Boot-Back (`src/`)

[src/application.ts](src/application.ts) (`BackApplication`) wires up the LB4 app with `BootMixin + ServiceMixin + RepositoryMixin`. Controllers auto-boot from `src/controllers/*.controller.ts`, repositories from `src/repositories/*.repository.ts`. Custom pieces registered there:

- `components/` — `EntityComponent`, `ValidatorsComponent`, `RestExplorerComponent` (Swagger UI at `/explorer`).
- `providers/api-resources.provider.ts` — bound to `RestBindings.SequenceActions.SEND`, customizing response serialization.
- `sequence.ts` — `MySequence`, the custom request sequence.
- Static files served from `public/` at `/`.

Two controller patterns coexist:

1. **Standard LB4 CRUD** — [category.controller.ts](src/controllers/category.controller.ts): model (`models/category.model.ts`) → datasource (`datasources/region.datasource.ts`, an in-memory `juggler.DataSource` backed by `.env.region.db`) → repository (`DefaultCrudRepository`) → controller. Template for any new persisted resource.
2. **Shell-exec controller** — [region.controller.ts](src/controllers/region.controller.ts): no model/repository. It runs `rpi/pxetools-install.sh` / `rpi/pxetools-setup.sh` and the installed `pxetools` CLI (`sudo pxetools --add <serial>`) via `execFile` with array args, guarding the one user-supplied value (`serial`) with a hex regex before it reaches `sudo`. This is how the API exposes the manual `pxetools` workflow to the frontend. No acceptance tests exist yet for this controller.

Tests live under `src/__tests__/acceptance/` (jest, matched by `.*\..*spec\.ts$`), currently covering `category` CRUD/validation/filtering and `ping`/home-page.

## pxetools / IoT OS (`rpi/`)

A CLI (`pxetools`, installed by `pxetools-install.sh`) manages RPis on the boot server's LAN by serial number:

```sh
rpi/pxetools-install.sh      # one-time service install
rpi/pxetools-setup.sh         # initial setup
sudo pxetools --add <serial>    # register a RPi
sudo pxetools --list             # list registered RPis
sudo pxetools --remove <serial>   # remove a RPi
rpi/pxetools-reset.sh              # wipe all RPis and reset setup
```

Per-sensor subfolders (`rpi/htu21`, `rpi/vl53l1x`, `rpi/ws281x`) each contain an install script, a systemd `.service` file, a Python driver (`main.py`), and Home Assistant integration files (`ha/`) — the template for adding a new sensor/actuator.

## Home-Assistant frontend (`region/`)

HA config/compose (`configuration.yaml`, `sensors.yaml`, `secrets.yaml`), with `tst.*.yaml` test/tofu variants, running as a container on the RPis.

## Networking model

Each deployment "region" is a local PoE LAN with one Tofu boot server and several RPis, connected upstream to a main LAN/cloud. This is why the backend runs shell commands with `sudo` locally on the Tofu box rather than reaching RPis over the network directly.

## Deployment

`compose.yml` (dev, builds from `Dockerfile`, entrypoint `.docker/start.sh`) and `compose.prod.yml` (prod, builds from `Dockerfile.prod`, also runs the `homeassistant` container on `network_mode: host`) both mount `/home/jo/pipe:/hostpipe` — a host bind mount specific to the Tofu deployment machine.

CI (`.github/workflows/cd.yaml`) builds `Dockerfile.prod` and pushes `boot-back:<sha>` / `boot-back:latest` to Docker Hub on every push to `main`, running on a **self-hosted ARM64 runner on the Tofu Pi itself**, not GitHub-hosted infra.

## Open items

Tracked in [PROXIMOS-PASSOS.md](PROXIMOS-PASSOS.md):

- Planned endpoints: `GET /regions/rpi`, `DELETE /regions/rpi/:serial`, `POST /regions/reset`.
- No error handling for non-zero exit codes from the shell scripts in `region.controller.ts` — a failing script currently causes an unhandled rejection instead of a clean HTTP 500.
- CORS not yet enabled for the separate `iot-tofu-site` (Next.js/Vercel) frontend.
