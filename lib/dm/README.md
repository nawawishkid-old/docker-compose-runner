# Docker compose manager

## Commands
### `dm compose <command>`
#### `build`
**Usage**  
- `dm compose build <project_name> <template_name> [options]`

**Options**  
<!-- - `--var <key=value>`: Key-value variable using in template string replacement -->
<!-- - `--varf <name>`: Name of template variable file using in template string replacement -->
- `--override`: Override existing project with the same name
- `--dir-from <template_name>`: Use directories from another template

**Description**  
Create a project directory in `compose/projects` from template directory in `compose/templates`

**Work flow**  
- Create directory in `compose/projects/<project>`
- Copy template from `compose/templates/<template>` to `compose/projects/<project>` directory
- Rename `template.yml` to `docker-compose.yml` in `compose/projects/<project>`
<!-- - Replace placeholder in `template.yml` with given details -->

#### `up`
**Usage**  
- `dm compose up <project_name> [options]`

**Options**  


**Description**  
Run `docker-compose up` on `docker-compose.yml` in specified project.

**Work flow**  
- Check if `docker-compose.yml` in given `compose/projects/<project_name>` exists
- If exists:
    - `cd` to the directory
    - Run `docker-compose up`

#### `down`
**Usage**  
- `dm compose down <project_name> [options]`

**Options**  


**Description**  
Run `docker-compose down` on `docker-compose.yml` in specified project.


**Work flow**  
- Check if `docker-compose.yml` in given `compose/projects/<project_name>` exists
- If exists:
    - `cd` to the directory
    - Run `docker-compose down`


#### `ps`
**Usage**  
- `dm compose ps`

**Options**  


**Description**  


**Work flow**  


#### `delete`
**Usage**  
- `dm compose delete <project_name> [options]`

**Options**  


**Description**  
Remove specified project directory


**Work flow**  
- Check if `compose/projects/<project_name>` exists
- If exists:
    - Remove the directory
