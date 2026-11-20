# Geri-soft Helper

Shared backend and reusable solutions for geri-soft.com projects.

**Version**: 0.1.0  
**Status**: Initial scaffold; authentication and data APIs are not implemented yet.

## Purpose

Helper is the canonical home for small, reusable solutions that can serve multiple projects, including the shared Cloudflare backend, database access, user management, and frontend components or patterns.

## Current Scaffold

- Cloudflare Worker entry point using Hono and TypeScript
- Initial D1 schema and migration
- Vitest Worker-pool configuration with a health endpoint smoke test
- Shared client type definitions in `client/gs-db.ts`
- Local and remote migration scripts

The authentication routes, item CRUD API, CORS policy, complete client, offline fallback, and import helper remain to be implemented. Do not use this scaffold as a production data service yet.

## Technology

- Cloudflare Workers and D1
- Hono and TypeScript
- Wrangler
- Vitest with `@cloudflare/vitest-pool-workers`
- Zod for request validation when the API is implemented

## Setup

Install the dependencies:

```powershell
npm install
```

Create a D1 database in the Cloudflare account and replace the placeholder `database_id` in `worker/wrangler.toml` with its ID. Apply the local migration and start the Worker:

```powershell
npm run db:migrate:local
npm run dev
```

The current smoke endpoint is `http://localhost:8787/health`.

Run checks with:

```powershell
npm test
npm run typecheck
```

## Database and Deployment

Apply migrations to the configured remote D1 database with `npm run db:migrate:remote`. Deploy the Worker with `npm run deploy` after configuring the production database and route. The intended production hostname is `api.geri-soft.com`; add it as a Worker custom domain in Cloudflare when the production API is ready.

Never store secrets in this repository. Use `.dev.vars` for local secrets and `wrangler secret put JWT_SECRET` for deployed environments. `.dev.vars` is ignored by Git.

Check the current [D1 limits](https://developers.cloudflare.com/d1/platform/limits/) and [Workers limits](https://developers.cloudflare.com/workers/platform/limits/) before making quota-dependent design decisions.

## Project Structure

```text
client/                 Shared client module and types
worker/
  migrations/            D1 SQL migrations
  src/                   Worker source
  test/                  Worker tests
  wrangler.toml          Worker and D1 configuration
```

## License

MIT. See [LICENSE](LICENSE).

## Feedback & Support

- Email: [info@geri-soft.com](mailto:info@geri-soft.com)
- Support: [Revolut](https://revolut.me/kgergo1713)

## Changelog

### 0.1.0

#### New Feature

- Added the initial Worker, D1 schema, client type definitions, and test scaffold.