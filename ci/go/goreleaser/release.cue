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
	version: *"1.10.1" | string

	// Don't publish or announce the release
	dryRun: bool | *false

	// Build a snapshot instead of a tag
	snapshot: bool | *false

	_image: docker.#Pull & {
		source: "index.docker.io/goreleaser/goreleaser:v\(version)"
	}

	go.#Container & {
		name: "goreleaser"
		entrypoint: []
		"source": source
		input:    _image.output
		command: {
			name: "goreleaser"

			flags: {
				if dryRun {
					"--skip-publish":  true
					"--skip-announce": true
				}

				if snapshot {
					"--snapshot": true
				}
			}
		}
	}
}
