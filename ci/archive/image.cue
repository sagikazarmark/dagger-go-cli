package archive

import (
	"universe.dagger.io/alpine"
)

// Build an archive base image
#Image: {
	alpine.#Build & {
		packages: {
			bash:      _
			coreutils: _
			p7zip:     _
		}
	}
}
