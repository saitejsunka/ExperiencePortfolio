package enact

import (
	"context"
	"database/sql"

	"github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/enact/apis"
	"github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/observability"
	pb "github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/stubs"
	"google.golang.org/protobuf/types/known/emptypb"
)

// ExpoBackendService implements the gRPC service interface.
type ExpoBackendService struct {
	pb.UnimplementedExpoBackendServiceServer
	primaryDB *sql.DB
	replicaDB *sql.DB
	telemetry *observability.Telemetry
}

// NewExpoBackendService creates a new instance of the service.
func NewExpoBackendService(primaryDB, replicaDB *sql.DB, telemetry *observability.Telemetry) *ExpoBackendService {
	return &ExpoBackendService{
		primaryDB: primaryDB,
		replicaDB: replicaDB,
		telemetry: telemetry,
	}
}

// CreatePost performs an UPSERT operation.
func (s *ExpoBackendService) CreatePost(ctx context.Context, req *pb.CreatePostRequest) (*pb.Post, error) {
	return apis.CreatePostAPI(ctx, req, s.primaryDB, s.telemetry)
}

// ReadPost retrieves a post by its ID.
func (s *ExpoBackendService) ReadPost(ctx context.Context, req *pb.ReadPostRequest) (*pb.Post, error) {
	return apis.ReadPostAPI(ctx, req, s.replicaDB, s.telemetry)
}

// DeletePost performs a soft delete operation.
func (s *ExpoBackendService) DeletePost(ctx context.Context, req *pb.DeletePostRequest) (*emptypb.Empty, error) {
	return apis.DeletePostAPI(ctx, req, s.primaryDB, s.telemetry)
}
