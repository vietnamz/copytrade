package httputils

import (
	"context"
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"
	"github.com/vietnamz/prime-generator/api/types"
	"github.com/vietnamz/prime-generator/errdefs"
	"io"
	"mime"
	"net/http"
	"strings"
)

type APIVersionKey struct{}

type APIFunc func(ctx context.Context, w http.ResponseWriter, r *http.Request, vars map[string]string) error


// MakeErrorHandler makes an HTTP handler that decodes a Error and
// returns it in the response.
func MakeErrorHandler( err error ) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		statusCode := errdefs.GetHTTPErrorStatusCode(err)
		response := &types.ErrorResponse{
			Message: err.Error(),
		}
		_ = WriteJSON(w, statusCode, response)
	}
}
// HijackConnection interrupts the http response writer to get the
// underlying connection and operate with it.
func HijackConnection(w http.ResponseWriter) (io.ReadCloser, io.Writer, error) {
	conn, _, err := w.(http.Hijacker).Hijack()
	if err != nil {
		return nil, nil, err
	}
	// Flush the options to make sure the client sets the raw mode
	_, _ = conn.Write([]byte{})
	return conn, conn, nil
}

// CloseStreams ensures that a list for http streams are properly closed.
func CloseStreams(streams ...interface{}) {
	for _, stream := range streams {
		if tcpc, ok := stream.(interface {
			CloseWrite() error
		}); ok {
			_ = tcpc.CloseWrite()
		} else if closer, ok := stream.(io.Closer); ok {
			_ = closer.Close()
		}
	}
}

// CheckForJSON makes sure that the request's Content-Type is application/json.
func CheckForJSON(r *http.Request) error {
	ct := r.Header.Get("Content-Type")

	// No Content-Type header is ok as long as there's no Body
	if ct == "" {
		if r.Body == nil || r.ContentLength == 0 {
			return nil
		}
	}

	// Otherwise it better be json
	if matchesContentType(ct, "application/json") {
		return nil
	}
	return errdefs.InvalidParameter(errors.Errorf("Content-Type specified (%s) must be 'application/json'", ct))
}

// ParseForm ensures the request form is parsed even with invalid content types.
// If we don't do this, POST method without Content-type (even with empty body) will fail.
func ParseForm(r *http.Request) error {
	if r == nil {
		return nil
	}
	if err := r.ParseForm(); err != nil && !strings.HasPrefix(err.Error(), "mime:") {
		return errdefs.InvalidParameter(err)
	}
	return nil
}

// VersionFromContext returns an API version from the context using APIVersionKey.
// It panics if the context value does not have version.Version type.
func VersionFromContext(ctx context.Context) string {
	if ctx == nil {
		return ""
	}

	if val := ctx.Value(APIVersionKey{}); val != nil {
		return val.(string)
	}

	return ""
}


// matchesContentType validates the content type against the expected one
func matchesContentType(contentType, expectedType string) bool {
	mimetype, _, err := mime.ParseMediaType(contentType)
	if err != nil {
		logrus.Errorf("Error parsing media type: %s error: %v", contentType, err)
	}
	return err == nil && mimetype == expectedType
}
