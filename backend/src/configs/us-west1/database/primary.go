package database

import db_connections "github.com/saitejsunka/ExperiencePortfolio/Portfolio/backend/src/connections/databases"

// GetPrimaryWriteUsWest1Config returns the connection configuration for the primary
// write database located in the us-west1 region.
func GetPrimaryWriteUsWest1Config(projectID string) db_connections.PrimaryConfig {
	return db_connections.PrimaryConfig{
		ProjectID:          projectID,
		Region:             "us-west1",
		InstanceName:       "expo-primary-write-us-west1",
		DBUser:             "postgres", // Default user, update if different
		DBNameSecretName:   fmtSecretName(projectID, "expo-db-name"),
		PasswordSecretName: fmtSecretName(projectID, "expo-db-password"),
		IPSecretName:       fmtSecretName(projectID, "expo-primary-write-db-us-west1-ip-address"),
	}
}

// fmtSecretName is a helper to format the Secret Manager URI
func fmtSecretName(projectID, secretID string) string {
	return "projects/" + projectID + "/secrets/" + secretID + "/versions/latest"
}
