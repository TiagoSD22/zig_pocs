# Use Ubuntu as base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV ZIG_VERSION=0.16.0-dev.3685+60c75fa2e

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    xz-utils \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and install Zig 0.16.0-dev
RUN curl -L "https://ziglang.org/builds/zig-linux-x86_64-${ZIG_VERSION}.tar.xz" -o zig.tar.xz \
    && tar -xf zig.tar.xz \
    && mv zig-linux-x86_64-${ZIG_VERSION} /usr/local/zig \
    && rm zig.tar.xz

# Add Zig to PATH
ENV PATH="/usr/local/zig:${PATH}"

# Set working directory
WORKDIR /app

# Copy project files
COPY build.zig build.zig.zon ./
COPY src/ ./src/

# Build the application
RUN zig build -Doptimize=ReleaseSafe

# Expose port
EXPOSE 8080

# Run the application
CMD ["./zig-out/bin/zig-rest-api"]