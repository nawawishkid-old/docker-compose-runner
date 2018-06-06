# Docker compose manager
Run `docker-compose` command on any project without changing directory.

## Usage
`dm [compose_options] COMMAND [command_options]`

## Commands
- Any command of original `docker-compose` commands. And...
    - `DOCKER_COMPOSE_COMMAND PROJECT_NAME` -- e.g. `dm up my-project -d`
- `project COMMAND` -- Manage your Docker Compose projects
- `help | --help` -- This help text
