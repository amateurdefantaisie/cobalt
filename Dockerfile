FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app

RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --prod --frozen-lockfile

RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

FROM base AS api
WORKDIR /app

COPY --from=build --chown=node:node /prod/api /app

# The runtime performs a Git-root lookup. Render's Docker build context does not
# include .git, so initialize a minimal repository in the final image.
RUN apk add --no-cache git \
    && git init /app \
    && git -c user.name="Render Build" -c user.email="render-build@localhost" commit --allow-empty -m "Initialize runtime metadata" \
    && git remote add origin https://github.com/imputnet/cobalt.git \
    && chown -R node:node /app/.git

USER node

EXPOSE 9000
CMD [ "node", "src/cobalt" ]
