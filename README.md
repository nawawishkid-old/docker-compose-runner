# Docker Compose Runner
Run `docker-compose` command on any project without changing directory.

>Note: This project tested only on Ubuntu 16.04 LTS, not on any Mac or Windows. :(

## Features
- [x] Run any `docker-compose` command on any Docker compose project directory without manually changing directory.

## Prerequisites
- You should familiar with command-line interface. And...
- Yes, [Docker compose](https://docs.docker.com/compose/)!

## Installation
1. Just clone this repo to any directory you want. :)
2. Create a file in your working directory named `dm` then makes it executable
```shell
your-working-dir$ touch dm
your-working-dir$ chmod +x dm
```
3. Import `dm` source directory by editing the `dm` file you've just created
```shell
#!/usr/bin/env bash

# This is your `dm` file, opent it, not a console!

APP_SOURCE_DIR=path/to/dm/directory

source ${APP_SOURCE_DIR}/main.sh
```
4. You can now use `./dm` command in your working directory.

## Example usage
Suppose you have multiple Docker compose projects like this:
```
|-- docker-projects
    |-- project-1
    |-- some-directory
        |-- project-2
        |-- some-directory
            |-- project-3
|-- dm
```
Instead of moving into each `project-*` directory when you want to run some `docker-compose` on specific project, you just append the name of your project to `docker-compose` command to run on that project like `dm DOCKER_COMMAN PROJECT_NAME`.  

But before our `dm` knows where your project directory is. You have to register your existing projects directory first:
```shell
~$ dm project add project-1 ./docker-projects/project-1
~$ dm project add project-2 ./docker-projects/some-directory/project-2
~$ dm project add project-2 ./docker-projects/some-directory/some-directory/project-3
```
Now, you can run any `docker-compose` command for the project you've just registered with `dm`:
```shell
~$ dm up project-1 -d
~$ dm build project-2
~$ dm create project-3
```
That's it :)

## Issues
- [x] ~~[2018/06/07] Unable to use `--help` after docker-compose command e.g. `dm build --help` because the parameter next to `docker-compose` command is reserved for `PROJECT_NAME`. Must fix positional-parameter filtering algorithm in [`./main.sh`](main.sh)~~
- [ ] [2018/06/07] Unable to add compose_options argument before COMMAND

## Documentations
See [this](lib/dm/doc/main.md)