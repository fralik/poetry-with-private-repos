# How to use Poetry with private repos in Docker (without secret exposure)

This example shows how one can install packages from private repos 
(with authentication) with Poetry and Docker. Poetry version is 1.0.2.
I've tested it with a single Azure DevOps feed, i.e. one extra repository.

## Problem

Poetry [documentation](https://python-poetry.org/docs/repositories/#using-a-private-repository) describes how one can use private repos.
One has to invoke `poetry config` commands and also have `[[tool.poetry.source]]`
in `pyproject.toml`.

This is fine as long as you are ready to expose your password. If `keyring`
is available in the system, then poetry will try to use it.
I am not very familiar with the keyring, but it seems that logged-in user is 
able to read the secret easily. I guess this is OK while you are developping
on your machine. In Docker, this essentially means that anyone who gets your
image will be able to retrieve the secret.

## Mentions

There is an [issue](https://github.com/python-poetry/poetry/issues/208)
regarding usage of environment variables in `pyproject.toml`. Looks like
it was rejected by the Poetry author.

Poetry documentation [says](https://github.com/python-poetry/poetry/blob/636ce8b0eba7dfa390b3fd961d1b9fb533d5d033/docs/docs/configuration.md#using-environment-variables) one can use
`POETRY_HTTP_BASIC_MY_REPOSITORY_PASSWORD` environment variable.
In reallity, [this doesn't seem to work](https://github.com/python-poetry/poetry/issues/1871).

## Proposed solution

1. Prepare `auth.toml` file locally. Be sure not to check it in under version control.
2. Use Docker [BuildKit](https://docs.docker.com/develop/develop-images/build_enhancements/)
   to pass `auth.toml` inside the image.

You can see how it all works in the `Dockerfile` in this repo. Pay 
attention to `.gitignore` and `.dockerignore` files.

## Walkthrough

After you cloned the code in and cd'ed in the `poetry-with-private-repos` folder.

1. Copy `auth-example.toml` to `auth.toml`, i.e. `cp auth-example.toml auth.toml`.

2. Make changes to `pyproject.toml`:
    1. Change `name` and `url` of your repo under `tool.poetry.source`.
    2. Adjust dependencies to include your packages.

3. Be sure to enable Docker BuildKit, i.e. `export DOCKER_BUILDKIT=1`.

4. Build docker image:
    
    `docker build --secret id=auth_toml,src=auth.toml --progress=plain -t demo .`

You shall see no errors and Docker image shall be built. If you 
login into docker and try to see the content of `/root/.config/pypoetry/auth.toml`,
this file must be empty.

