# Qorus in Docker

## Qorus Integration Engine(R) Enterprise Edition in Docker

 There are four images available, two based on Ubuntu, and two based on Alpine Linux.  Docker images contain a minimal set of packages able to run everything.  All Docker images as of Qorus v5.1+ are multiarch images, supporting amd64 (x86_64) and arm64 (aarch64) processors.

The latest `latest` tag is for version `6.0`.

Available images for Qorus Integration Engine(R) Enterprise Edition:
- `public.ecr.aws/qorus/qorus-ee:latest` (Ubuntu Jammy Jellyfish 22.04 LTS with Java 17, Python 3.10, Oracle Instant Client 21.1, Firebird ODBC drivers)
- `public.ecr.aws/qorus/qorus-ee-go:latest` (`qorus-ee:latest` with Python 3.8 + `go` and `grpcurl`)
- `public.ecr.aws/qorus/qorus-ee-alpine:latest` (Alpine Linux 3.17, Java 17, Python 3.10, Oracle Instant Client 21.1)
- `public.ecr.aws/qorus/qorus-ee-alpine-minimal:latest` (Alpine Linux 3.17, Python 3.10, without Java or Oracle client libraries)

More information here: https://gallery.ecr.aws/qorus

**NOTE**: All Docker images have been moved to `public.ecr.aws`; the `dregistry.qoretechnologies.com` registry is no longer used
---

## Pulling

In order to use the image you have to first pull it:
```
docker pull public.ecr.aws/qorus/qorus-ee:latest
```

## Quick start

### Docker Compose

The easiest way to start Qorus and its DB in a simple configuration for test and evaluation is to use Docker Compose.  A compose file is included in this repository.  To use it, make sure that you have `docker-compose` installed and available in your `PATH`. Then simply navigate to this directory and run the following:
```
docker-compose up
```

This will start up the database using `postgres:17` image and also start up a Qorus container that will connect to it as well as persistent volumes for the DB and for Qorus logs, configuration, and user code.

If you want to launch the containers in background, add `-d` option to the command:
```
docker-compose up -d
```

To check the container state, you can run `docker-compose ps` and to see all the running processes in the containers, you can run `docker-compose top`.

If you want to run additional containers/services or modify any settings, you can simply copy the compose file and edit it appropriately.

The `docker-compose` configuration also creates the `omquser` datasource in the PostgreSQL database at the same time as creating the system schema (in the system `omq` datasource).

### Linux example

First start the DB container.

For dev and evaluation purposes, a single-node, non-clustered database is sufficient; the following
command will start a PostgreSQL 17 database for Qorus with a persistent volume for the DB files:

```
docker run --name pg -v $HOME/qorus/postgres-data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=omq -e TZ=Europe/Prague -e PGTZ=Europe/Prague -d postgres:17
```

*NOTE*: Modify the DB password and time zone names appropriately (see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones for valid time zone names)

Create persistent directories for Qorus:
```
mkdir -p $HOME/qorus/etc $HOME/qorus/user $HOME/qorus/log
```

Download and start the Qorus image in a Docker container:

```
docker run --name qorus \
    --link pg:postgres \
    --restart always
    -p 8011:8011 \
    --ulimit nofile=8192:8192 \
    --ulimit nproc=8192:8192 \
    -e OMQ_DB_NAME=postgres \
    -e OMQ_DB_TYPE=pgsql \
    -e OMQ_DB_HOST=postgres \
    -e OMQ_DB_USER=postgres \
    -e OMQ_DB_PASS=omq \
    -e TZ=Europe/Prague \
    -e QORUS_ADMIN_PASS=changeme \
    -e QORUS_UID=1000 \
    -e QORUS_GID=100 \
    -v $HOME/qorus/etc:/opt/qorus/etc \
    -v $HOME/qorus/log:/opt/qorus/log \
    -v $HOME/qorus/user:/opt/qorus/user \
    -d public.ecr.aws/qorus/qorus-ee:latest
```

*NOTE*:
- Ensure that the `OMQ_DB_PASS` environment variable value matches the password set for the PostgreSQL image above
- Ensure that the `-v` options match the directories created above
- Update the first part of the `-p` option to expose the Qorus instance on another local port (ex: `-p 10011:8011`
  will expose the Qorus instance on local port `10011`)
- Update the value of the `QORUS_ADMIN_PASS` environment variable option above to set a custom admin password (Enterprise Edition only)
- Update the image name if necessary before starting

### Podman example
Podman is compatible with Docker, but it runs rootless, and in the container it runs as root, which is mapped to the current user on the host, therefore the same command line can be used with the `QORUS_UID` and `QORUS_GID` environment variables omitted - these environment variables should not be used with podman.

