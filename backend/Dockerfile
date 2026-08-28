# Trigger backend CI/CD pipeline
# ---------------------------------------------------------
# Stage 1: Build the Go binary
# ---------------------------------------------------------
FROM golang:1.27-alpine AS builder

WORKDIR /app

RUN apk update && apk add --no-cache git ca-certificates tzdata

# Copy the stubs directory
COPY stubs/ ./stubs/
# Copy the src directory
COPY src/ ./src/

# Set working directory to where the main go.mod is
WORKDIR /app/src

# Download all dependencies
RUN go mod download

# Build the Go app statically
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o expo_backend .

# ---------------------------------------------------------
# Stage 2: Build a small, secure runtime image
# ---------------------------------------------------------
FROM alpine:latest

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

WORKDIR /root/

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /app/src/expo_backend .

# Expose the gRPC port
EXPOSE 5080

# Command to run the executable
ENTRYPOINT ["./expo_backend"]
