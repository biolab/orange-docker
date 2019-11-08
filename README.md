# Orange docker

Docker image for Orange Data Mining Suite.

## Start new instances ##

If you have a working guacamole environment, you can use this command to spawn 
additional remote desktop instances. Note that tag is the same as the hostname 
in the web interface and needs to be unique.


```sh
    tag=orange1
    docker run --rm -d -h $tag --name=$tag --network=guacamole -v guacamole_share:/home/orange/share -it orangedm/orange-xrdp
```

Use this command to stop the remote desktop instance.

```sh
    docker stop orange1
```

## Deploy from scratch ##

First ensure that you have a docker installed.
- [docker](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce).

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
volume first and then attach it to each container.

```sh
    docker volume create guacamole_share
```
