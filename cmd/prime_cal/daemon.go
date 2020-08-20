package main

import (
	"context"
	"crypto/tls"
	"fmt"
	"github.com/docker/docker/pkg/homedir"
	"github.com/docker/docker/pkg/signal"
	"github.com/docker/go-connections/tlsconfig"
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"
	"github.com/spf13/pflag"
	"github.com/vietnamz/prime-generator/api"
	apiServer "github.com/vietnamz/prime-generator/api/server"
	"github.com/vietnamz/prime-generator/api/server/middleware"
	"github.com/vietnamz/prime-generator/api/server/router"
	"github.com/vietnamz/prime-generator/api/server/router/prime"
	systemRouter "github.com/vietnamz/prime-generator/api/server/router/system"
	"github.com/vietnamz/prime-generator/cli/debug"
	"github.com/vietnamz/prime-generator/daemon"
	"github.com/vietnamz/prime-generator/daemon/config"
	"os"
	"path/filepath"
	"runtime"
	"strings"
)

type DaemonCli struct {
	Config *config.Config
	flags *pflag.FlagSet
	api *apiServer.Server
	Hosts []string
}

func NewDaemonCli() *DaemonCli  {
	return &DaemonCli{}
}
func (cli *DaemonCli) stop() {
	logrus.Info("Stop daemon")
	cli.api.Close()
}

func getDefaultDaemonConfigDir() (string, error) {
	// NOTE: CLI uses ~/.docker while the daemon uses ~/.config/docker, because
	// ~/.docker was not designed to store daemon configurations.
	// In future, the daemon directory may be renamed to ~/.config/moby-engine (?).
	configHome, err := homedir.GetConfigHome()
	if err != nil {
		return "", nil
	}
	return filepath.Join(configHome, "prime"), nil
}

func getDefaultDaemonConfigFile() (string, error) {
	dir, err := getDefaultDaemonConfigDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(dir, "prime.json"), nil
}
func loadDaemonCliConfig(opts *daemonOptions) (*config.Config, error) {
	conf := opts.daemonConfig
	flags := opts.flags
	conf.Debug = opts.Debug
	conf.Host = opts.Host
	conf.LogLevel = opts.LogLevel
	conf.TLS = opts.TLS
	conf.TLSVerify = opts.TLSVerify

	if opts.TLSOptions != nil {
		logrus.Printf("Tls not null")
		conf.CAFile = opts.TLSOptions.CAFile
		conf.CertFile = opts.TLSOptions.CertFile
		conf.KeyFile = opts.TLSOptions.KeyFile
	}
	if opts.configFile != "" {
		c, err := config.MergeDaemonConfigurations(conf, flags, opts.configFile)
		if err != nil {
			if flags.Changed("config-file") || !os.IsNotExist(err) {
				return nil, errors.Wrapf(err, "unable to configure the Docker daemon with file %s", opts.configFile)
			}
		}
		// the merged configuration can be nil if the config file didn't exist.
		// leave the current configuration as it is if when that happens.
		if c != nil {
			conf = c
		}
	}
	return conf, nil
}
func newAPIServerConfig( cli *DaemonCli) (*apiServer.Config, error) {
	serverConfig := &apiServer.Config{
		Logging: cli.Config.Debug,
		Version: api.DefaultVersion,
		CorsHeader : cli.Config.CorsHeaders,

	}
	if cli.Config.TLS {
		tlsOptions := tlsconfig.Options{
			CAFile:             cli.Config.CAFile,
			CertFile:           cli.Config.CertFile,
			KeyFile:            cli.Config.KeyFile,
			ExclusiveRootPools: true,
		}

		if cli.Config.TLSVerify {
			// server requires and verifies client's certificate
			tlsOptions.ClientAuth = tls.RequireAndVerifyClientCert
		}
		tlsConfig, err := tlsconfig.Server(tlsOptions)
		if err != nil {
			logrus.Errorf("Failed to load tlsconfig %s", err)
			return nil, err
		}
		serverConfig.TLSConfig = tlsConfig
	}
	return serverConfig, nil
}

