# OS/161 Ready Docker Image

An Ubuntu 14.04 image with OS/161 installed. 

## Build Args
None of the build args are required.

| Argument | Description |
| --- | --- |
| `BASHRC_CONFIG_SCRIPT` | Path to a script that can be run prior to copying the `.bashrc` file. Useful to setup things (such as git prompt). Defaults to `bashrc_config.sh` |
| `SSH_PATH` | Path to the ssh directory, by default `.ssh`. Can place ssh configuration and keys for easy use in the container. |
| `GIT_URL` | URL to the git repo to be cloned into the user home. Useful for cloning OS/161 project. If not given, nothing is cloned. |

### Other info
`.bashrc` is copied into the container. My own `.bashrc` with colours and git prompt is provided, but can be personalised.

## Usage Example
```
docker build -t os161 --build-arg GIT_URL=git@github.com:trevoryao/cs350.git .
docker run -dt --name os161 os161
```
The container can be developed on in interactive mode (replace `-d` with `-i`), or in VSCode using the [container extension](https://code.visualstudio.com/docs/remote/containers).

## Bugs and other Features
Open an issue or PR. I'll look at it when I can.
