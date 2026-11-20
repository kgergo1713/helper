# Task: Shared Backend (Cloudflare Worker + D1) for geri-soft.com Projects

## Context
- `geri-soft.com` is my private website. The domain and several services run on Cloudflare, including a Cloudflare Tunnel for home services.
- More projects need a database and/or backend. Until now, project data has been stored in the frontend on each user's device (for example, in localStorage).
- Goal: **one shared, free backend** that every project accesses through a small shared client module (`gs-db.js`).
- The data volume is small: a user list and one or two data collections per project. No special performance requirements.

## Decisions (already made; do not revisit)
- Platform: **Cloudflare Workers (free) + D1** (SQLite). Keep services within one Cloudflare account rather than using an external provider.
- Worker framework: **Hono**; language: **TypeScript**; deployment: **Wrangler**.
- One Worker and one D1 database, reachable at `api.geri-soft.com`.
- Separate projects using a `project` field in shared tables, not separate databases.
- Shared authentication: one `users` table and JWTs used by every project.

## Initial Data Model (can be refined)
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  pass_hash TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- One user can belong to multiple projects, with a separate role in each.
CREATE TABLE memberships (
  user_id TEXT NOT NULL REFERENCES users(id),
  project TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user',
  PRIMARY KEY (user_id, project)
);

-- General-purpose storage: exactly one row per item, not an array in one field.
CREATE TABLE items (
  id TEXT PRIMARY KEY,
  project TEXT NOT NULL,
  collection TEXT NOT NULL,
  user_id TEXT NOT NULL REFERENCES users(id),
  data TEXT NOT NULL,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX idx_items_lookup ON items(project, collection, user_id);
```

Store one item per row rather than packing an array into a single field. SQLite has no array type; updating a packed array rewrites the whole value, can lose concurrent edits from another device, and prevents efficient filtering. If a project later needs a strict schema, add a project-specific table and support it alongside the shared helper.

## Expected Deliverables
1. **Repository structure**: `worker/` (Hono app, `wrangler.toml`, D1 migrations in `migrations/`), `client/gs-db.js` (or `.ts`), and `README.md`.
2. **Migration** for the schema above, managed with `wrangler d1 migrations`.
3. **Worker API**:
   - `POST /auth/register`, `POST /auth/login` (password hashing with Web Crypto, such as PBKDF2 or a Workers-compatible scrypt-like solution; **do not** use Node-only native modules), JWT issuance and verification middleware.
   - `GET/POST/PUT/DELETE /p/:project/:collection[/:id]` for the `items` table. Verify the token and membership in the requested project on every request; by default, return only rows belonging to the caller's `user_id`.
   - A consistent error format, input validation (for example, Zod), and CORS restricted to allowed `*.geri-soft.com` origins.
4. **Client module** (`gs-db`): login/logout and token storage; an API such as `db.project('name').collection('collection').list()`, `.get(id)`, `.create(data)`, `.update(id, data)`, and `.remove(id)`. Include error handling, a simple localStorage offline fallback, and a one-time import function for existing local data.
5. **README**: local development (`wrangler dev`), D1 creation, applying migrations, deployment, configuring the `api.geri-soft.com` custom domain, and managing secrets such as `JWT_SECRET` with `wrangler secret`.
6. Basic tests (for example, Vitest with Miniflare or `@cloudflare/vitest-pool-workers`) for auth and `items` CRUD, including denial of access to another project or user's data.

## Constraints
- Stay on the free Workers/D1 plans. D1 has daily read/write row limits that Cloudflare began enforcing on **September 1, 2026**; when exceeded, queries fail until the next UTC midnight. Avoid unnecessary full-table reads, use indexes, and handle limit errors gracefully in the client.
- Before relying on specific quota numbers, **verify the current Cloudflare D1 and Workers limit documentation**, because limits can change.
- Never commit secrets such as JWT secrets or tokens. Use `wrangler secret` and gitignored `.dev.vars` only.
- Avoid heavy dependencies; keep the package small, clear, and maintainable.

## Workflow
- First show a short plan (file list and API outline), and begin coding only after approval.
- Work in small steps: schema and migration, auth, items CRUD, client module, tests, and README.
- If anything is uncertain (for example, password hashing or CORS rules), ask instead of guessing.
- Keep documentation, code, identifiers, and commit messages in English. User communication remains Hungarian.
