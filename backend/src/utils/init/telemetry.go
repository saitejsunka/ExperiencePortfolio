package init

import (
	"context"
	"log"

	"github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/observability"
)

// InitializeTelemetryAndLogging sets up the telemetry and returns the telemetry object
// along with a cleanup function to be deferred in main.
func InitializeTelemetryAndLogging(ctx context.Context, projectID string) (*observability.Telemetry, func()) {
	telemetry, err := observability.InitTelemetry(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to initialize telemetry: %v", err)
	}

	cleanup := func() {
		telemetry.LogSync() // Ensure logs are flushed before exit
	}

	return telemetry, cleanup
}