Download and start the Qorus image in a podman container:

```
podman run --name qorus \
    --link pg:postgres \
    --restart always
    -p 8011:8011 \
    --ulimit nofile=8192:8192 \
    --ulimit nproc=8192:8192 \
    -e OMQ_DB_NAME=postgres \
    -e OMQ_DB_TYPE=pgsql \
    -e OMQ_DB_HOST=postgres \
    -e OMQ_DB_USER=postgres \
    -e OMQ_DB_PASS=omq \
    -e TZ=Europe/Prague \
    -e QORUS_ADMIN_PASS=changeme \
    -v $HOME/qorus/etc:/opt/qorus/etc \
    -v $HOME/qorus/log:/opt/qorus/log \
    -v $HOME/qorus/user:/opt/qorus/user \
    -d public.ecr.aws/qorus/qorus-ee:latest
```

**NOTE** Qorus on podman requires Qorus 6.0.14 or better

## Docker Usage Info

To run a Qorus container in the background, you can run a command similar to the following:

```
docker run --name <CONTAINER> \
    --link <DB_CONTAINER>:<DB_HOSTNAME> \
    --restart always
    -p 8011:8011 \
    --ulimit nofile=8192:8192 \
    --ulimit nproc=8192:8192 \
    -e OMQ_DB_NAME=postgres \
    -e OMQ_DB_TYPE=pgsql \
    -e OMQ_DB_HOST=postgres \
    -e OMQ_DB_USER=postgres \
    -e OMQ_DB_PASS=omq \
    -e TZ=Europe/Prague \
    -e QORUS_ADMIN_PASS=changeme \
    -e QORUS_UID=1000 \
    -e QORUS_GID=100 \
    -v /path/to/omqdir/etc:/opt/qorus/etc \
    -v /path/to/omqdir/log:/opt/qorus/log \
    -v /path/to/omqdir/user:/opt/qorus/user \
    -d public.ecr.aws/qorus/qorus-ee:latest
```

The `--link` option is used to connect the Qorus container to another container. In this case a DB container since Qorus requires a database for functioning.

The `--restart` option configures the behaviour when the container exits, whether it be through an error, a normal exit etc. Since we usually want Qorus to always be running, we select the `always` flag.

The `-p` options are used to forward/publish internal container ports to host's ports.
With the default `options` file configuration, Qorus is set up to run on port 8011 for HTTPS traffic
(note that a self-signed certificate is used).  If you want to have multiple Qorus containers running on
the same machine with the default config, you can simply map them to different outer ports, for example
like this: `-p 12345:8011`. Without these port options, you won't be able to connect to Qorus from outside the container.
With the given option, you can connect to the Qorus instance with `https://localhost:8011` in the browser or using the
REST API.  Note that the format is *-p host_post:container_port*, so if you use `-p 12345:8011`, then you would connect
to Qorus with `https://localhost:12345` on the host.

The `-e` options set up environment variables. The ones related to system DB configuration are unnecessary if you mount the `/etc` directory containing `options` or `dbparams` file with correctly set up system DB connection.

Likewise, the `-v` options are used for mounting volumes (host filesystem directories) into the container. Mounting them is unnecessary and they can still be accessed easily from the docker data directory.

More info about the database configuration can be seen in the *System DB configuration* section.

**NOTE** Omit the `QORUS_UID` and `QORUS_GID` environment variables with podman

## Minimal example for testing

```
docker run --name pg -e POSTGRES_PASSWORD=omq -e TZ=Europe/Prague -e PGTZ=Europe/Prague -d postgres:17
docker run --name qorus --link pg:postgres -p 8011:8011 --ulimit nofile=8192:8192 --ulimit nproc=8192:8192 -e OMQ_DB_NAME=postgres -e OMQ_DB_TYPE=pgsql -e OMQ_DB_HOST=postgres -e OMQ_DB_USER=postgres -e OMQ_DB_PASS=omq -e QORUS_TZ=Europe/Prague -d public.ecr.aws/qorus/qorus-ee:latest
docker exec -it qorus bash -l
```

*NOTE*:
- the above example does not mount any config directories from the host in the containers, therefore neither the DB nor Qorus will run with persistent configuration or data; this example should only be used for quick testing.

## Logging

The container's logging is set up to merge stdout and stderr to one log. You can see all the output of the initialization script, the base `qorus` command and of `runit`, which is used as light init system in the Qorus Docker image.

To view log of the container's output, you can use the following:

```
docker logs <CONTAINER>
```

