package main

import (
	"strings"

	"dagger.io/dagger"
	"dagger.io/dagger/core"

	"universe.dagger.io/go"

	"github.com/sagikazarmark/dagger-go-cli/ci/archive"
	"github.com/sagikazarmark/dagger-go-cli/ci/codecov"
	"github.com/sagikazarmark/dagger-go-cli/ci/github"
	"github.com/sagikazarmark/dagger-go-cli/ci/go/golangci"
	"github.com/sagikazarmark/dagger-go-cli/ci/go/goreleaser"
)

dagger.#Plan & {
	client: filesystem: ".": read: exclude: [
		"bin",
		"build",
		"tmp",
	]
	client: env: {
		CI:                string | *""
		GITHUB_ACTIONS:    string | *""
		GITHUB_ACTION:     string | *""
		GITHUB_HEAD_REF:   string | *""
		GITHUB_REF:        string | *""
		GITHUB_REPOSITORY: string | *""
		GITHUB_RUN_ID:     string | *""
		GITHUB_SERVER_URL: string | *""
		GITHUB_SHA:        string | *""
		GITHUB_WORKFLOW:   string | *""
		CODECOV_TOKEN?:    dagger.#Secret
		GITHUB_TOKEN?:     dagger.#Secret
		GIT_TAG:           string | *""
		GITHUB_REF_NAME:   string | *""
		GITHUB_REF_TYPE:   string | *""
	}
	actions: {
		_source: client.filesystem["."].read.contents

		build: {
			"linux/amd64":   _
			"darwin/amd64":  _
			"windows/amd64": _

			[platform=string]: go.#Build & {
				source: _source

				package: "."
				// binaryName: "hello"
				os:   strings.Split(platform, "/")[0]
				arch: strings.Split(platform, "/")[1]

				ldflags: "-s -w"

				env: {
					CGO_ENABLED: "0"
				}
			}
		}

		check: {
			test: {
				"go": {
					_test: go.#Test & {
						source:  _source
						package: "./..."

						_image: go.#Image & {
							version: "1.18"
						}

						input: _image.output
						command: flags: {
							"-race":         true
							"-covermode":    "atomic"
							"-coverprofile": "/coverage.out"
						}

						export: files: "/coverage.out": _
					}
					_coverage: codecov.#Upload & {
						_write: core.#WriteFile & {
							input:    _source
							path:     "/coverage.out"
							contents: _test.export.files."/coverage.out"
						}

						source: _write.output
						file:   "/src/coverage.out"

						// Fixes https://github.com/dagger/dagger/issues/2680
						_token: client.env.CODECOV_TOKEN

						if client.env.CODECOV_TOKEN != _|_ {
							token: client.env.CODECOV_TOKEN
						}

						dryRun: client.env.CI != "true"

						// token: client.env.CODECOV_TOKEN

						env: {
							// if client.env.CODECOV_TOKEN != _|_ {
							//  CODECOV_TOKEN: client.env.CODECOV_TOKEN
							// }
							GITHUB_ACTIONS:    client.env.GITHUB_ACTIONS
							GITHUB_ACTION:     client.env.GITHUB_ACTION
							GITHUB_HEAD_REF:   client.env.GITHUB_HEAD_REF
							GITHUB_REF:        client.env.GITHUB_REF
							GITHUB_REPOSITORY: client.env.GITHUB_REPOSITORY
							GITHUB_RUN_ID:     client.env.GITHUB_RUN_ID
							GITHUB_SERVER_URL: client.env.GITHUB_SERVER_URL
							GITHUB_SHA:        client.env.GITHUB_SHA
							GITHUB_WORKFLOW:   client.env.GITHUB_WORKFLOW
						}
					}

					export: files: "/coverage.out": _test.export.files."/coverage.out"
				}
			}
			lint: {
				"go": golangci.#Lint & {
					source:  _source
					version: "1.46"
					always:  true
				}
			}
		}

		package: {
			_files: core.#Copy & {
				input:    dagger.#Scratch
				contents: _source
				include: [
					"README.md",
					"LICENSE",
				]
			}

			_archives: {
				"linux/amd64":   _
				"darwin/amd64":  _
				"windows/amd64": _

				[platform=string]: archive.#Create & {
					_source: core.#Merge & {
						inputs: [
							_files.output,
							if platform == "darwin/amd64" {
								build."darwin/amd64".output
							},
							if platform == "linux/amd64" {
								build."linux/amd64".output
							},
							if platform == "windows/amd64" {
								build."windows/amd64".output
							},
						]
					}

					source: _source.output

					_os:   strings.Split(platform, "/")[0]
					_arch: strings.Split(platform, "/")[1]
					_type: string | *"tar.gz"
					if _os == "windows" {
						_type: "zip"
					}

					name: "dagger-go-cli_\(_os)_\(_arch).\(_type)"
				}
			}

			_packages: core.#Merge & {
				inputs: [
					package._archives."linux/amd64".export.directories."/result",
					package._archives."darwin/amd64".export.directories."/result",
					package._archives."windows/amd64".export.directories."/result",
				]
			}

			output: _packages.output
		}

		release: {
			"goreleaser": goreleaser.#Release & {
				source: _source

				dryRun:   client.env.CI != "true" || client.env.GITHUB_REF_TYPE != "tag"
				snapshot: client.env.CI != "true" || client.env.GITHUB_REF_TYPE != "tag"

				env: {
					if client.env.GITHUB_TOKEN != _|_ {
						GITHUB_TOKEN: client.env.GITHUB_TOKEN
					}
				}
			}
			"github": github.#Release & {
				source:    _source
				artifacts: package.output

				tag: client.env.GIT_TAG

				if client.env.GITHUB_REF_NAME != "" {
					tag: client.env.GITHUB_REF_NAME
				}

				env: {
					if client.env.GITHUB_TOKEN != _|_ {
						GITHUB_TOKEN: client.env.GITHUB_TOKEN
					}
				}
			}
		}
	}
}
