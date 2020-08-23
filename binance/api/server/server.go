package server

import (
	"context"
	"crypto/tls"
	"fmt"
	"github.com/gorilla/mux"
	"github.com/sirupsen/logrus"
	"github.com/vietnamz/prime-generator/api/server/httputils"
	"github.com/vietnamz/prime-generator/api/server/middleware"
	"github.com/vietnamz/prime-generator/api/server/router"
	"net"
	"net/http"
	"strings"
)

const versionMatcher = "/v{version:[0-9.]+}"


type Config struct {
	Logging bool
	CorsHeader string
	Version string
	TLSConfig   *tls.Config
}

type Server struct {
	cfg *Config
	servers []*HTTPSever
	routes []router.Router
	middlewares []middleware.Middleware
}

func New(cfg *Config) *Server  {
	return &Server{
		cfg: cfg,
	}
}
func (s *Server) Accept( addr string, listeners ...net.Listener) {
	for _, listener := range listeners {
		httpServer := &HTTPSever{
			srv: &http.Server{
				Addr: addr,
			},
			l:listener,
		}
		s.servers = append(s.servers, httpServer)
	}
}
func (s *Server) Close() {
	for _, srv := range s.servers {
		if err := srv.close(); err != nil {
			logrus.Error(err)
		}
	}
}

func (s *Server) ServeAPI() error {
	var chError = make(chan error, len(s.servers))
	for _, srv := range s.servers {
		srv.srv.Handler = s.createMux()
		go func(srv *HTTPSever) {
			var err error
			logrus.Infof("API Listen on %s", srv.l.Addr())
			if err = srv.Serve(); err != nil && strings.Contains( err.Error(), "use of closed network connetion") {
				err = nil
			}
			chError <- err
		}(srv)
	}
	for range s.servers {
		err := <-chError
		if err != nil {
			return err
		}
	}
	return nil
}

func (s *Server) makeHTTPHandler( handler httputils.APIFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := context.WithValue(r.Context(), "APP", r.Header.Get("User-Agent"))
		handlerFunc := s.handlerWithGlobalMiddlewares(handler)
		vars := mux.Vars(r)
		if vars == nil {
			vars = make (map[string]string)
		}
		if err := handlerFunc(ctx, w, r, vars); err != nil {
			fmt.Println(err)
		}
	}
}

type pageNotFoundError struct{}

func (pageNotFoundError) Error() string {
	return "page not found"
}

// UseMiddleware appends a new middleware to the request chain.
// This needs to be called before the API routes are configure.
func (s *Server) UseMiddleware(m middleware.Middleware ) {
	s.middlewares = append(s.middlewares, m)
}
func (pageNotFoundError) NotFound() {}

func (s *Server) createMux() *mux.Router  {
	m := mux.NewRouter()
	logrus.Infof("Registering routers")
	for _, apiRouter := range s.routes {
		for _, r := range apiRouter.Routers() {
			f := s.makeHTTPHandler(r.Handler())
			logrus.Infof("Registering %s, %s", r.Method(), r.Path())
			m.Path(versionMatcher + r.Path()).Methods( r.Method()).Handler(f).Queries()
			m.Path(r.Path()).Methods(r.Method()).Handler(f)
		}
	}
	notFoundHandler := httputils.MakeErrorHandler(pageNotFoundError{})
	m.HandleFunc(versionMatcher + "/{path:.*}", notFoundHandler)
	m.NotFoundHandler = notFoundHandler
	m.MethodNotAllowedHandler = notFoundHandler
	return m

}

// Wait blocks the server goroutine util it exits.
// It sends an error message if there is anay error during
// The API execution.
func (s *Server) Wait( waitChain chan error) {
	if err  := s.ServeAPI(); err != nil {
		logrus.Errorf("ServerAPI error: %v", err)
		waitChain <- err
	}
	waitChain <- nil
}
type HTTPSever struct {
	srv *http.Server
	l net.Listener
}

func (s *HTTPSever) Serve() error {
	return s.srv.Serve(s.l)
}

func (s *HTTPSever) close() error {
	return s.l.Close()
}

func ( s *Server) InitRouter( routers ...router.Router) {
	s.routes = append(s.routes, routers...)
}