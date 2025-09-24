FROM ruby:3.2-alpine

LABEL maintainer="Ignacio González Orellana"
LABEL description="Fudo Challenge API - Professional Ruby Rack Application"

WORKDIR /app

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    tzdata \
    curl \
    && rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copy Gemfile and Gemfile.lock
COPY Gemfile* ./

# Install gems
RUN bundle config set --local without 'development test' && \
    bundle install && \
    bundle clean --force

# Copy application code
COPY . .

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:9292/health || exit 1

# Expose port
EXPOSE 9292

# Set environment
ENV RACK_ENV=production
ENV PORT=9292

# Start the application
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "9292", "-E", "production"]
