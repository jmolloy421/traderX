# Use official PostgreSQL image
FROM postgres:16-alpine

# Set environment variables for PostgreSQL
ENV POSTGRES_USER=sa
ENV POSTGRES_PASSWORD=sa
ENV POSTGRES_DB=traderx

# Copy initialization script
COPY initialSchema.sql /docker-entrypoint-initdb.d/

# Expose PostgreSQL port
EXPOSE 5432
