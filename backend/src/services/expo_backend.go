package services

import (
	"context"
	"database/sql"
	"fmt"

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
	logger := s.telemetry.Logger("expo-backend")
	logger.Info(ctx, fmt.Sprintf("Received CreatePost request for author: %s", req.GetAuthorId()))

	// TODO: Implement database UPSERT logic using s.primaryDB
	return &pb.Post{
		Content: "This is a mock response from the server!",
	}, nil
}

// ReadPost retrieves a post by its ID.
func (s *ExpoBackendService) ReadPost(ctx context.Context, req *pb.ReadPostRequest) (*pb.Post, error) {
	logger := s.telemetry.Logger("expo-backend")
	logger.Info(ctx, fmt.Sprintf("Received ReadPost request for post: %s", req.GetPostId()))

	// TODO: Implement database SELECT logic using s.replicaDB
	return &pb.Post{
		PostId:  req.GetPostId(),
		Content: "This is a mock response from the server!",
	}, nil
}

// DeletePost performs a soft delete operation.
func (s *ExpoBackendService) DeletePost(ctx context.Context, req *pb.DeletePostRequest) (*emptypb.Empty, error) {
	logger := s.telemetry.Logger("expo-backend")
	logger.Info(ctx, fmt.Sprintf("Received DeletePost request for post: %s", req.GetPostId()))

	// TODO: Implement database soft delete logic using s.primaryDB
	return &emptypb.Empty{}, nil
}
