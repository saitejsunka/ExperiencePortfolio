#!/bin/bash
# Script to generate gRPC stubs from the protobuf contracts

set -e

# 1. Check for core 'protoc' compiler
if ! command -v protoc &> /dev/null; then
    echo "❌ Error: 'protoc' is not installed."
    echo "Please install it first (e.g., 'brew install protobuf' on macOS, or 'sudo apt install protobuf-compiler' on Linux)."
    exit 1
fi

# 2. Check and install Go Protobuf plugins if missing
if ! command -v protoc-gen-go &> /dev/null; then
    echo "⏳ 'protoc-gen-go' not found. Installing..."
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
fi

if ! command -v protoc-gen-go-grpc &> /dev/null; then
    echo "⏳ 'protoc-gen-go-grpc' not found. Installing..."
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
fi

# Ensure the Go bin directory is in the PATH so protoc can find the newly installed plugins
export PATH="$PATH:$(go env GOPATH)/bin"

# 3. Create the stubs directory if it doesn't exist
mkdir -p stubs

# 4. Run the Protobuf Compiler
echo "🚀 Generating gRPC Stubs..."
protoc -I=contracts \
  --go_out=stubs --go_opt=paths=source_relative \
  --go-grpc_out=stubs --go-grpc_opt=paths=source_relative \
  contracts/expo_backend.proto

echo "✅ gRPC Stubs generated successfully in the 'stubs' directory!"

# 5. Initialize the stubs directory as a standalone Go module
echo "📦 Initializing stubs as a Go module..."
cd stubs
if [ ! -f go.mod ]; then
    go mod init github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/stubs
fi
go mod tidy
cd ..

echo "🎉 All done!"
