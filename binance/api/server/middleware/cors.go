package middleware

import (
	"context"
	"github.com/sirupsen/logrus"
	"net/http"
)

// CORSMiddlware injects CORS headers to each request
// when it's configured.
type CORSMiddleware struct {
	defaultHeaders string
}
// NewCORSMiddleware creates a new NewCORSMiddleware with default headers.
func NewCORSMiddleware(d string) CORSMiddleware {
	return CORSMiddleware{defaultHeaders:  d}
}

// WrapHandler returns a new handler function wrapping the previous one in the request chain.
func (c CORSMiddleware) WrapHandler( handler func(ctx context.Context, w http.ResponseWriter, r *http.Request, vars map[string]string) error) func(ctx context.Context, w http.ResponseWriter, r *http.Request, vars map[string]string) error {
	return func (ctx context.Context, w http.ResponseWriter, r *http.Request, vars map[string]string) error{
		// if "api-cors-headers' is no given, but "api-enable-cors" is true, we set crs to "*"
		// otherwise, all head values will be passed to HTTP handler.
		corsHeader := c.defaultHeaders
		if corsHeader == "" {
			corsHeader = "*"
		}
		logrus.Debugf("CORS header is enabled and set to: %s", corsHeader)
		w.Header().Add("Access-Control-Allow-Origin", corsHeader)
		w.Header().Add("Access-Control-Allow-Headers", "Origin, X-Request-With, Content-Type, Accept, X-Registry-Auth")
		w.Header().Add("Access-Control-Allow-Methods", "HEAD, GET, POST, DELETE, PUT, OPTIONS")
		return handler(ctx, w, r, vars)
	}
}