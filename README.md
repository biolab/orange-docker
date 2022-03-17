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
contains instructions for ubuntu platform: [instructions](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce).

If you want to deploy a new system, follow this guide to create a basic 
guacamole setup using official dockers: [setup guide](https://www.linode.com/docs/guides/installing-apache-guacamole-through-docker/)

After that, create common network and storage volume and attach each of the 
instances to the network and storage.

```sh
    docker network create guacamole
    docker network connect guacamole example-mysql
    docker network connect guacamole example-guacd
    docker network connect guacamole example-guacamole
```

### Start docker container ###

When you have a working guacamole environment, you can use this command to spawn 
additional Orange remote desktop instances. 

You can use the same command multiple times to create multiple remote desktop enviroments. Note that tag is the same as the hostname 
in the web interface and needs to be unique.


```sh
    tag=orange1
    docker run --name $tag --link example-guacd:guacd --network=guacamole -d orangedm/orange-docker-vnc:v1.0
```

Change the user password and VNC password withing container. 
```sh
    docker exec -it $tag /bin/bash
    passwd orange  # changes orange user password
    vncpasswd  # changes password for vnc
```

### Create connection ###

Admins must create new connections for each image via Settings -> Connections menu. 
Guacamole website contains [a detailed guide on Guacamole administration](https://guacamole.apache.org/doc/gug/administration.html).

In the browser open localhost:<port>/guacamole, where the port is the value that you see PORTS section for guacamole container if you run  `docker ps`.

The first time you login with the default user `guacadmin` and password `guacadmin`. Do not forget to change it.

Open Settings > Connections, and click on New connection.

In general, at least these values need to be configured:
- `Edit connections -> name`: Can be anything, this will be shown on the home dashboard
- `Edit connections -> name`: ROOT
- `Edit connections -> protocol`: VNC
- `Concurrency limits (both)`: Default is 1, set this to higher value if you want to share connections with multiple users.
- `Parameters -> Network -> hostname`: This equals to the $tag variable when creating instance or docker name. 
- `Parameters -> Network -> port`: 5901
- `Parameters -> Authentication -> Username`: orange
- `Parameters -> Authentication -> Password`: <vnc password assinged in the previous section>

### Sharing screen ###

Go to `Settings -> Connections`.

Click on the [+] sign left of the desktop you want to share with one-time 
link. If there exists a Sharing profile for this desktop you can skip this 
step. Otherwise click on the `New sharing profile`. Name the profile and check `Read only` if you want to restrict users to view only experience.

Click save. Now share button should be available from the Ctrl+Alt+Shift menu (when connected to the virtual machine).

### Stop instances ###

Use this command to stop the remote desktop instance.

```sh
    docker stop orange1
```
