package system

import "github.com/vietnamz/prime-generator/api/server/router"
// System route is used to monitor the health of the api.
type systemRouter struct {
	routes []router.Route
}

func (r systemRouter) Routers() []router.Route {
	return r.routes
}

func NewRouter() router.Router {
	r := &systemRouter{}
	r.routes = []router.Route {
		router.NewGetRoute("/ping", r.pingHandler),
	}
	return r
}




