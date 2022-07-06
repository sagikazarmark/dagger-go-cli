package archive

import (
	"dagger.io/dagger"

	"universe.dagger.io/bash"
)

// Create a new archive
#Create: {
	// Source files for the archive
	source: dagger.#FS

	// Archive name
	name: string

	_image: #Image

	_sourcePath: "/src"

	bash.#Run & {
		input: _image.output

		script: contents: """
case "\(name)" in
    *.tar.gz | *.tgz)
        tar -czvf \(name) *
        ;;

    *.zip)
        7z a \(name) *
        ;;

    *)
        echo "Unsupported archive type"
        exit 1
        ;;
esac

mkdir -p /result
mv \(name) /result
"""

		workdir: _sourcePath
		mounts: {
			"source": {
				dest:     _sourcePath
				contents: source
			}
		}

		export: directories: "/result": _
	}
}
