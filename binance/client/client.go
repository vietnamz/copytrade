package client

import (
	"context"
	"errors"
	"fmt"
	"github.com/docker/go-connections/sockets"
	"github.com/vietnamz/prime-generator/api"
	"github.com/vietnamz/prime-generator/api/types"
	"github.com/vietnamz/prime-generator/api/types/versions"
	"net/http"
	"net/url"
	"path"
	"strings"
)

var DefaultDockerHost = "localhost"
var defaultProto = "tcp"
var defaultAddr = "localhost"

// ErrRedirect is the error returned by checkRedirect when the request is non-GET.
var ErrRedirect = errors.New("unexpected redirect in response")

type Client struct {
	 // scheme sets the scheme for the client
	scheme string
	// host holds the server address to connect to.
	host string
	// proto holds the client protocols.
	proto string
	// addr holds the client address.
	addr string
	// basePath holds the path to prepend to the requests.
	basePath string
	// client used to send and recieve the http requests.
	client *http.Client
	// version of the server to talk to.
	version string
	// custom http headers configured by users.
	customHTTPHeaders map[string]string
	// manualOverride is set to true when the version is set by users.
	manualOverride bool
	// negotiateVersion indicates if client should automatically negotiate
	// the API version to use when making requests. API version negotiation is
	// performed on the first request. after which negotiated is set to "true"
	// so that subsequent requests do not re-negotiate.
	negotiateVersion bool

	// negotiated indicates that API version negotiation took place.
	negotiated bool
}

// CheckRedirect specifies the policy for dealing with redirect responses:
// If the request is non-GET return `ErrRedirect`. Otherwise use the last response.
//
// Go 1.8 changes behavior for HTTP redirects (specifically 301, 307, and 308) in the client .
// The Docker client (and by extension docker API client) can be made to send a request
// like POST /containers//start where what would normally be in the name section of the URL is empty.
// This triggers an HTTP 301 from the daemon.
// In go 1.8 this 301 will be converted to a GET request, and ends up getting a 404 from the daemon.
// This behavior change manifests in the client in that before the 301 was not followed and
// the client did not generate an error, but now results in a message like Error response from daemon: page not found.
func CheckRedirect(req *http.Request, via []*http.Request) error {
	if via[0].Method == http.MethodGet {
		return http.ErrUseLastResponse
	}
	return ErrRedirect
}

// NewClientWithOpts initializes a new API client with default values. It takes functors
// to modify values when creating it, like `NewClientWithOpts(WithVersion(…))`
// It also initializes the custom http headers to add to each request.
//
// It won't send any version information if the version number is empty. It is
// highly recommended that you set a version or your client may break if the
// server is upgraded.
func NewClientWithOpts(ops ...Opt) (*Client, error) {
	client, err := defaultHTTPClient(DefaultDockerHost)
	if err != nil {
		return nil, err
	}
	c := &Client{
		host:    DefaultDockerHost,
		version: api.DefaultVersion,
		client:  client,
		proto:   defaultProto,
		addr:    defaultAddr,
	}

	for _, op := range ops {
		if err := op(c); err != nil {
			return nil, err
		}
	}

	if _, ok := c.client.Transport.(http.RoundTripper); !ok {
		return nil, fmt.Errorf("unable to verify TLS configuration, invalid transport %v", c.client.Transport)
	}
	if c.scheme == "" {
		c.scheme = "http"

		tlsConfig := resolveTLSConfig(c.client.Transport)
		if tlsConfig != nil {
			// TODO(stevvooe): This isn't really the right way to write clients in Go.
			// `NewClient` should probably only take an `*http.Client` and work from there.
			// Unfortunately, the model of having a host-ish/url-thingy as the connection
			// string has us confusing protocol and transport layers. We continue doing
			// this to avoid breaking existing clients but this should be addressed.
			c.scheme = "https"
		}
	}

	return c, nil
}

// NegotiateAPIVersionPing updates the client version to match the Ping.APIVersion
// if the ping version is less than the default version.  If a manual override is
// in place, either through the `DOCKER_API_VERSION` environment variable, or if
// the client was initialized with a fixed version (`opts.WithVersion(xx)`), no
// negotiation is performed.
func (cli *Client) NegotiateAPIVersionPing(p types.Ping) {
	if !cli.manualOverride {
		cli.negotiateAPIVersionPing(p)
	}
}
// Close the transport used by the client
func (cli *Client) Close() error {
	if t, ok := cli.client.Transport.(*http.Transport); ok {
		t.CloseIdleConnections()
	}
	return nil
}

// getAPIPath returns the versioned request path to call the api.
// It appends the query parameters to the path if they are not empty.
func (cli *Client) getAPIPath(ctx context.Context, p string, query url.Values) string {
	var apiPath string
	if cli.negotiateVersion && !cli.negotiated {
		cli.NegotiateAPIVersionPing(ctx)
	}
	if cli.version != "" {
		v := strings.TrimPrefix(cli.version, "v")
		apiPath = path.Join(cli.basePath, "/v"+v, p)
	} else {
		apiPath = path.Join(cli.basePath, p)
	}
	return (&url.URL{Path: apiPath, RawQuery: query.Encode()}).String()
}

// negotiateAPIVersionPing queries the API and updates the version to match the
// API version. Any errors are silently ignored.
func (cli *Client) negotiateAPIVersionPing(p types.Ping) {
	// try the latest version before versioning headers existed
	if p.APIVersion == "" {
		p.APIVersion = "1.24"
	}

	// if the client is not initialized with a version, start with the latest supported version
	if cli.version == "" {
		cli.version = api.DefaultVersion
	}
	// if server version is lower than the client version, downgrade
	if versions.LessThan(p.APIVersion, cli.version) {
		cli.version = p.APIVersion
	}

	// Store the results, so that automatic API version negotiation (if enabled)
	// won't be performed on the next request.
	if cli.negotiateVersion {
		cli.negotiated = true
	}
}

// DaemonHost returns the host address used by the client
func (cli *Client) DaemonHost() string {
	return cli.host
}

// HTTPClient returns a copy of the HTTP client bound to the server
func (cli *Client) HTTPClient() *http.Client {
	c := *cli.client
	return &c
}

func defaultHTTPClient(host string) (*http.Client, error) {
	url, err := ParseHostURL(host)
	if err != nil {
		return nil, err
	}
	transport := new(http.Transport)
	sockets.ConfigureTransport(transport, url.Scheme, url.Host)
	return &http.Client{
		Transport:     transport,
		CheckRedirect: CheckRedirect,
	}, nil
}

// ParseHostURL parses a url string, validates the string is a host url, and
// returns the parsed URL
func ParseHostURL(host string) (*url.URL, error) {
	protoAddrParts := strings.SplitN(host, "://", 2)
	if len(protoAddrParts) == 1 {
		return nil, fmt.Errorf("unable to parse docker host `%s`", host)
	}

	var basePath string
	proto, addr := protoAddrParts[0], protoAddrParts[1]
	if proto == "tcp" {
		parsed, err := url.Parse("tcp://" + addr)
		if err != nil {
			return nil, err
		}
		addr = parsed.Host
		basePath = parsed.Path
	}
	return &url.URL{
		Scheme: proto,
		Host:   addr,
		Path:   basePath,
	}, nil
}