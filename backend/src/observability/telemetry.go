package observability

import (
	"context"
	"fmt"
	"log"

	"cloud.google.com/go/logging"
	monitoring "cloud.google.com/go/monitoring/apiv3/v2"
	"google.golang.org/api/option"
)

// contextKey is a custom type to prevent context collisions.
type contextKey string

const RequestIDKey contextKey = "request_id"

// Telemetry holds the base clients for GCP Cloud Logging and Cloud Monitoring.
type Telemetry struct {
	client  *logging.Client
	LogSync func() error
	Metrics *monitoring.MetricClient
}

// ComponentLogger is a structured wrapper that auto-injects Request IDs into logs.
type ComponentLogger struct {
	logger *logging.Logger
}

// InitTelemetry initializes and returns the GCP Telemetry clients.
func InitTelemetry(ctx context.Context, projectID string) (*Telemetry, error) {
	logClient, err := logging.NewClient(ctx, projectID)
	if err != nil {
		return nil, fmt.Errorf("failed to create logging client: %w", err)
	}

	// Initialize Cloud Monitoring
	metricClient, err := monitoring.NewMetricClient(ctx, option.WithTelemetryDisabled()) // Telemetry disabled prevents recursive trace tracking in the client itself
	if err != nil {
		logClient.Close()
		return nil, fmt.Errorf("failed to create metric client: %w", err)
	}

	log.Println("Successfully initialized GCP Observability (Logging & Monitoring)")

	return &Telemetry{
		client:  logClient,
		LogSync: logClient.Close, // Call this on application exit to flush logs
		Metrics: metricClient,
	}, nil
}

// Logger returns a new ComponentLogger scoped to a specific component (e.g. "expo-connections").
func (t *Telemetry) Logger(name string) *ComponentLogger {
	return &ComponentLogger{
		logger: t.client.Logger(name),
	}
}

// extractRequestID pulls the Request ID from context, or returns "NO-REQ-ID" if missing.
func extractRequestID(ctx context.Context) string {
	if reqID, ok := ctx.Value(RequestIDKey).(string); ok && reqID != "" {
		return reqID
	}
	return "NO-REQ-ID"
}

// Info logs an informational message prepended with the Request ID.
func (l *ComponentLogger) Info(ctx context.Context, msg string) {
	reqID := extractRequestID(ctx)
	payload := fmt.Sprintf("%s: %s", reqID, msg)
	l.logger.Log(logging.Entry{Severity: logging.Info, Payload: payload})
}

// Error logs an error message prepended with the Request ID.
func (l *ComponentLogger) Error(ctx context.Context, msg string) {
	reqID := extractRequestID(ctx)
	payload := fmt.Sprintf("%s: %s", reqID, msg)
	l.logger.Log(logging.Entry{Severity: logging.Error, Payload: payload})
}
