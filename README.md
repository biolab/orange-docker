# Setup example
Replace "pass" with your password.
```
export NOVNC_PASSWORD=pass
docker build --secret id=noVNC_password,env=NOVNC_PASSWORD -t orangedocker:latest . 
```

```
docker run --init -d --rm -p 6080:6080 -v {path_to_data_folder_on_host}:/data orangedocker
```

Navigate to `https://localhost:6080/vnc.html` or `https://{host_ip}:6080/vnc.html` if on the same network. Certificates for SSL/TLS encryption are currently self-signed which means the browser will not allow connections by default without you clicking through and accepting the warning pop-up.

Once on the noVNC homepage click connect and input your password. On the left are also some useful settings such as "Remote Resizing" which makes the resolution match your browser.

The VNC server allows only one connection at a time by default. To allow multiple simultaneous connections pass `-e SHARED=1` to `docker run`.
```
docker run --init -d --rm -p 6080:6080 -v {path_to_data_folder_on_host}:/data -e SHARED=1 orangedocker

``` 

# How to import and export data
The `docker run` command in the example creates a volume mount between data stored in your specified path `{path_to_data_folder_on_host}` and `/data/` inside the container. Data stored inside the container's `/data/` folder will persist on host folder after stopping the container.

If exporting resulting data to host is not needed and you wish to burn import data into the image at build, you can do so by creating a `data/` folder in the same folder as `Dockerfile` and using `docker run` command without creating a volume mount.
```
docker run --init -d --rm -p 6080:6080 orangedocker
```