Other Qorus logs are then available in the `OMQ_DIR/log` directory, which you can read either by connecting to the container via bash shell or by mounting the log directory to a directory on the host filesystem.

## Connecting to running container

To connect to running instance with shell access, run the following:

```
docker exec -it <CONTAINER> bash -l
```

This will open a root bash login shell inside the container.  The `-l` option ensures that a login shell is used which
will set up the shell's environment so that programs and scripts in the container can communicate with Qorus properly.

## Qorus user and directory permissions

The Qorus Docker image is set up so that the `runit` init system runs under *root* user and Qorus runs under a special *qorus* user. By default, this user will have UID and GID both set to 999.

The following directories will also always get "chowned" (get their owner user and group set) to these UID and GID values during the container initialization (before launching Qorus):

* `$OMQ_DIR/etc`
* `$OMQ_DIR/log`
* `$OMQ_DIR/user`

This is done so that the *qorus* user is able to write to these directories.

If you want to have Qorus run under a different user, please create the user in the host system and supply the user's UID and GID to the Docker container with `QORUS_UID` and `QORUS_GID` environment variables. The affected OMQ_DIR directories will then get their owner UID and GID set to these values as well. Be aware that both of these environment variables have to be set, if you want to use them.

Another way how to set up the *qorus* user and group is to mount the `$OMQ_DIR/etc`, `$OMQ_DIR/log` and/or `$OMQ_DIR/user` directories as container volumes, and have them be owned under the correct user and group in the host filesystem. The container will then set up *qorus* user to match this UID and GID, and will also "chown" the other directories if they are owned by someone else.

The order in which these possibilities are checked:

1. If `QORUS_UID` and `QORUS_GID` environment variables are set up, they will be used.
2. If the affected `$OMQ_DIR` directories are owned by other user/group than root (UID or GID different from 0), then UID and GID will be taken from the first directory with different owner than root. These directories are checked in the following order:
    1. `$OMQ_DIR/etc`
    2. `$OMQ_DIR/log`
    3. `$OMQ_DIR/user`
3. The mounted `$OMQ_DIR` directories are either owned by the *root* user and group, or the volumes were not mounted (and are owned by *root* by default). In this case the default *qorus* user with UID and GID 999 will be used and the directories "chowned" by this user and group.

