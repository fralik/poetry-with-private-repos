# syntax = docker/dockerfile:1.0-experimental

FROM python:3.7

# We are going to use the latest available pip. Not necessary for poetry issue
RUN pip install --upgrade pip

WORKDIR /app

COPY . ./
# Poetry will be installed to that location
ENV POETRY_HOME=/poetry

# We ship get-poetry.py with us rather then downloading it. You can get it the way it suits you.
RUN python get-poetry.py --version 1.0.2

# Looks like poetry fails to add itself to the Path in Docker. We add it here.
ENV PATH="/poetry/bin:${PATH}"

# Configure our private repo
RUN poetry config repositories.foo https://foo.bar/simple/

# Use secret to get packages from the private repo
RUN --mount=type=secret,id=auth_toml,required,dst=/root/.config/pypoetry/auth.toml poetry install -vvv --no-ansi
