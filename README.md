# Go CLI example for [Dagger](https://dagger.io/)

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/sagikazarmark/dagger-go-cli/CI?style=flat-square)](https://github.com/sagikazarmark/dagger-go-cli/actions?query=workflow%3ACI)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/sagikazarmark/dagger-go-cli/Dagger?style=flat-square)](https://github.com/sagikazarmark/dagger-go-cli/actions?query=workflow%3ADagger)
[![Codecov](https://img.shields.io/codecov/c/github/sagikazarmark/dagger-go-cli?style=flat-square)](https://codecov.io/gh/sagikazarmark/dagger-go-cli)

This repository serves as an example for using [Dagger](https://dagger.io/) as a CI solution for a Go CLI tool.

It's also the model repository for my [Building a CI pipeline for a Go CLI application with Dagger](https://sagikazarmark.hu/blog/dagger-go-cli/) post (available on [dev.to](https://dev.to/sagikazarmark/building-a-ci-pipeline-for-a-go-cli-application-with-dagger-1ik5) as well).

## Setup

[Install Dagger](https://docs.dagger.io/install) (at least version 0.2.19).

Run tests and linters:

```shell
dagger do check
```


## License

The project is licensed under the [MIT License](LICENSE).
