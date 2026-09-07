# Codebase tour — iot-tofu / boot-back

This is an IoT platform for Raspberry Pi CM4 boards on an [Oratek Tofu](https://tofu.oratek.com/) carrier: one Tofu box is the PXE boot server for a LAN of Pis; those Pis run sensors and Home Assistant. A separate Next.js site (`iot-tofu-site`) talks to this API over `NEXT_PUBLIC_API_URL`.

The npm package name is `boot-back`.

## Architecture

Three layers in one repo:

| Layer | Where | Role |
|---|---|---|
| **Boot-Back** | `src/` | LoopBack 4 TypeScript API (x86 for dev, arm64 on the Tofu in prod) |
| **IoT OS / pxetools** | `rpi/` | Shell + Python that turn the Tofu into a DHCP/TFTP/NFS boot server, plus per-sensor drivers |
| **Home Assistant** | `region/` | HA YAML that runs in a container on the Pis |

Networking: each **region** is a PoE LAN (Tofu + Pis). The API does not talk to Pis over HTTP; it runs privileged commands **on the Tofu host**. That is why `src/controllers/region.controller.ts` shells out.

**Boot-Back wiring** starts in `src/index.ts` → `src/application.ts` (`BackApplication`):

- Mixins: `BootMixin` + `ServiceMixin` + `RepositoryMixin`
- Controllers auto-boot from `src/controllers/*.controller.ts`
- Repositories from `src/repositories/*.repository.ts`
- Swagger UI at `/explorer` (`RestExplorerComponent`)
- Custom response serialization in `src/providers/api-resources.provider.ts`
- Request pipeline: `src/sequence.ts` (`MySequence` — currently a thin `MiddlewareSequence`)
- Static files from `public/` at `/`

Two controller styles live side by side:

1. **Standard LB4 CRUD** — `Category` as a template: model → in-memory datasource → repository → controller. Persistence is the LoopBack memory connector writing `.env.region.db`. The `DIRECTOR`/`ACTOR` enum on Category is leftover sandbox data, not IoT domain.
2. **Shell-exec** — `RegionController` has no model/repo. It runs scripts in `rpi/` and the installed `pxetools` CLI.

## Main flows

### 1. Start the API

```
src/index.ts  →  BackApplication.boot()  →  listen on PORT (3000)
```

Config is `config.js` (host/port/OpenAPI). Env is loaded in `src/bootstrap.ts` from `.env`.

### 2. CRUD (dev / template)

`POST/GET/PATCH/PUT/DELETE /categories` in `src/controllers/category.controller.ts`:

`Category` (`src/models/category.model.ts`) → `CategoryRepository` (`src/repositories/category.repository.ts`) → `RegionDataSource` (`src/datasources/region.datasource.ts`, memory file `.env.region.db`).

Validation extras live in `src/components/validators.component.ts` (custom AJV `exists` keyword). Tests are the best-covered path: `src/__tests__/acceptance/category/`.

### 3. Region / PXE (the real product)

The frontend is supposed to:

1. **Initialize region** → `POST /regions/setup`  
   Runs `rpi/pxetools-install.sh` then `rpi/pxetools-setup.sh`.
2. **Add a Pi** → `POST /regions/rpi` with `{ "serial": "9f55bbfd" }`  
   Validates 8-char hex, then `sudo pxetools --add <serial>`.

That maps to the CLI workflow in `README.md` / `rpi/pxetools.py`: install → setup → `--add` / `--list` / `--remove`. `--add` copies TFTP + NFS trees under `/tftpboot/<serial>` and `/nfs/<serial>`, writes `cmdline.txt` for NFS root, updates `/etc/exports`.

**Two gaps that matter if you touch this path** (documented in `PROXIMOS-PASSOS.md`):

- `pxetools --add` is **interactive** (`Owner name`, `Pi name`, image choice). The API does not feed stdin, so add currently dies with `EOFError`.
- The Docker image (`Dockerfile`) runs as user `node` and never installs `sudo`. Compose mounts `/home/jo/pipe:/hostpipe`; `rpi/pipe.sh` looks like the intended host-command bridge, but the controller does not use it.

### 4. Sensors on a Pi

Each of `rpi/htu21`, `rpi/vl53l1x`, `rpi/ws281x` is the same shape: `install-*.sh`, systemd `.service`, Python `main.py`, Home Assistant YAML under `ha/`. HA config for a region is `region/configuration.yaml` + `region/sensors.yaml`.

### 5. Deploy

Push to `main` → `.github/workflows/cd.yaml` on a **self-hosted ARM64 runner on the Tofu Pi** → builds `Dockerfile.prod` → pushes `boot-back:<sha>` / `boot-back:latest` to Docker Hub.

## How to run

Node **>= 18.17.1**. From the repo root:

```sh
npm install
npm start          # rebuild + run; open http://127.0.0.1:3000
                   # Explorer: http://127.0.0.1:3000/explorer
                   # Health:   http://127.0.0.1:3000/ping
```

Useful commands:

```sh
npm run build:watch
npm test           # rebuild, jest, then lint
npx jest src/__tests__/acceptance/category/category-crud.spec.ts
npm run docker:build && npm run docker:run
```

Docker Compose: `compose.yml` (dev, `Dockerfile`, entrypoint `.docker/start.sh` / nodemon) and `compose.prod.yml` (also starts Home Assistant on host networking).

PXE on the real Tofu (not needed for local API work):

```sh
rpi/pxetools-install.sh
rpi/pxetools-setup.sh
sudo pxetools --add 9f55bbfd
sudo pxetools --list
```

## Best first change

**Add `GET /regions/rpi` in `src/controllers/region.controller.ts`**, wrapping `sudo pxetools --list`.

Why that file and that endpoint:

- `region.controller.ts` is the live product surface. Category CRUD is a LoopBack template with tests; Region is what the config site actually calls, and it has **no tests yet**.
- `--list` is non-interactive (unlike `--add` / `--remove`, which prompt). You can copy the existing `execFileAsync('sudo', …)` + serial-validation pattern without solving stdin or `pipe.sh`.
- It is the first planned API in `PROXIMOS-PASSOS.md`.

After that, in the same file: catch non-zero `execFile` failures and return HTTP 500 (today they become unhandled rejections). Then `DELETE /regions/rpi/:serial` and `POST /regions/reset`.

If you want a **safer, test-only first step**: an acceptance spec next to `src/__tests__/acceptance/ping.controller.spec.ts` that stubs `execFile` and hits `/regions/setup` and `/regions/rpi`. Same file, no hardware.

**Avoid as a first change:** making `POST /regions/rpi` actually work. That needs non-interactive flags (or piped stdin) in `rpi/pxetools.py` *and* a real privileged path (`sudo` vs `rpi/pipe.sh`). That is the right second project, not a warmup.

## Files worth opening first

- `src/application.ts` — app composition
- `src/index.ts` + `config.js` — boot and listen
- `src/controllers/region.controller.ts` — PXE API (where to change)
- `src/controllers/category.controller.ts` — CRUD template
- `src/models/category.model.ts` + `src/repositories/category.repository.ts` + `src/datasources/region.datasource.ts`
- `rpi/pxetools.py` — what the API actually drives
- `PROXIMOS-PASSOS.md` — backlog and known breakage
- `compose.yml` / `Dockerfile` / `.github/workflows/cd.yaml` — run and ship
