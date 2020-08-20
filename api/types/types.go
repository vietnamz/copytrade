package types

// alias to a builder version
// format MAJOR_MINOR_DATE
// ex: 2020_1_2020/08/18
type BuilderVersion string

// PrimeNumber is used to retrieve the prime number.
// GET "/prime?number=123"
// "number" is the upper bound value.
type PrimeNumber struct {
	Number     string       `json:"number"`
	Mtime      string   `json:"elapsed_time"`
}
// Version contains response of Engine API:
// GET "/version"
type Version struct {
	Platform   struct{ Name string } `json:",omitempty"`

	// The following fields are deprecated, they relate to the Engine component and are kept for backwards compatibility

	Version       string
	APIVersion    string `json:"ApiVersion"`
	MinAPIVersion string `json:"MinAPIVersion,omitempty"`
	GitCommit     string
	GoVersion     string
	Os            string
	Arch          string
	KernelVersion string `json:",omitempty"`
	Experimental  bool   `json:",omitempty"`
	BuildTime     string `json:",omitempty"`
}

// Ping contains response of Engine API:
// GET "/ping"
type Ping struct {
	// API Version
	// ex: v1
	APIVersion     string
	// OS Type
	// ex: linux
	OSType         string
	// Not release yet.
	Experimental   bool
	//! refs above.
	BuilderVersion BuilderVersion
}