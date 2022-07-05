package goreleaser

import (
	"dagger.io/dagger"

	"universe.dagger.io/docker"
	"universe.dagger.io/go"
)

// Release Go binaries using GoReleaser
#Release: {
	// Source code
	source: dagger.#FS

	// GoReleaser version
	version: *"1.9.2" | string

	_image: docker.#Pull & {
		source: "index.docker.io/goreleaser/goreleaser:v\(version)"
	}

	go.#Container & {
		name: "goreleaser"
		entrypoint: []
		"source": source
		input:    _image.output
		command: {
			// name: "goreleaser"
			name: "release"
			// args: ["release"]
		}
	}
}
