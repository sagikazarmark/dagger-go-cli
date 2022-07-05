package github

import (
	"universe.dagger.io/bash"
	"universe.dagger.io/docker"
)

// GitHub CLI image
#Image: {
	version: string | *"2.13.0"

	docker.#Build & {
		steps: [
			docker.#Pull & {
				source: "index.docker.io/alpine:3.15.0@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300"
			},
			docker.#Run & {
				command: {
					name: "apk"
					args: ["add", "bash"]
					flags: {
						"-U":         true
						"--no-cache": true
					}
				}
			},
			docker.#Run & {
				command: {
					name: "apk"
					args: ["add", "curl"]
					flags: {
						"-U":         true
						"--no-cache": true
					}
				}
			},
			docker.#Run & {
				command: {
					name: "apk"
					args: ["add", "git"]
					flags: {
						"-U":         true
						"--no-cache": true
					}
				}
			},
			bash.#Run & {
				script: contents: """
apk add curl tar
curl -L https://github.com/cli/cli/releases/download/v\(version)/gh_\(version)_linux_amd64.tar.gz | tar -zOxf - gh_\(version)_linux_amd64/bin/gh > /usr/local/bin/gh
chmod +x /usr/local/bin/gh
"""
			},
		]
	}
}
