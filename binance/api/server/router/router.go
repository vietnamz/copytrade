package router

import "github.com/vietnamz/prime-generator/api/server/httputils"

// Router defines an interfaces to specify a group of routes to add to the server
type Router interface {
	// Routes returns the list of routes to add to the server
	Routers() []Route
}

// Route defines an individual API route in the server
type Route interface {
	// Handler returns the raw function to create the http handler.
	Handler() httputils.APIFunc
	// Method returns the http method the the route responds to.
	Method() string
	// Path returns the subpath where the route responds to.
	Path() string
}