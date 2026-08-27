package main

import (
	"context"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"

	appinit "github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/utils/init"
	"github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/observability"
	"github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/services"
	pb "github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/stubs"
	"google.golang.org/grpc"
)

func main() {
	// Initialize a root context with a sample Request ID (usually injected by HTTP/gRPC middleware)
	ctx := context.WithValue(context.Background(), observability.RequestIDKey, "REQ-BOOTSTRAP-001")

	// 1. Get Project ID
	projectID := os.Getenv("GOOGLE_CLOUD_PROJECT")
	if projectID == "" {
		projectID = "experienceportfolio" // Fallback, normally injected by environment
	}

	// 2. Initialize Observability Layer
	telemetry, telemetryCleanup := appinit.InitializeTelemetryAndLogging(ctx, projectID)
	defer telemetryCleanup()

	// 3. Initialize Secret Manager
	smClient, smCleanup := appinit.InitializeSecretManager(ctx, telemetry)
	defer smCleanup()

	// 4. Initialize Database Connections
	primaryDB, replicaDB, dbCleanup := appinit.InitializeUsWest1Databases(ctx, projectID, smClient, telemetry)
	defer dbCleanup()

	// 5. Initialize Services
	expoService := services.NewExpoBackendService(primaryDB, replicaDB, telemetry)

	// 6. Setup gRPC Server
	lis, err := net.Listen("tcp", ":5080")
	if err != nil {
		log.Fatalf("Failed to listen on port 5080: %v", err)
	}

	grpcServer := grpc.NewServer()
	pb.RegisterExpoBackendServiceServer(grpcServer, expoService)

	logger := telemetry.Logger("expo-backend")
	
	// Start the server in a separate goroutine so we can gracefully shutdown
	go func() {
		logger.Info(ctx, "Starting gRPC server on :5080...")
		if err := grpcServer.Serve(lis); err != nil {
			log.Fatalf("Failed to serve gRPC: %v", err)
		}
	}()

	// 7. Wait for OS interrupt to gracefully shutdown
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
	<-stop

	logger.Info(ctx, "Shutting down gRPC server gracefully...")
	grpcServer.GracefulStop()
	logger.Info(ctx, "Server exited.")
}
