package batcher

import (
	"fmt"
	"github.com/alecthomas/kong"
)

var VERSION = "0.0.1"

type Globals struct {
	Debug     bool        `short:"D" help:"Enable debug mode"`
	Set       string      `short:"S" help:"Set column=value"`
	Where     string      `short:"W" help:"WHERE clause"`
	Version   VersionFlag `name:"version" short:"V" help:"Print version information and quit"`
}

type VersionFlag string

func (v VersionFlag) Decode(ctx *kong.DecodeContext) error { return nil }
func (v VersionFlag) IsBool() bool                         { return true }
func (v VersionFlag) BeforeApply(app *kong.Kong, vars kong.Vars) error {
	fmt.Println(VERSION)
	app.Exit(0)
	return nil
}

type CLI struct {
	Globals

	// Delete  DeleteCmd  `cmd help:"Block until one or more containers stop, then print their exit codes"`
	// Update  UpdateCmd  `cmd help:"Block until one or more containers stop, then print their exit codes"`
        Version VersionCmd `cmd help:"Show version information"`
}

type VersionCmd struct {
}

func (cmd *VersionCmd) Run(globals *Globals) error {
	fmt.Println(VERSION)
	return nil
}

func main() {
	cli := CLI{
		Globals: Globals{
			Version: VersionFlag(VERSION),
		},
	}

	ctx := kong.Parse(&cli,
		kong.Name("batcher"),
		kong.Description("Transaction-friendly bulk updates and deletes"),
		kong.UsageOnError(),
		kong.ConfigureHelp(kong.HelpOptions{
			Compact: true,
		}),
		kong.Vars{
			"version": VERSION,
		})
	err := ctx.Run(&cli.Globals)
	ctx.FatalIfErrorf(err)
}
