package database

import db_connections "github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/connections/databases"

// GetReplicaReadUsWest1Config returns the connection configuration for the read
// replica database located in the us-west1 region.
func GetReplicaReadUsWest1Config(projectID string) db_connections.ReplicaConfig {
	return db_connections.ReplicaConfig{
		ProjectID:          projectID,
		Region:             "us-west1",
		InstanceName:       "expo-replica-read-us-west1",
		UserSecretName:     fmtSecretName(projectID, "expo-db-user"), 
		DBNameSecretName:   fmtSecretName(projectID, "expo-db-name"),
		PasswordSecretName: fmtSecretName(projectID, "expo-db-password"),
		IPSecretName:       fmtSecretName(projectID, "expo-replica-read-db-us-west1-ip-address"),
	}
}
