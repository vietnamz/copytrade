package daemon

import (
	"github.com/vietnamz/prime-generator/daemon/config"
)

// Daemon is entry to keep all the backend services to serve the API.
type Daemon struct {
	 PrimeSrv *PrimeService
	 config *config.Config
}

// Constructor.
func NewDaemon(cfg *config.Config) *Daemon {
	return &Daemon{
		config: cfg,
	}
}

// initialize all the backend services.
// Support:
//			+ Prime Generator service: to return a sample prime number.
func (d *Daemon) Init() error{
	d.PrimeSrv = newPrimeService(d.config)
	return nil
}