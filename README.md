# Job Tracker

A self-hosted job application tracker built with React + Vite (frontend), Fastify (backend), and PostgreSQL. Single-user application designed for personal job search management with a Kanban-style pipeline view.

## Project Description

Job Tracker consolidates all job applications into one place with a clear pipeline: **Wishlist → Applied → Interview → Offer → Rejected**. It provides a Kanban board, table view, search/filter, overdue tracking, CSV export, and full CRUD operations — all running in Docker containers on your own server.

No login required (access is restricted via Tailscale). No CDN dependencies. Lightweight and designed for resource-constrained servers.

## Setup Instructions

### Prerequisites

- Docker and Docker Compose installed
- pnpm (version 9+)
- Node.js 22+

### Local Development

```bash
# Install dependencies
pnpm install

# Run frontend dev server
pnpm dev

# Run backend dev server (separate terminal)
pnpm dev:api

# Run database migrations
pnpm db:migrate
```

### Production Setup

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```
2. Edit `.env` and set a strong `POSTGRES_PASSWORD`.
3. The `DATABASE_URL` will be constructed automatically from `POSTGRES_PASSWORD`.

## How to Run with Docker Compose

```bash
# Build and start all services
docker compose up -d --build

# Check status
docker compose ps

# View logs
docker compose logs -f app
docker compose logs -f db

# Stop services
docker compose down
```

The application is available at `http://localhost:3100`. PostgreSQL is **not** exposed to the host — it is only accessible via the internal Docker network.

## Backup Instructions

### Database Backup

```bash
# Create a timestamped backup
docker exec job-tracker-db \
  pg_dump -U jobtracker jobtracker \
  > backups/jobtracker_$(date +%Y%m%d_%H%M%S).sql
```

### CSV Export

Users can also export all application data from the UI via **Export CSV**, providing a human-readable backup in spreadsheet format.

Regular database backups are the primary backup method. Schedule periodic `pg_dump` runs via cron for production use.

## Restore Instructions

```bash
# Restore from a backup file
cat backups/jobtracker_backup.sql | \
docker exec -i job-tracker-db \
psql -U jobtracker -d jobtracker
```

**Important:** Ensure the `job-tracker-db` container is running before restoring. The database must exist before importing. After restore, restart the app container:

```bash
docker compose restart app
```

## Architecture Overview

```
                   Tailscale
                       │
                       ▼
                 Port 3100
                       │
                       ▼
             ┌─────────────────┐
             │   job-tracker   │
             │                 │
             │ React/Vite      │
             │ Fastify API     │
             │ Drizzle ORM     │
             └────────┬────────┘
                      │
                Docker Network
                      │
                      ▼
             ┌─────────────────┐
             │ job-tracker-db  │
             │   PostgreSQL    │
             └────────┬────────┘
                      │
                      ▼
                Docker Volume
                (postgres_data)
```

- **Frontend** (`apps/web`): React + Vite + TypeScript + Tailwind CSS + shadcn/ui + dnd-kit
- **Backend** (`apps/api`): Node.js + Fastify + Drizzle ORM + Zod validation
- **Shared** (`packages/shared`): Shared TypeScript types and schemas
- **Database**: PostgreSQL 18-alpine with persistent Docker volume
- **Access**: Restricted to Tailnet (no public internet exposure)

## Available Scripts

| Script | Description |
|--------|-------------|
| `pnpm build` | Build all packages and apps |
| `pnpm dev` | Start frontend dev server |
| `pnpm dev:api` | Start backend dev server |
| `pnpm test` | Run all tests |
| `pnpm db:migrate` | Run Drizzle migrations |
| `pnpm db:push` | Push schema to database |
| `pnpm db:studio` | Open Drizzle Studio |
| `pnpm lint` | Lint all packages |
| `pnpm clean` | Clean build artifacts and dependencies |
| `docker compose up -d` | Start all Docker services |
| `docker compose down` | Stop all Docker services |
| `docker compose logs -f app` | Stream app container logs |

## Docker Configuration

| Container | Image | Port | Memory | Restart |
|-----------|-------|------|--------|---------|
| `job-tracker` | Built from Dockerfile | 3100:3100 | 256MB | unless-stopped |
| `job-tracker-db` | postgres:18-alpine | Internal only | 384MB | unless-stopped |

- PostgreSQL port 5432 is **not published** to the host
- Application port **3100** is the only exposed port
- Existing services (Portainer on 8000/9443, 9router on 20128) are **not disturbed**

## Project Structure

```
job-tracker/
├── apps/
│   ├── api/          # Fastify backend
│   └── web/          # React frontend
├── packages/
│   └── shared/       # Shared TypeScript types & schemas
├── Dockerfile
├── docker-compose.yml
├── package.json
├── pnpm-workspace.yaml
├── tsconfig.json
├── .env.example
├── .gitignore
└── README.md
```
