## `make`
- **Usage**:
    - `dm compose make PROJECT_NAME TEMPLATE [options]`
- **Parameters**
    - **`PROJECT_NAME`** -- Name of the directory hosting Docker Compose project
    - **`TEMPLATE`** -- Docker Compose directory you wish to copy. This can be both name of a template in template directory you specified in environment variable `DM_TEMPLATE_DIR`, or a path to existing directory.
- **Options**:  
    - **`--dir PATH`** -- Specify existing directory for hosting project directory

- **Description**:  
Create a project directory in `compose/projects` from template directory in `compose/templates`

- **Work flow**:

## `register`
- **Usage**:
    - `dm compose register PROJECT_NAME PROJECT_DIR`

- **Parameters**
    - **`PROJECT_NAME`** -- 
    - **`PROJECT_DIR`** -- 

- **Options**:  

- **Description**:  
Map existing project directory to given name

- **Work flow**:


#### `build`
**Usage**  
- `dm compose [options] build PROJECT_NAME TEMPLATE_NAME [options]`

**Options**  
<!-- - `--var <key=value>`: Key-value variable using in template string replacement -->
<!-- - `--varf <name>`: Name of template variable file using in template string replacement -->
- `--override`: Override existing project with the same name
- `--dir-from TEMPLATE_NAME`: Use directories from another template

**Description**  
Create a project directory in `compose/projects` from template directory in `compose/templates`

**Work flow**  
- Check if directory with the given name already exists.
- if not exists:
    - Check if given name is a valid project name.
        - if valid:
            - Create directory in `compose/projects/PROJECT_NAME`
            - Copy template from `compose/templates/TEMPLATE_NAME` to `compose/projects/PROJECT_NAME` directory
            - Rename `template.yml` to `docker-compose.yml` in `compose/projects/PROJECT_NAME`
- if exists:
    - Tell user that they can override existing project directory
<!-- - Replace placeholder in `template.yml` with given details -->

#### `up`
**Usage**  
- `dm compose up PROJECT_NAME [options]`

**Options**  


**Description**  
Run `docker-compose up` on `docker-compose.yml` in specified project.

**Work flow**  
- Check if `docker-compose.yml` in given `compose/projects/PROJECT_NAME` exists
- If exists:
    - `cd` to the directory
    - Run `docker-compose up`

#### `down`
**Usage**  
- `dm compose down PROJECT_NAME [options]`

**Options**  


**Description**  
Run `docker-compose down` on `docker-compose.yml` in specified project.


**Work flow**  
- Check if `docker-compose.yml` in given `compose/projects/PROJECT_NAME` exists
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
- `dm compose delete PROJECT_NAME [options]`

**Options**  


**Description**  
Remove specified project directory


**Work flow**  
- Check if `compose/projects/PROJECT_NAME` exists
- If exists:
    - Remove the directory

#### `template`
**Usage**  
- `dm compose template COMMAND`

**Options**  


**Description**  


**Work flow**  


