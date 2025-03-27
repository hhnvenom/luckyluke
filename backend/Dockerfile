FROM golang:1.24.1-alpine AS builder

# Set necessary environment variables
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# Create and change to the app directory
WORKDIR /app

# Copy go.mod and go.sum files
COPY go.mod go.sum* ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN go build -o main ./cmd/api

# Use a Docker multi-stage build to create a lean production image
FROM alpine:3.21

# Add ca-certificates for secure connections
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary from builder
COPY --from=builder /app/main .

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
CMD ["./main"]
