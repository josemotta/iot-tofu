# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

`iot-tofu` (npm package name `boot-back`) is an IoT platform for Raspberry Pi CM4 boards mounted on a "Tofu" carrier board. It has three parts living in one repo:

- **Boot-Back** (`src/`) — the backend API, a [LoopBack 4](https://loopback.io/doc/en/lb4/) (TypeScript) application. Runs on x86-64 for development and arm64 (the Tofu Pi) in production.
- **IoT OS / pxetools** (`rpi/`) — shell/Python scripts that turn the Tofu board into a PXE boot server for other RPis in the local LAN (no local SD card needed), plus per-sensor install scripts (`htu21`, `vl53l1x`, `ws281x`) for Home Assistant integrations.
- **Home-Assistant frontend** (`region/`) — Home Assistant config/compose setup that runs as a container on the RPis.

The companion configuration website (`iot-tofu-site`, Next.js/Tailwind on Vercel) lives in a **separate repo** and is out of scope here; it only talks to this backend over `NEXT_PUBLIC_API_URL`.

## Commands

Run from the repo root (Node >= 18.17.1):

```sh
npm install                # install deps
npm run build               # incremental TS build (lb-tsc)
npm run build:watch         # TS build in watch mode
npm run rebuild              # clean + full build
npm start                    # rebuild then run dist/ (node -r source-map-support/register .)
npm test                     # rebuild, run jest, then lint (pretest/posttest hooks)
npm run test:x                # jest with --detectOpenHandles --forceExit
npm run test:in                # jest --runInBand (use for debugging flaky/async tests)
npm run test:cov               # jest with coverage
npm run test:debug              # jest under node --inspect-brk, single worker
npm run lint                     # eslint + prettier check
npm run lint:fix                  # eslint --fix + prettier --write
npm run migrate                    # rebuild, then run dist/migrate (datasource schema migration)
npm run openapi-spec                # rebuild, then dump the OpenAPI spec to a file
npm run docker:build / docker:run    # build/run the app image (see Dockerfile)
```

Run a single test file directly with jest (skips the rebuild/lint pre/post hooks):

```sh
npx jest src/__tests__/acceptance/category/category-crud.spec.ts
```

Test files are matched by `testRegex: '.*\..*spec\.ts$'` (jest.config.ts) and live under `src/**/__tests__/`.

Docker Compose: `compose.yml` (dev, builds from `Dockerfile`, entrypoint `.docker/start.sh`) and `compose.prod.yml` (prod, builds from `Dockerfile.prod`, also runs the `homeassistant` container on `network_mode: host`). Both mount `/home/jo/pipe:/hostpipe` — a host bind mount specific to the Tofu deployment machine.

CI: `.github/workflows/cd.yaml` builds `Dockerfile.prod` and pushes `boot-back:<sha>`/`boot-back:latest` to Docker Hub on every push to `main`. It runs on a **self-hosted ARM64 runner on the Tofu Pi itself**, not GitHub-hosted infra.

## Architecture

### LoopBack 4 conventions

`src/application.ts` (`BackApplication`) wires up the LB4 app: `BootMixin` + `ServiceMixin` + `RepositoryMixin`. Controllers are auto-booted from `src/controllers/*.controller.ts`, repositories from `src/repositories/*.repository.ts` (see `bootOptions` in `application.ts`). Custom pieces registered there:

- `components/` — `EntityComponent`, `ValidatorsComponent`, `RestExplorerComponent` (Swagger UI at `/explorer`).
- `providers/api-resources.provider.ts` — bound to `RestBindings.SequenceActions.SEND`, i.e. it customizes how responses are serialized.
- `sequence.ts` — `MySequence`, the custom request sequence.
- Static files served from `public/` at `/`.

Two distinct patterns coexist in `src/controllers/`:

1. **Standard LB4 CRUD** (`category.controller.ts`): model (`models/category.model.ts`) → datasource (`datasources/region.datasource.ts`, an in-memory `juggler.DataSource` backed by `.env.region.db`) → repository (`DefaultCrudRepository`) → controller. Follow this pattern for any new persisted resource.
2. **Shell-exec controller** (`region.controller.ts`): no model/repository — it directly `exec()`s scripts in `rpi/` (e.g. `pxetools-install.sh`, `pxetools-setup.sh`) or the installed `pxetools` CLI (`sudo pxetools --add <serial>`) and returns raw stdout/stderr as JSON. This is how the API exposes the manual `pxetools` workflow described below. `PROXIMOS-PASSOS.md` tracks planned additions to this controller (`GET /regions/rpi`, `DELETE /regions/rpi/:serial`, `POST /regions/reset`) and open concerns (no error handling on non-zero exit codes, CORS not yet enabled for the public frontend).

Because `region.controller.ts` shells out with values taken from the request body (e.g. `serial`), treat any change there as a command-injection-sensitive boundary — validate/sanitize input before it reaches `exec`.

### pxetools / IoT OS (`rpi/`)

Operates via a CLI (`pxetools`, installed by `pxetools-install.sh`) that manages RPis on the boot server's LAN by serial number:

```sh
rpi/pxetools-install.sh      # one-time service install
rpi/pxetools-setup.sh         # initial setup
sudo pxetools --add <serial>    # register a RPi
sudo pxetools --list             # list registered RPis
sudo pxetools --remove <serial>   # remove a RPi
rpi/pxetools-reset.sh              # wipe all RPis and reset setup
```

Per-sensor subfolders (`rpi/htu21`, `rpi/vl53l1x`, `rpi/ws281x`) each contain an install script, a systemd `.service` file, a Python `main.py` driver, and Home Assistant (`ha/`) integration files — this is the template to follow when adding support for a new sensor/actuator.

### Networking model

Each deployment "region" is a local PoE LAN with one Tofu boot server and several RPis, connected upstream to a main LAN/cloud (see README.md for the two-tier DNS/gateway setup). This shapes why the backend needs to run shell commands with `sudo` locally on the Tofu box rather than reach RPis over the network directly.

## TypeScript config notes

`tsconfig.json` extends `@loopback/build`'s common config with relaxed strictness (`strictNullChecks: false`, `noImplicitAny: false`) — don't assume strict-mode guarantees when reading/writing `src/`. `baseUrl` is `src`, output goes to `dist/`.
