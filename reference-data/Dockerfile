FROM --platform=$BUILDPLATFORM node:23 AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
RUN npm install @nestjs/cli

COPY . .
RUN npm run build

FROM alpine:3.21
RUN apk add --no-cache nodejs
WORKDIR /usr/src/app
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/tracing.js ./tracing.js
COPY . .
EXPOSE 18085

# Configure OTEL via environment variables
ENV OTEL_SERVICE_NAME=reference-data
ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317

CMD [ "node", "--require", "./tracing.js", "dist/main"]
