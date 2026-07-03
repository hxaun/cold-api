# Codex Project Entry

This repository already has a project map for future agents and maintainers.
Before making non-trivial changes, read:

- [docs/PROJECT_OVERVIEW_FOR_CODEX.md](docs/PROJECT_OVERVIEW_FOR_CODEX.md)

Quick defaults:

- Backend is Go/Gin/Ent/Wire under `backend/`.
- Frontend is Vue 3/Vite/Pinia/pnpm under `frontend/`.
- Generated backend files live in `backend/ent/` and `backend/cmd/server/wire_gen.go`; do not hand-edit generated output unless explicitly needed.
- Database migrations live in `backend/migrations/`; do not modify already-applied migrations. Add a new forward-only migration instead.
- Use `pnpm`, not `npm`, for frontend dependency work.
- Prefer focused tests near the touched module before running broad suites.