Make sure to always run the Qorus Docker image under the *root* user (i.e. don't use the `--user` option of `docker run` command), otherwise the above setup will fail.

## Enabling RBAC

RBAC (Role-Based Access Control) is disabled by default in a new Docker instance of Qorus Enterprise Edition.  To enable it, edit the `$OMQ_DIR/etc/options` file in the container (the `$OMQ_DIR/etc` directory is mounted from the host as well, so this file can also be edited on the host) and enable the `qorus.rbac-security` option by including a line like the following in the file:
```
qorus.rbac-security: true
```

Then restart qorus (ex: `docker restart qorus`)

See the next section for information on how to set the password for the *admin* user.

**NOTE** RBAC is not supported in the Community Edition

## Qorus admin account

The *admin* account is created by `schema-tool` during schema alignment during initialization phase of the Qorus Enterprise Edition container.  Its password is set to a random string.  If the `QORUS_ADMIN_PASS` environment variable is set when the Docker container is started for the first time, the account password will be set to the value of this environment variable.

If no password environment variables were set, then the random string used to set the *admin* user's password is logged in the output during the container's initialization.

To reset the *admin* password on subsequent runs of the Docker container, set `FORCE_UPDATE_ADMIN_USER=1` and restart the container (ex: `docker restart qorus`).

**NOTE**
- If RBAC is not enabled then user authentication is not required to access Qorus.
- RBAC is not supported in the Community Edition.

## Ports

Qorus is set to run on port `8011` for HTTPS traffic by default (using a self-signed certificate), unless the user changes or mounts their own `options` file in the `$OMQ_DIR/etc` directory.  In order to be able to connect to these ports from outside the container, you have to "publish" these ports using the `-p` option of the
`docker run` command.

## System DB configuration

There are two ways to configure Qorus's system DB:

1. Environment variables during the initial setup. Simply set the correct environment variables with DB connection
info. For example:

    ```
    -e OMQ_DB_NAME=postgres -e OMQ_DB_TYPE=pgsql -e OMQ_DB_HOST=postgres -e OMQ_DB_USER=postgres -e OMQ_DB_PASS=omq
    ```

    These could also be set from the Docker Compose configuration file.

    *NOTE*: The `OMQ_DB_*` environment variables only work when Qorus is initialized for the first time.  To change the DB
    connection after the initial setup, edit the `qorus.systemdb` option in the `options` file as described in the
    following item.

2. Edit the `$OMQ_DIR/etc/options` file with `qorus.systemdb` option set to the desired value
   (`/opt/qorus/etc/options` in the Docker container, `qorus-etc/options` on the host). For example:

    ```
    qorus.systemdb: pgsql:omq/omq@omq(utf8)%db-host
    ```

    For more information on this option, see:
    https://qoretechnologies.com/manual/qorus/current/qorus/systemoptions.html#systemdb and
    https://qoretechnologies.com/manual/qorus/current/qore/lang/html/group__dbi__functions.html#ga5bc0c2cfb4f1bfbf73c527f9441a6dbe

## Environment variables

The following are environment variables that you can set when running the Docker container with the `-e` options, or that you can configure in the Docker Compose file. They are read during the container initialization phase, before launching Qorus.

| Variable | Description |
| --- | --- |
| `DISABLE_QORUS_TELEMETRY` | if set to `Y` will disable telemetry which will disable all access to Qore Technologies' cloud APIs as well as any associated functionality (Qorus 7+)
| `FORCE_INIT_STEPS` | will force all init steps to be done |
| `FORCE_LOAD_SYSTEM_SERVICES` | will force oloading of all system jobs and services from the `$OMQ_DIR/system` directory |
| `FORCE_UPDATE_ADMIN_USER` | will force the init step of updating admin user password to run; the password won't be updated if the `QORUS_ADMIN_PASS` environment variable isn't set (see `2` below) |
| `OMQ_DB_NAME` | database name (see `1` below) |
| `OMQ_DB_TYPE` | database type, one of `pgsql`, `oracle` or `mysql` (see `1` below) |
| `OMQ_DB_HOST` | database host, assumed to be `localhost` if omitted (see `1` below) |
| `OMQ_DB_USER` | database username (see `1` below) |
| `OMQ_DB_PASS` | database password (see `1` below) |
| `OMQ_DB_ENC` | database encoding, assumed to be `utf8` if omitted (see `1` below) |
| `OMQ_DB_TABLESPACE` | DB tablespace, assumed to be `pg_default` if omitted and the system DB is PostgreSQL; note that this tablespace is used for both data and indexes; for separate tablespaces, edit the `qorus-client.omq-data-tablespace` and `qorus-client.omq-index-tablespace` options directly in the `options` file |
| `OMQUSER_DB_NAME` | `omquser` database name (see `3` below);  |
| `OMQUSER_DB_TYPE` | database type, one of `pgsql`, `oracle` or `mysql` (see `3` below) |
| `OMQUSER_DB_HOST` | database host, assumed to be `localhost` if omitted (see `3` below) |
| `OMQUSER_DB_USER` | database username (see `3` below) |
| `OMQUSER_DB_PASS` | database password (see `3` below) |
| `OMQUSER_DB_ENC` | database encoding, assumed to be `utf8` if omitted (see `3` below) |
| `OPENAI_API_KEY` | the Open AI API key (Qorus 7+)
| `QORE_TYPESCRIPT_ACTION_SCRIPTS` | A colon-separated list of JavaScript files containing data provider app-action definitions and code; files must use absolute paths from the server's perspective; for example a file in a persistent local location like `user/apps/my_app/index.js`, the path to use in this environment variable would be `/opt/qorus/user/apps/my_app/index.js` (Qorus 7+) |
| `QORUS_ADMIN_PASS` | Qorus admin user password, to which the *admin* account password will be set (see `2` below) |
| `QORUS_FORCE_CHECK_SCHEMA` | Force the schema alignment to run; allows for DB downgrades to be performed when starting Qorus
| `QORUS_GID` | GID under which Qorus will run |
| `QORUS_UID` | UID under which Qorus will run |
| `TZ` | The time zone locale for the container (ex: `Europe/Prague`: see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones for more info)

The environment variables related to system DB configuration are more suited for just trying out the Qorus Docker image. For production use-cases, please consider mounting the `$OMQ_DIR/etc` directory with the `options` file already properly configured.

*NOTES*
1. The DB environment variables (`OMQ_DB_*`) only take effect when Qorus is first initialized; if an `$OMQ_DIR/etc/options` file exists already with a `qorus.systemdb` option, these options are ignored.  In this case, make changes directly to the `$OMQ_DIR/etc/options` file and restart the container.
2. Options related to RBAC and users are only supported by the Enterprise Edition; the Community Edition does not support RBAC or users
3. The `omquser` datasource is created with the same connection as the main system schema if no `OMQUSER_DB_*` environment variables are set
