FROM node:22-alpine
WORKDIR /trade-feed
COPY package*.json ./
RUN npm install --only=production
COPY . .
EXPOSE 18086

# Configure OTEL via environment variables
ENV OTEL_SERVICE_NAME=trade-feed
ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317

CMD [ "node", "--require", "./tracing.js", "index.js" ]