func (cli *DaemonCli) initMiddleware( s *apiServer.Server, cfg *apiServer.Config ) error {
	v := cfg.Version
	vm := middleware.NewVersionMiddleware(v, api.DefaultVersion, api.MinVersion)
	s.UseMiddleware(vm)
	logrus.Printf("init the cors middleware %s" , cfg.CorsHeader)
	if cfg.CorsHeader != "" {
		c := middleware.NewCORSMiddleware(cfg.CorsHeader)
		s.UseMiddleware(c)
	}
	return nil
}
func initRouter( opts routerOptions) {
	routers := []router.Router {
		systemRouter.NewRouter(),
		prime.NewRouter(opts.daemon),
	}
	opts.api.InitRouter(routers...)
}

func loadListeners(cli *DaemonCli, serverConfig *apiServer.Config) ([]string, error) {
	var hosts []string

	var err error
	if cli.Config.Host, err = ParseHost(false, false, cli.Config.Host); err != nil {
		return nil, errors.Wrapf(err, "error parsing -H %s", cli.Config.Host)
	}

	protoAddr := cli.Config.Host
	protoAddrParts := strings.SplitN(protoAddr, "://", 2)
	if len(protoAddrParts) != 2 {
		return nil, fmt.Errorf("bad format %s, expected PROTO://ADDR", protoAddr)
	}

	proto := protoAddrParts[0]
	addr := protoAddrParts[1]

	ls, err := InitListeners(proto, addr, "", serverConfig.TLSConfig)
	if err != nil {
		return nil, err
	}
	logrus.Printf("Listener created for HTTP on %s (%s)", proto, addr)
	hosts = append(hosts, protoAddrParts[1])
	cli.api.Accept(addr, ls...)

	return hosts, nil
}

func (cli *DaemonCli) start(opts *daemonOptions) (err error )  {
	logrus.Info("Start a daemon")
	stopc := make(chan bool)
	defer close(stopc)
	opts.SetDefaultOptions(opts.flags)

	if cli.Config, err = loadDaemonCliConfig(opts); err != nil {
		return err
	}
	logrus.Info("Starting up")
	cli.flags = opts.flags
	cli.Config.ConfigFile = opts.configFile
	if cli.Config.Debug {
		debug.Enable()
	}
	if runtime.GOOS == "linux" && os.Getegid() != 0 {
		return fmt.Errorf("App needs to be started without root")
	}

	//TODO Start a web server
	serverConfig, err := newAPIServerConfig(cli)

	if err != nil {
		return errors.Wrap(err, "Failed to create api server")
	}

	cli.api = apiServer.New(serverConfig)
	_, err = loadListeners(cli, serverConfig)
	if err != nil {
		return errors.Wrap(err, "failed to load lister")
	}

	// create a context so that we can control how to terminate a app.
	_, cancel := context.WithCancel(context.Background())
	defer cancel()
	signal.Trap(func() {
		logrus.Print("graceful to close")
		cli.stop()
		<-stopc // wait for daemonCli.start() to return
	}, logrus.StandardLogger())


	cli.initMiddleware(cli.api, serverConfig)
	logrus.Info("Daemon has completed initialization")

	routerOptions, err := newRouterOptions(daemon.NewDaemon(cli.Config))
	if err != nil {
		return err
	}

	routerOptions.api = cli.api
	initRouter(routerOptions)

	serverAPIWait := make(chan error)
	go cli.api.Wait(serverAPIWait)

	errAPI := <-serverAPIWait
	if errAPI != nil {
		return errors.Wrap(errAPI, "shutting down due to ServeAPI error")
	}
	logrus.Info("Daemon shutdown complete")
	return nil
}

type routerOptions struct {
	api *apiServer.Server
	daemon *daemon.Daemon
}

func newRouterOptions( d *daemon.Daemon ) (routerOptions, error)  {
	return routerOptions{
		daemon: d,
	}, nil
}