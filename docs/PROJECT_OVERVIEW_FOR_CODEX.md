# Project Overview For Codex

This document is a fast orientation map for future changes. It captures the project shape, likely edit locations, and verification commands so agents do not need to rediscover the repository every time.

## What This Project Is

Sub2API is an AI API gateway and management platform. It provides:

- API gateway compatibility for Anthropic Claude, OpenAI-compatible APIs, Gemini native APIs, Codex-style endpoints, images, embeddings, and related upstream routing.
- Admin and user web UI for accounts, groups, API keys, usage, billing, subscriptions, payments, monitoring, risk control, OAuth binding, and settings.
- Backend persistence with PostgreSQL via Ent, plus Redis for caches, locks, queues, rate limits, and runtime state.
- Embedded frontend build output served by the Go backend in production.

## Top-Level Layout

| Path | Purpose |
| --- | --- |
| `backend/` | Go backend, migrations, Ent schema/generated code, server binary. |
| `frontend/` | Vue 3 admin/user frontend. Build output goes into backend embed path. |
| `docs/` | Feature and integration docs. |
| `deploy/` | Docker, systemd, Caddy, deployment examples. |
| `assets/` | Public/static partner assets used by readmes/site. |
| `skills/` | Local agent skill/reference material for this project. |
| `Makefile` | Root build/test orchestration. |
| `DEV_GUIDE.md` | Existing local development notes, but currently some text is mojibake in this checkout. |

## Backend Stack

- Language/module: Go module `github.com/Wei-Shaw/sub2api`, `backend/go.mod`.
- HTTP framework: Gin.
- ORM/codegen: Ent in `backend/ent/schema`; generated code in `backend/ent`.
- Dependency injection: Google Wire.
- Config: Viper-backed config in `backend/internal/config`.
- Database: PostgreSQL. Tests may use SQLite/miniredis/testcontainers depending on package.
- Cache/runtime state: Redis.
- Payments: provider registry and adapters in `backend/internal/payment` and `backend/internal/payment/provider`.

Important entry points:

- `backend/cmd/server/main.go`: process entry, setup mode, version flags, server startup/shutdown.
- `backend/cmd/server/wire.go`: Wire graph source.
- `backend/cmd/server/wire_gen.go`: generated Wire graph.
- `backend/internal/server/http.go`: router and HTTP server providers.
- `backend/internal/server/router.go`: global middleware and route registration.
- `backend/internal/server/routes/*.go`: route groups.

Backend layer map:

| Path | Role |
| --- | --- |
| `backend/internal/handler` | HTTP handlers and request/response orchestration. |
| `backend/internal/handler/admin` | Admin-only handlers. |
| `backend/internal/service` | Business logic, gateway routing, billing, OAuth, scheduling, ops, payment orchestration. |
| `backend/internal/repository` | Ent/Postgres/Redis access, caches, upstream HTTP clients, migration runner. |
| `backend/internal/server/middleware` | Auth, CORS, security, logging, rate/body limits. |
| `backend/internal/pkg` | Domain helpers and protocol adapters, including OpenAI, Gemini, Antigravity, API compatibility, web search, TLS fingerprinting. |
| `backend/internal/payment` | Payment abstractions, provider registry, amount/currency/fee helpers. |
| `backend/internal/web` | Embedded frontend serving and HTML config injection. |
| `backend/migrations` | Forward SQL migrations and custom runner assets. |

## Backend Request Flow

Typical management API request:

1. Gin router in `internal/server/router.go`.
2. Versioned group `/api/v1`.
3. Route registration in `internal/server/routes/*.go`.
4. Handler in `internal/handler` or `internal/handler/admin`.
5. Service in `internal/service`.
6. Repository/cache/upstream in `internal/repository`.
7. Ent models and migrations under `ent` and `migrations`.

Gateway request:

1. Public gateway routes are registered by `internal/server/routes/gateway.go`.
2. Routes include `/v1/messages`, `/v1/responses`, `/v1/chat/completions`, `/v1beta/models...`, `/responses`, `/chat/completions`, `/backend-api/codex/responses`, images, videos, embeddings.
3. API-key middleware assigns user/group/platform context.
4. Handler delegates to `GatewayHandler` or `OpenAIGatewayHandler`.
5. `internal/service/gateway_*`, `openai_gateway_*`, scheduler/account/token/billing services select accounts, call upstreams, stream responses, and record usage.

## Frontend Stack

- Framework: Vue 3 with Vite.
- State: Pinia.
- Routing: Vue Router.
- Styling: Tailwind CSS v3 plus app CSS.
- HTTP: Axios wrapper in `frontend/src/api/client.ts`.
- Package manager: pnpm only.
- Tests: Vitest with Vue Test Utils and jsdom.

Frontend entry points:

- `frontend/src/main.ts`: app bootstrap, Pinia, config injection, i18n, router mount.
- `frontend/src/router/index.ts`: public/user/admin/setup routes and guards.
- `frontend/src/api/client.ts`: Axios instance, auth token injection, response unwrapping, refresh behavior.
- `frontend/vite.config.ts`: dev proxy and production build output.

Frontend layout:

| Path | Role |
| --- | --- |
| `frontend/src/api` | Typed API clients by domain. |
| `frontend/src/views` | Route-level pages. `views/user`, `views/admin`, `views/auth`, `views/setup`, `views/public` are main areas. |
| `frontend/src/components` | Reusable UI and domain components. |
| `frontend/src/composables` | Shared composition functions. |
| `frontend/src/stores` | Pinia stores. |
| `frontend/src/i18n` | Internationalization setup/messages. |
| `frontend/src/types` | Shared TypeScript types. |

