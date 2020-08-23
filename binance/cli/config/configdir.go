package config // import "github.com/docker/docker/cli/config"

import (
	"github.com/opencontainers/runc/libcontainer/user"
	"os"
	"path/filepath"
)

var (
	configDir     = os.Getenv("PRIME_CONFIG")
	configFileDir = ".prime"
)

// Key returns the env var name for the user's home dir based on
// the platform being run on
func Key() string {
	return "HOME"
}

// Get returns the home directory of the current user with the help of
// environment variables depending on the target operating system.
// Returned path should be used with "path/filepath" to form new paths.
func Get() string {
	home := os.Getenv(Key())
	if home == "" {
		if u, err := user.CurrentUser(); err == nil {
			return u.Home
		}
	}
	return home
}

// Dir returns the path to the configuration directory as specified by the PRIME_CONFIG environment variable.
// If PRIME_CONFIG is unset, Dir returns ~/.prime .
func Dir() string {
	return configDir
}

func init() {
	if configDir == "" {
		configDir = filepath.Join(Get(), configFileDir)
	}
}
