package github

import (
	"dagger.io/dagger"

	"universe.dagger.io/bash"
	"universe.dagger.io/docker"
)

// Create new GitHub release
#Release: {
	// Source files
	source: dagger.#FS

	// Artifact files
	artifacts: dagger.#FS

	// Create release from this specific tag
	tag: string

	_image: #Image

	_sourcePath:   "/src"
	_artifactPath: "/artifacts"

	bash.#Run & {
		input: *_image.output | docker.#Image
		script: contents: "gh release create --title '\(tag)' \(tag) /artifacts/*"
		workdir: _sourcePath
		mounts: {
			"source": {
				dest:     _sourcePath
				contents: source
			}
			"artifacts": {
				dest:     _artifactPath
				contents: artifacts
			}
		}
	}
}
