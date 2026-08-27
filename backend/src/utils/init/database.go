package init

import (
	"context"
	"database/sql"
	"log"

	gcpsm "cloud.google.com/go/secretmanager/apiv1"
	"github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/configs/us-west1/database"
	db_connections "github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/connections/databases"
	"github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/observability"
)

// InitializeUsWest1Databases establishes connections to the primary and replica databases.
// It returns the primary DB, replica DB, and a cleanup function to close them.
func InitializeUsWest1Databases(ctx context.Context, projectID string, smClient *gcpsm.Client, telemetry *observability.Telemetry) (*sql.DB, *sql.DB, func()) {
	primaryCfg := database.GetPrimaryWriteUsWest1Config(projectID)
	replicaCfg := database.GetReplicaReadUsWest1Config(projectID)

	// Connect to Primary Database
	primaryDB, err := db_connections.ConnectPrimaryWrite(ctx, primaryCfg, smClient, telemetry)
	if err != nil {
		log.Fatalf("Critical Error: Primary Database unreachable: %v", err)
	}

	// Connect to Replica Database
	replicaDB, err := db_connections.ConnectReplicaRead(ctx, replicaCfg, smClient, telemetry)
	if err != nil {
		// Attempt to close primary if replica fails
		primaryDB.Close()
		log.Fatalf("Critical Error: Replica Database unreachable: %v", err)
	}

	cleanup := func() {
		primaryDB.Close()
		replicaDB.Close()
	}

	return primaryDB, replicaDB, cleanup
}
