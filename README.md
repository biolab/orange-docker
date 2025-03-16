# Containerized application Orange
A Docker image that sets up a VNC server accessible via a web browser, allowing remote desktop access. It supports password protection, volume mounting for data persistence, and options for multiple simultaneous connections.

# Setup example
## Pulling the pre-built image from Github Container Registry
```
docker run --init -d --rm -p 6080:6080 -v {path_to_data_folder_on_host}:/data -e SHARED=0 ghcr.io/biolab/orange-docker:latest
```
A downside to this approach is that the VNC server's password is created at build time and is set to default value `pass`. To use a different password, build the image yourself or fork this repository and set a new repository secret `NOVNC_PASSWORD` in `https://github.com/{owner}/orange-docker/settings/secrets/actions`.
## Building the image yourself
Store your password into an environment variable NOVNC_PASSWORD, which will be used to securely set the password of VNC server inside the container.

**Replace "pass" with your password.**
```
export NOVNC_PASSWORD=pass
docker build --secret id=noVNC_password,env=NOVNC_PASSWORD -t orangedocker . 
```
```
docker run --init -d --rm -p 6080:6080 -v {path_to_data_folder_on_host}:/data -e SHARED=0 orangedocker
```
## How to use
Navigate to `https://localhost:6080/vnc.html` or `https://{host_ip}:6080/vnc.html`. Certificates for SSL/TLS encryption are currently self-signed, which means the browser will not allow connections by default, without you clicking through and accepting the warning pop-up.

Once on the noVNC hmepage, click connect and input your password. On the left are also some useful settings, such as "Remote Resizing" which makes the resolution match your browser.

### Options
**Port:**

`-p {host_port}:6080` maps host's port to container's port `6080`. To run multiple instances assign a unique `host_port` to each container.

**Shared volume:**

`-v {path_to_data_folder_on_host}:/data` creates a shared volume between host and container. Explained in more detail in the following section.

**Multiple connections:**

The VNC server allows only one connection at a time by default. To allow multiple simultaneous connections pass `-e SHARED=1` to `docker run`.

# Importing and exporting data
The `docker run` command in the example creates a volume mount between data stored in your specified path `{path_to_data_folder_on_host}` and `/data/` inside the container. Data stored inside the container's `/data/` folder will persist on host folder after stopping the container.

If exporting resulting data to host is not needed and you wish to burn import data into the image at build, you can do so by creating a `data/` folder in the same folder as `Dockerfile` and using `docker run` command without creating a volume mount.
```
docker run --init -d --rm -p 6080:6080 orangedocker
```
