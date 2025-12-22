# Goravel Backend Dockerfile
FROM golang:1.23-alpine

# Install dependencies
RUN apk add --no-cache git make gcc musl-dev

# Set working directory
WORKDIR /app

# Copy go mod file first
COPY go.mod ./

# Copy source code
COPY . .

# Download and tidy dependencies
RUN go mod tidy

# Build the application
RUN go build -o main .

# Expose port
EXPOSE 8000

# Run the application
CMD ["./main"]
