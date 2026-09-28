FROM node:22-alpine AS builder

WORKDIR /app

# Copy workspace config and lockfile first for efficient layer caching
COPY package.json pnpm-workspace.yaml tsconfig.json pnpm-lock.yaml ./

# Copy package.json files for all workspace members
COPY apps/api/package.json apps/api/
COPY apps/web/package.json apps/web/
COPY packages/shared/package.json packages/shared/

# Install dependencies
RUN corepack enable pnpm && pnpm install --frozen-lockfile

# Copy source code
COPY apps/api/src apps/api/src
COPY apps/web/src apps/web/src

# Build both apps
RUN pnpm --filter @job-tracker/api run build && \
    pnpm --filter @job-tracker/web run build

# ---- Production stage ----
FROM node:22-alpine AS production

WORKDIR /app

ENV NODE_ENV=production

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy built artifacts from builder
COPY --from=builder /app/apps/api/dist apps/api/dist
COPY --from=builder /app/apps/web/dist apps/web/dist

# Copy package.json for production dependency resolution
COPY --from=builder /app/apps/api/package.json apps/api/
COPY --from=builder /app/apps/web/package.json apps/web/

# Install only production dependencies
RUN pnpm install --frozen-lockfile --prod && \
    pnpm prune --prod

USER appuser

EXPOSE 3100

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3100/api/health || exit 1

CMD ["node", "apps/api/dist/server.js"]
