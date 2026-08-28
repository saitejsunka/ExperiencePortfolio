package checks

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/observability"
)

// ContinuousMonitorDatabaseConnection runs a background goroutine that pings the databases every minute.
// It logs the status of the connections for FAANG-level proactive observability.
func ContinuousMonitorDatabaseConnection(ctx context.Context, primaryDB, replicaDB *sql.DB, telemetry *observability.Telemetry) {
	logger := telemetry.Logger("expo-health-check")

	go func() {
		ticker := time.NewTicker(1 * time.Minute)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				logger.Info(ctx, "Stopping database monitor gracefully.")
				return
			case <-ticker.C:
				if err := primaryDB.Ping(); err != nil {
					logger.Error(ctx, fmt.Sprintf("CRITICAL: Primary database connection lost: %v", err))
				} else {
					logger.Info(ctx, "Primary database connection is perfectly healthy.")
				}

				if err := replicaDB.Ping(); err != nil {
					logger.Error(ctx, fmt.Sprintf("CRITICAL: Replica database connection lost: %v", err))
				} else {
					logger.Info(ctx, "Replica database connection is perfectly healthy.")
				}
			}
		}
	}()
}
