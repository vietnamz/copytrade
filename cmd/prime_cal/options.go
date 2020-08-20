package main

import (
	"github.com/docker/go-connections/tlsconfig"
	"github.com/spf13/pflag"
	"github.com/vietnamz/prime-generator/daemon/config"
	"os"
	"path/filepath"
)

const (
	// DefaultCaFile is the default filename for the CA pem file
	DefaultCaFile = "configs/ca.pem"
	// DefaultKeyFile is the default filename for the key pem file
	DefaultKeyFile = "configs/key.pem"
	// DefaultCertFile is the default filename for the cert pem file
	DefaultCertFile = "configs/cert.pem"
	// FlagTLSVerify is the flag name for the TLS verification option
	FlagTLSVerify = "tlsverify"
)

var (
	certPath  = os.Getenv("CERT_PATH")
	tLSVerify = os.Getenv("TLS_VERIFY") != ""
)

type daemonOptions struct {
	configFile   string
	daemonConfig *config.Config
	flags        *pflag.FlagSet
	Debug        bool
	Host         string
	LogLevel     string
	TLS          bool
	TLSVerify    bool
	TLSOptions   *tlsconfig.Options
}


// newDaemonOptions returns a new daemonFlags
func newDaemonOptions(config *config.Config) *daemonOptions {
	return &daemonOptions{
		daemonConfig: config,
		TLS: true,
		TLSVerify: true,
	}
}
// QuotedString is a string that may have extra quotes around the value. The
// quotes are stripped from the value.
type QuotedString struct {
	value *string
}

// Set sets a new value
func (s *QuotedString) Set(val string) error {
	*s.value = trimQuotes(val)
	return nil
}

// Type returns the type of the value
func (s *QuotedString) Type() string {
	return "string"
}

func (s *QuotedString) String() string {
	return string(*s.value)
}

func trimQuotes(value string) string {
	lastIndex := len(value) - 1
	for _, char := range []byte{'\'', '"'} {
		if value[0] == char && value[lastIndex] == char {
			return value[1:lastIndex]
		}
	}
	return value
}

// NewQuotedString returns a new quoted string option
func NewQuotedString(value *string) *QuotedString {
	return &QuotedString{value: value}
}


// InstallFlags adds flags for the common options on the FlagSet
func (o *daemonOptions) InstallFlags(flags *pflag.FlagSet) {

	flags.BoolVarP(&o.Debug, "debug", "D", false, "Enable debug mode")
	flags.StringVarP(&o.LogLevel, "log-level", "l", "info", `Set the logging level ("debug"|"info"|"warn"|"error"|"fatal")`)
	flags.BoolVar(&o.TLS, "tls", false, "Use TLS; implied by --tlsverify")
	flags.BoolVar(&o.TLSVerify, FlagTLSVerify, tLSVerify, "Use TLS and verify the remote")

	// TODO use flag flags.String("identity"}, "i", "", "Path to libtrust key file")

	o.TLSOptions = &tlsconfig.Options{
		CAFile:   filepath.Join(certPath, DefaultCaFile),
		CertFile: filepath.Join(certPath, DefaultCertFile),
		KeyFile:  filepath.Join(certPath, DefaultKeyFile),
	}
	tlsOptions := o.TLSOptions
	flags.Var(NewQuotedString(&tlsOptions.CAFile), "tlscacert", "Trust certs signed only by this CA")
	flags.Var(NewQuotedString(&tlsOptions.CertFile), "tlscert", "Path to TLS certificate file")
	flags.Var(NewQuotedString(&tlsOptions.KeyFile), "tlskey", "Path to TLS key file")

	flags.StringVarP(&o.Host, "host", "H", "tcp://0.0.0.0:8080", "Daemon socket(s) to connect to")
}

// SetDefaultOptions sets default values for options after flag parsing is
// complete
func (o *daemonOptions) SetDefaultOptions(flags *pflag.FlagSet) {
	// Regardless of whether the user sets it to true or false, if they
	// specify --tlsverify at all then we need to turn on TLS
	// TLSVerify can be true even if not set due to DOCKER_TLS_VERIFY env var, so we need
	// to check that here as well
	if flags.Changed(FlagTLSVerify) || o.TLSVerify {
		o.TLS = true
	}
	if !o.TLS {
		o.TLSOptions = nil
	} else {
		tlsOptions := o.TLSOptions
		tlsOptions.InsecureSkipVerify = !o.TLSVerify

		// Reset CertFile and KeyFile to empty string if the user did not specify
		// the respective flags and the respective default files were not found.
		if !flags.Changed("tlscert") {
			if _, err := os.Stat(tlsOptions.CertFile); os.IsNotExist(err) {
				tlsOptions.CertFile = ""
			}
		}
		if !flags.Changed("tlskey") {
			if _, err := os.Stat(tlsOptions.KeyFile); os.IsNotExist(err) {
				tlsOptions.KeyFile = ""
			}
		}
	}
}