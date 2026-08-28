package init

import (
	"context"
	"log"

	gcpsm "cloud.google.com/go/secretmanager/apiv1"
	expo_sm "github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/connections/secretmanager"
	"github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/observability"
)

// InitializeSecretManager establishes a connection to Google Cloud Secret Manager.
// It returns the client and a cleanup function to close it.
func InitializeSecretManager(ctx context.Context, telemetry *observability.Telemetry) (*gcpsm.Client, func()) {
	smClient, err := expo_sm.ConnectSecretManager(ctx, telemetry)
	if err != nil {
		log.Fatalf("Critical Error: Secret Manager unreachable: %v", err)
	}

	cleanup := func() {
		smClient.Close()
	}

	return smClient, cleanup
}
