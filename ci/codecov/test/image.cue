package codecov

import (
	"dagger.io/dagger"

	"github.com/sagikazarmark/dagger-go-cli/ci/codecov"
)

dagger.#Plan & {
	actions: test: codecov.#Image & {}
}