Frontend API responses are normally unwrapped from backend shape `{ code, message, data }` by `apiClient`; callers usually receive `data` directly.

## Config, Build, And Runtime Notes

- Backend config structs live in `backend/internal/config/config.go`.
- Deployment examples and `config.example.yaml` live under `deploy/`.
- Production frontend build output is `backend/internal/web/dist`, configured by `frontend/vite.config.ts`.
- Backend serves embedded frontend when available and injects public settings through `backend/internal/web`.
- First-run setup is handled by `backend/internal/setup`; `cmd/server/main.go` can start setup wizard or auto-setup from env.
- Server supports h2c and streaming; do not add blanket write/read timeouts that break long streaming responses.

## Code Generation

Generated or semi-generated areas:

- Ent schema source: `backend/ent/schema/*.go`.
- Ent generated output: most files under `backend/ent/`.
- Wire source: `backend/cmd/server/wire.go`, provider sets in `internal/*/wire.go`.
- Wire generated output: `backend/cmd/server/wire_gen.go`.

When changing Ent schema or Wire providers:

```powershell
cd backend
go generate ./ent
go generate ./cmd/server
```

Then run focused tests.

## Database Migrations

Migrations are in `backend/migrations` and are executed by a custom runner in `backend/internal/repository/migrations_runner.go`.

Rules:

- Migration names use `NNN_description.sql`.
- Use `*_notx.sql` only for statements requiring non-transactional execution, especially `CREATE INDEX CONCURRENTLY` / `DROP INDEX CONCURRENTLY`.
- Do not modify, rename, delete, or reorder migrations that may have been applied anywhere.
- Create a new forward migration for follow-up changes.
- The runner stores SHA256 checksums in `schema_migrations`.

The migration README mentions rollback examples, but the runner executes SQL files as-is. Do not put executable down SQL in the same migration file.

## Common Edit Targets

| Task | Start Here |
| --- | --- |
| Add/modify backend API route | `backend/internal/server/routes/*.go`, then matching handler/service/repository. |
| Add admin UI page | `frontend/src/router/index.ts`, `frontend/src/views/admin`, `frontend/src/api`, maybe `frontend/src/stores`. |
| Add user UI page | `frontend/src/router/index.ts`, `frontend/src/views/user`, `frontend/src/components/user`. |
| Change gateway behavior | `backend/internal/server/routes/gateway.go`, `backend/internal/handler/gateway*`, `backend/internal/service/gateway*`, `openai_gateway*`. |
| Change account scheduling | `backend/internal/service/*scheduler*`, `account_*`, `scheduler_*`, repository cache files. |
| Change billing/usage | `backend/internal/service/billing*`, `usage*`, `backend/internal/repository/usage*`, frontend usage/payment views. |
| Change payments | `backend/internal/payment`, `backend/internal/payment/provider`, `backend/internal/service/payment*`, `backend/internal/handler/payment*`, `frontend/src/components/payment`, `frontend/src/views/user/*Payment*`. |
| Change OAuth/account binding | backend `auth_*`, `oauth_*`, platform token providers; frontend `use*OAuth`, auth/profile views. |
| Change Ent model | `backend/ent/schema`, new migration, regenerate Ent. |
| Change app settings/public config | `backend/internal/service/setting*`, `backend/internal/handler/setting*`, `frontend/src/stores/app.ts`, `frontend/src/api/*settings*`. |

## Commands

Backend:

```powershell
cd backend
go test ./...
go test -tags=unit ./...
go test -tags=integration ./...
golangci-lint run ./...
go build -o bin/server ./cmd/server
```

Frontend:

```powershell
cd frontend
pnpm install
pnpm run lint:check
pnpm run typecheck
pnpm run test:run
pnpm run build
```

Root:

```powershell
make build
make test
make test-backend
make test-frontend
```

On Windows without `make`, run the underlying commands directly.

## Testing Strategy For Future Changes

- Prefer narrow tests around touched files first.
- Backend service/handler changes usually already have adjacent `*_test.go`; use package-level focused `go test ./internal/service -run TestName`.
- Repository integration tests may require PostgreSQL/Redis/testcontainers; check the test tags and package setup before assuming they are cheap.
- Frontend component/view changes should run the closest Vitest spec and then `pnpm run typecheck` when TypeScript surface changes.
- For gateway streaming changes, include stream lifecycle/failover tests if touched code affects SSE, websocket, retries, billing, or account selection.

## Known Local/Repo Quirks

- Some Chinese text in this checkout appears mojibake in markdown and comments; avoid broad reformatting or encoding churn.
- `README_CN.md`, `DEV_GUIDE.md`, and some comments may render incorrectly depending on shell encoding. Use code structure over garbled prose when unsure.
- `go.mod` currently declares Go `1.26.4`; some older badges/docs mention earlier versions. Trust `backend/go.mod` for toolchain intent.
- Root `Makefile` references `datamanagement`, but this checkout may not contain that directory. Do not assume `build-datamanagementd` works without checking.
- `frontend/pnpm-lock.yaml` must stay in sync when dependencies change.
- Avoid hand-editing embedded frontend output under `backend/internal/web/dist`; edit `frontend/src` and rebuild instead.

## Minimal Mental Model

Think of the product as two coupled apps:

1. A Go API gateway and control plane that owns auth, settings, accounts, scheduling, billing, usage, payments, monitoring, and upstream AI protocol compatibility.
2. A Vue frontend that calls `/api/v1/*` management APIs and is embedded into the Go binary for production.

Most changes cross one vertical slice: route -> handler -> service -> repository/schema, plus frontend API -> store/composable -> view/component.

