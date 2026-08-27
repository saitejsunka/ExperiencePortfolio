package secretmanager

import (
	"context"
	"fmt"

	gcpsm "cloud.google.com/go/secretmanager/apiv1"
	"github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/observability"
)

// ConnectSecretManager establishes an authorized connection to Google Cloud Secret Manager.
// Remember to defer client.Close() in the caller when you are done.
func ConnectSecretManager(ctx context.Context, telemetry *observability.Telemetry) (*gcpsm.Client, error) {
	logger := telemetry.Logger("expo-connections")
	logger.Info(ctx, "Initializing secure connection to Secret Manager")

	smClient, err := gcpsm.NewClient(ctx)
	if err != nil {
		logger.Error(ctx, "Failed to create Secret Manager client")
		return nil, fmt.Errorf("failed to create Secret Manager client: %w", err)
	}

	logger.Info(ctx, "Successfully connected to Secret Manager")
	return smClient, nil
}
