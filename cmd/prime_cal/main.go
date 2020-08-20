package main

import (
	"fmt"
	"github.com/docker/docker/pkg/term"
	"github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"github.com/vietnamz/prime-generator/cli"
	"github.com/vietnamz/prime-generator/daemon/config"
	"io"
	"os"
)

func initLogging(_, stderr io.Writer )  {
	logrus.SetOutput( stderr)
}
func runDaemon(opts *daemonOptions) (err error) {
	daemonCli := NewDaemonCli()
	return daemonCli.start(opts)
}
func newDaemonCommand() (*cobra.Command, error) {
	opts := newDaemonOptions(config.NewDaemonConfig())
	cmd := &cobra.Command{
		Use: "Prime Generation [OPTIONS]",
		Short: "A self-sufficent runtime for application",
		SilenceUsage: true,
		SilenceErrors: true,
		Args: cli.NoArgs,
		RunE: func(cmd *cobra.Command, args []string) error {
			opts.flags = cmd.Flags()
			return runDaemon(opts)
		},
		Version: fmt.Sprintf("%s, build %s", "1.0.0", "master"),
	}
	flags := cmd.Flags()
	flags.BoolP("version", "v", false, "Print version information and quit")
	defaultDaemonConfigFile, err := getDefaultDaemonConfigFile()
	if err != nil {
		return nil, err
	}
	flags.StringVar(&opts.configFile, "config-file", defaultDaemonConfigFile, "Daemon configuration file")
	opts.InstallFlags(flags)
	if err := installConfigFlags(opts.daemonConfig, flags); err != nil {
		return nil, err
	}
	return cmd, nil
}
func main() {
	logrus.SetFormatter(&logrus.TextFormatter{
		TimestampFormat: "2006-01-02 15:04:05",
		FullTimestamp: true,
	})
	_, stdout, stderr := term.StdStreams()
	initLogging(stdout, stderr)

	onError := func( err error ) {
		fmt.Fprintf(stderr, "%s\n", err)
		os.Exit(1)
	}
	cmd, err := newDaemonCommand()
	if err != nil {
		onError(err)
	}
	cmd.SetOut(stdout)
	if err := cmd.Execute(); err != nil {
		onError(err)
	}
}
