# Orange docker #

Docker image for Orange Data Mining Suite.

You can run Orange in docker containers on server infrastructure. Key benefits of this approach are:
- Orange can have access to greater amount of memory and processing power
- It can be accessible from anywhere and can be run for extended time without interruptions
- Existing workflows can be shared with other people in real time

We use the following technologies:
- Docker containers
- Remote access via RDP, VNC and SSH protocols.
- Apache Guacamole as HTML front-end

### Setup guide ###

First ensure that you have a docker installed. The following guide 
contains instructions for ubuntu platform:
- [docker](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce)

If you want to deploy a new system, follow this guide to create a basic 
guacamole setup using official dockers:
- [setup guide](https://www.linode.com/docs/applications/remote-desktop/remote-desktop-using-apache-guacamole-on-docker/)

After that, create common network and storage volume and attach each of the 
instances to the network and storage.

```sh
    docker network create guacamole
    docker network connect guacamole example-mysql
    docker network connect guacamole example-guacd
    docker network connect guacamole example-guacamole
```

Shared volume is used to transfer data. To enable this feature, create the 
volume first and then attach it to example-guacamole container.

```sh
    docker volume create guacamole_share1
```

### Start docker container ###

If you have a working guacamole environment, you can use this command to spawn 
additional remote desktop instances. Note that tag is the same as the hostname 
in the web interface and needs to be unique.


```sh
    tag=orange1
    docker run --rm -d -h $tag --name=$tag --network=guacamole -v guacamole_share1:/home/orange/share -it orangedm/orange-xrdp
```

Change the password within the container. 
```sh
    docker exec -it orange1 /bin/bash
    passwd orange
```

### Create connection ###

Admins can create new connections via Settings -> Connections menu. 
Guacamole website contains a detailed guide on this:
- [Guacamole administration](https://guacamole.apache.org/doc/gug/administration.html).

In general, at least these values need to be configured:
- Edit connections -> name: Can be anything, this will be shown on the home dashboard
- Edit connections -> protocol: RDP (if you use orangedm/orange-xrdp image)
- Concurrency limits (both): Default is 1, set this to higher value if you want to share connections with multiple users.
- Parameters -> Network -> hostname: This equals to the $tag variable when creating instance or docker name. 
- Parameters -> Authentication -> Username: orange
- Parameters -> Authentication -> Username: password # use password you set in the previous section

If you want to enable file transfers you need to also configure the following fields:
- Device redirection -> Enable drive
- Device redirection -> Drive name
- Device redirection -> Drive path
- Device redirection -> Automatically create drive (optional)

Drive path should be different for each container and is the path 
to where docker volume is mounted in example-guacamole container. 
Make sure the drive is mounted correctly:

```sh
    docker exec -it example-guacamole /bin/bash
    mount
```

Click on the create connection button. The connection is created and you 
should be able to see it in the main dashboard. You can restrict/allow access 
to individual users in the “Users” tab.

### Sharing screen ###

Go to Settings -> Connections.

Click on the [+] sign left of the desktop you want to share with one-time 
link. If there exists a Sharing profile for this desktop you can skip this 
step. Otherwise click on the “New sharing profile”. Check “Read only” if 
you want to restrict users to view only experience.

Click save. Now share button should be available from the Ctrl+Alt+Shift menu.

### File transfer ###

If you have enabled file sharing, you can upload and download the files via the 
side panel. To transfer files to the remote server, open the side menu (Ctrl+Alt+Shift) 
and click Shared drive button. You will see a list of files. You can either 
click “Upload file” button at the top and choose a file from the local computer 
or drag&drop the files into browser tab.

After the upload is completed, double click on the “File Manager” icon on the 
desktop to re-open the share folder. File manager was configured to reset file 
ownership when opened. Otherwise you will may to set the permissions manually. 

Files are now located within the container in ~/share and you can access them 
from Orange application.

### Stop instances ###

Use this command to stop the remote desktop instance.

```sh
    docker stop orange1
```
