package databases

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"cloud.google.com/go/cloudsqlconn"
	"cloud.google.com/go/cloudsqlconn/postgres/pgxv5"
	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/observability"

	// Import secretmanager client for accessing version request structures
	gcpsm "cloud.google.com/go/secretmanager/apiv1"
	"cloud.google.com/go/secretmanager/apiv1/secretmanagerpb"
)

// ReplicaConfig holds the required parameters to connect to the Replica database
type ReplicaConfig struct {
	ProjectID            string
	Region               string
	InstanceName         string // e.g., "expo-replica-read-us-west1"
	UserSecretName       string // e.g., "projects/123/secrets/expo-db-user/versions/latest"
	DBNameSecretName     string
	PasswordSecretName   string
	IPSecretName         string // e.g., "projects/.../secrets/expo-replica-read-db-us-west1-ip-address/versions/latest"
}

// ConnectReplicaRead builds a secure TLS tunnel to the Read Replica Cloud SQL database.
func ConnectReplicaRead(ctx context.Context, cfg ReplicaConfig, smClient *gcpsm.Client, telemetry *observability.Telemetry) (*sql.DB, error) {
	logger := telemetry.Logger("expo-connections")
	logger.Info(ctx, "Initializing secure connection to Read Replica Database")


	// Fetch Password
	passReq, err := smClient.AccessSecretVersion(ctx, &secretmanagerpb.AccessSecretVersionRequest{
		Name: cfg.PasswordSecretName,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to access password secret: %w", err)
	}
	dbPassword := string(passReq.Payload.Data)

	// Fetch DB Name
	dbNameReq, err := smClient.AccessSecretVersion(ctx, &secretmanagerpb.AccessSecretVersionRequest{
		Name: cfg.DBNameSecretName,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to access dbname secret: %w", err)
	}
	dbName := string(dbNameReq.Payload.Data)

	// Fetch DB User
	dbUserReq, err := smClient.AccessSecretVersion(ctx, &secretmanagerpb.AccessSecretVersionRequest{
		Name: cfg.UserSecretName,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to access dbuser secret: %w", err)
	}
	dbUser := string(dbUserReq.Payload.Data)

	// 2. Establish Secure Authorized Tunnel
	instanceConnectionName := fmt.Sprintf("%s:%s:%s", cfg.ProjectID, cfg.Region, cfg.InstanceName)
	
	cleanup, err := pgxv5.RegisterDriver("cloudsql-postgres-replica", 
		cloudsqlconn.WithDefaultDialOptions(cloudsqlconn.WithPrivateIP()),
	)
	if err != nil {
		return nil, fmt.Errorf("failed to register driver: %w", err)
	}
	_ = cleanup // Usually defer cleanup()

	// 3. Open the Connection Pool
	dsn := fmt.Sprintf("user=%s password=%s dbname=%s sslmode=disable", dbUser, dbPassword, dbName)
	
	start := time.Now()
	db, err := sql.Open("cloudsql-postgres-replica", instanceConnectionName+"?"+dsn)
	if err != nil {
		logger.Error(ctx, "Failed to open Replica database pool")
		return nil, fmt.Errorf("failed to open database pool: %w", err)
	}

	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping Replica database: %w", err)
	}

	duration := time.Since(start)
	logger.Info(ctx, fmt.Sprintf("Successfully established secure tunnel to Replica Database in %v", duration))

	return db, nil
}
