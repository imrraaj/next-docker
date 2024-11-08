ARG NODE_VERSION=22
FROM alpine:3.19 as base

# Next.js app lives here
WORKDIR /app

# Set production environment
ENV NODE_ENV="production"


# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build node modules
RUN apk -U add build-base gyp pkgconfig python3 nodejs npm

# Install node modules
COPY --link package-lock.json package.json ./
RUN npm ci --include=dev

# Copy application code
COPY --link . .

# Build application
RUN npm run build

# Remove development dependencies
RUN npm prune --omit=dev


FROM base AS run

RUN apk add nodejs

# Copy built app
COPY --from=build /app/.next/standalone /app
COPY --from=build /app/.next/static /app/.next/static

EXPOSE 3000
# Run the app
CMD [ "node", "server.js" ]
