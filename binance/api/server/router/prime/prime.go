package prime

import (
	"github.com/vietnamz/prime-generator/api/server/router"
	"github.com/vietnamz/prime-generator/daemon"
)

// prime route is used to sampling the prime number.

type primeRoute struct {
	routes []router.Route
	D *daemon.Daemon
}

func (r primeRoute) Routers() []router.Route {
	return r.routes
}

func NewRouter( daemon *daemon.Daemon) router.Router {
	r := &primeRoute{
		D : daemon,
	}
	r.routes = []router.Route {
		router.NewGetRoute("/prime", r.primeHandler),
	}
	return r
}