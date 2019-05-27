# docker-ttrss

[![Docker build status](https://img.shields.io/docker/cloud/build/aheilde/ttrss.svg)](https://cloud.docker.com/repository/docker/aheilde/ttrss/builds)
[![Docker pulls](https://img.shields.io/docker/pulls/_/ubuntu.svg)](https://hub.docker.com/r/aheilde/ttrss)

## What is ttrss and docker-ttrss

Tiny Tiny RSS (trss) is a free and open source web-based news feed (RSS/Atom) reader and aggregator which can be hosted by you on your own server.

When you want to run and host ttrss by yourself, there are a few manual steps involved, such as setting up and initialzing the database as well as running the feed updater to frequently fetch your feeds. 

This Docker image takes care of all of these manual steps for you. 

## Quickstart 

This section assumes you want to get started very quickly. More details will be provided later on. So let's start.

Step 1: Clone the GitHub repository 

```
> git clone https://github.com/aheil/docker-ttrss.git
```

Step 2: Start the containers using docker-compose: 

```
> docker-compoer up
```

Step 3: Run application using navigating browser to  

```
http://localhost:8080
```

You now should see the start page. By default you can login using the default paramters
```
Login: admin 
Password: password
```

## How to use this Docker image 

## Initializing a fresh instance

## Docker Hub Repository 

You can pull the latest image directly from [Docker Hub](https://cloud.docker.com/repository/docker/aheilde/ttrss).
Please refer the docker-compose.yml for dependencies and further configuration. 

## Caveats
There are some [caveats](https://www.urbandictionary.com/define.php?term=caveat) you should be aware of this project. Most of the issues we are working actively on. 
* The current setup is hard coded to a Postgres Database. Although, ttrss supports mysql this option is not configurable yet. This should be less a problem, as the provided setup starts its own Postgres container.
* Not all paramters used by ttrss are fully supported yet. 
* The image uses a recent stable version of ttrss. It is planned to make this more flexible in the future.
* Updates to a newer version is not supported for running containers. This is planned to be improved in the future.

## License 
The code for docker-ttrss at GitHub repository is licensed under a MIT license. Please refer the license page for further information.

## Further References 
* [Tiny Tiny RSS Homepage](https://tt-rss.org/)
