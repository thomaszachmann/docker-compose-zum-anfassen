# syntax=docker/dockerfile:1
# check=error=true
# notes-web – Endstand aus „Dockerfiles zum Anfassen", Node 26
# in Produktion: @sha256:… pinnen
FROM node:26-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
# .npmrc (mit Registry-Token) nur für diesen RUN – optional, fehlt es, entfällt der Mount
RUN --mount=type=cache,target=/root/.npm \
    --mount=type=secret,id=npmrc,target=/root/.npmrc \
    npm ci
COPY . .
RUN npm run build

FROM node:26-alpine AS prod
ENV NODE_ENV=production
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    --mount=type=secret,id=npmrc,target=/root/.npmrc \
    npm ci --omit=dev
COPY server.js ./
COPY --chown=node:node public/ ./public/
COPY --from=build /app/dist/ ./dist/
USER node
EXPOSE 3000
CMD ["node", "server.js"]
